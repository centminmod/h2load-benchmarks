#!/bin/bash

TIMESTAMP=$(date +%Y%m%d%H%M%S)
RAW_LOG="h2load-logs/h2load-raw-$TIMESTAMP.log"
STATS_JSON="h2load-logs/h2load-stats-$TIMESTAMP.json"

# Ensure the h2load-logs directory exists
mkdir -p h2load-logs

# Initialize our own variables
THREADS=""
CONNECTIONS=""
REQUESTS=""
REQ_DURATION=""
WARM_UP_TIME=""
URI=""

if ! command -v h2load &> /dev/null
then
    echo "h2load could not be found. Please make sure it is installed and in the PATH."
    exit
fi

# Process arguments
OPTIONS=ht:c:n:D:w:u:
LONGOPTS=usage,threads:,connections:,requests:,duration:,warm-up:,uri:

usage() {
    echo "Usage: $0 [-t threads] [-c connections] [-n requests] [-D duration] [-w warm-up] [-u uri]"
    echo
    echo "Options:"
    echo "  -t, --threads       Number of threads"
    echo "  -c, --connections   Number of connections"
    echo "  -n, --requests      Number of requests"
    echo "  -D, --duration      Duration of the benchmark"
    echo "  -w, --warm-up       Warm-up time before the benchmark"
    echo "  -u, --uri           URI to request"
    echo "  -h, --help          Display this help message"
    exit 0
}

if [ $# -eq 0 ]; then
    usage
    exit 0
fi

PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")

if [[ $? -ne 0 ]]; then
    exit 2
fi

eval set -- "$PARSED"

while true; do
    case "$1" in
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -c|--connections)
            CONNECTIONS="$2"
            shift 2
            ;;
        -n|--requests)
            REQUESTS="$2"
            shift 2
            ;;
        -D|--duration)
            REQ_DURATION="$2"
            shift 2
            ;;
        -w|--warm-up)
            WARM_UP_TIME="$2"
            shift 2
            ;;
        -u|--uri)
            URI="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        --)
            shift
            break
            ;;
    esac
done

if [ -n "$REQ_DURATION" ]; then
  h2load -t$THREADS -c$CONNECTIONS -D$REQ_DURATION --warm-up-time=$WARM_UP_TIME -m32 -H 'Accept-Encoding: gzip,br' $URI > "$RAW_LOG"
else
  h2load -t$THREADS -c$CONNECTIONS -n$REQUESTS -m32 -H 'Accept-Encoding: gzip,br' $URI > "$RAW_LOG"
fi

# Parse h2load output and convert it to JSON format
JSON_OUTPUT=$(awk '
  /finished in/ {time=$3; req_per_sec=$4; mbs=$6}
  /requests:/ {total_req=$2; started_req=$4; done_req=$6; succeeded_req=$8; failed_req=$10; errored_req=$12; timeout_req=$14}
  /status codes:/ {status_2xx=$3; status_3xx=$5; status_4xx=$7; status_5xx=$9}
  /traffic:/ {total_traffic=$2; header_traffic=$5; data_traffic=$11; data_traffic_savings=$10}
  /time for request:/ {req_min=$4; req_max=$5; req_mean=$6; req_sd=$7; req_sd_pct=$8}
  /time for connect:/ {conn_min=$4; conn_max=$5; conn_mean=$6; conn_sd=$7; conn_sd_pct=$8}
  /time to 1st byte:/ {first_byte_min=$5; first_byte_max=$6; first_byte_mean=$7; first_byte_sd=$8; first_byte_sd_pct=93}
  /req\/s/ {req_s_min=$3; req_s_max=$4; req_s_mean=$5; req_s_sd=$6; req_s_sd_pct=$7}
  /Cipher:/ {cipher=$2}
  /Server Temp Key:/ {tempkey=$4}
  /Application protocol:/ {protocol=$3}
  END {
    printf "{\
      \"time\": \"%s\", \"req_per_sec\": \"%s\", \"mbs\": \"%s\",\
      \"total_req\": \"%s\", \"started_req\": \"%s\", \"done_req\": \"%s\", \"succeeded_req\": \"%s\", \"failed_req\": \"%s\", \"errored_req\": \"%s\", \"timeout_req\": \"%s\",\
      \"status_2xx\": \"%s\", \"status_3xx\": \"%s\", \"status_4xx\": \"%s\", \"status_5xx\": \"%s\",\
      \"total_traffic\": \"%s\", \"header_traffic\": \"%s\", \"data_traffic\": \"%s\",\
      \"req_min\": \"%s\", \"req_max\": \"%s\", \"req_mean\": \"%s\", \"req_sd\": \"%s\", \"req_sd_pct\": \"%s\",\
      \"conn_min\": \"%s\", \"conn_max\": \"%s\", \"conn_mean\": \"%s\", \"conn_sd\": \"%s\", \"conn_sd_pct\": \"%s\",\
      \"first_byte_min\": \"%s\", \"first_byte_max\": \"%s\", \"first_byte_mean\": \"%s\", \"first_byte_sd\": \"%s\", \"first_byte_sd_pct\": \"%s\",\
      \"req_s_min\": \"%s\", \"req_s_max\": \"%s\", \"req_s_mean\": \"%s\", \"req_s_sd\": \"%s\", \"req_s_sd_pct\": \"%s\",\
      \"cipher\": \"%s\", \"tempkey\": \"%s\", \"protocol\": \"%s\"\
    }", time, req_per_sec, mbs,\
    total_req, started_req, done_req, succeeded_req, failed_req, errored_req, timeout_req,\
    status_2xx, status_3xx, status_4xx, status_5xx,\
    total_traffic, header_traffic, data_traffic,\
    req_min, req_max, req_mean, req_sd, req_sd_pct,\
    conn_min, conn_max, conn_mean, conn_sd, conn_sd_pct,\
    first_byte_min, first_byte_max, first_byte_mean, first_byte_sd, first_byte_sd_pct,\
    req_s_min, req_s_max, req_s_mean, req_s_sd, req_s_sd, cipher, tempkey, protocol
  }' $RAW_LOG)

# Save JSON output to a file
printf "%s\n" "$JSON_OUTPUT" > "$STATS_JSON"

# Display the JSON output
printf "%s\n" "$JSON_OUTPUT"

