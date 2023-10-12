#!/bin/bash

TIMESTAMP=$(date +%Y%m%d%H%M%S)
RAW_LOG_PREFIX="h2load-logs/h2load-raw-$TIMESTAMP"
STATS_JSON="h2load-logs/h2load-stats-$TIMESTAMP.json"
STATS_CSV="h2load-logs/h2load-stats-$TIMESTAMP.csv"
STATS_MAX_CSV="h2load-logs/h2load-stats-max-$TIMESTAMP.csv"
PSRECORD_LOG="psrecord-logs/psrecord-nginx-$TIMESTAMP.log"
PSRECORD_LOG_JSON="psrecord-logs/psrecord-nginx-$TIMESTAMP.json"
PSRECORD_LOG_CSV="psrecord-logs/psrecord-nginx-$TIMESTAMP.csv"
PSRECORD_PLOT_IMAGE="psrecord-logs/psrecord-nginx-$TIMESTAMP.png"

# local h2load test psrecord for Nginx resource usage
PSRECORD_LOCAL='y'
PSRECORD_DELAY='15'

# Ensure the h2load-logs directory exists
mkdir -p h2load-logs psrecord-logs

# Initialize our own variables
THREADS=""
CONNECTIONS=""
REQUESTS=""
REQ_DURATION=""
WARM_UP_TIME=""
URI=""
BATCH_MODE=0
MAXCONCURRENT_STREAMS='100'

if ! command -v h2load &> /dev/null
then
    echo "h2load could not be found. Please make sure it is installed and in the PATH."
    exit
fi
# Check if h2load built with HTTP/3 support
if [[ "$(ldd $(which h2load) | grep -o libnghttp3 | sort -u)" = 'libnghttp3' ]]; then
  HTTP3_OPT=' --npn-list h3'
else
  HTTP3_OPT=""
fi

# Process arguments
OPTIONS=ht:c:n:D:w:u:b
LONGOPTS=usage,threads:,connections:,requests:,duration:,warm-up:,uri:,batch

usage() {
    echo "Usage: $0 [-t threads] [-c connections] [-n requests] [-D duration] [-w warm-up] [-u uri] [-b batch]"
    echo
    echo "Options:"
    echo "  -t, --threads       Number of threads"
    echo "  -c, --connections   Number of connections"
    echo "  -n, --requests      Number of requests"
    echo "  -D, --duration      Duration of the benchmark"
    echo "  -w, --warm-up       Warm-up time before the benchmark"
    echo "  -u, --uri           URI to request"
    echo "  -b, --batch         Enable batch mode"
    echo "  -h, --help          Display this help message"
    exit 0
}

converter() {
  mode="$1"
  file="$2"
  if [[ "$mode" = 'json' ]]; then
    cat "$file" | sed -e '1d' | column -t | tr -s ' ' | jq -nR '[inputs | split(" ") | { "time": .[0], "cpuload": .[1], "realmem": .[2], "virtualmem": .[3] }]'
  fi
}

service_info_json() {
  info_service_name=$1
  if [[ -n "$info_service_name" ]]; then
    if [ "$(egrep 'centos:7|CentOS Linux 7' /etc/os-release )" ]; then
      systemctl show --no-pager $info_service_name | jq --slurp --raw-input 'split("\n") | map(select(. != "") | split("=") | {"key": .[0], "value": (.[1:] | join("="))}) | from_entries' | jq --arg sli_opt $sli_opt -r '{Names: .Names, Description: .Description, Type: .Type, ActiveState: .ActiveState, LoadState: .LoadState, SubState: .SubState, Result: .Result, ExecMainStartTimestamp: .ExecMainStartTimestamp, MainPID: .MainPID, DropInPaths: .DropInPaths, ExecStart: .ExecStart, ExecStartPre: .ExecStartPre, ExecReload: .ExecReload, ExecStop: .ExecStop, PIDFile: .PIDFile, LimitMEMLOCK: .LimitMEMLOCK, LimitNOFILE: .LimitNOFILE, LimitNPROC: .LimitNPROC, After: .After, Before: .Before, Conflicts: .Conflicts, FailureAction: .FailureAction, FragmentPath: .FragmentPath, NotifyAccess: .NotifyAccess, PrivateNetwork: .PrivateNetwork, PrivateTmp: .PrivateTmp, ProtectHome: .ProtectHome, ProtectSystem: .ProtectSystem, Requires: .Requires, Restart: .Restart, RestartUSec: .RestartUSec, StartLimitAction: .StartLimitAction, StartLimitBurst: .StartLimitBurst, StartLimitInterval: .StartLimitInterval, TimeoutStartUSec: .TimeoutStartUSec, TimeoutStopUSec: .TimeoutStopUSec, UnitFilePreset: .UnitFilePreset, UnitFileState: .UnitFileState, WantedBy: .WantedBy, Wants: .Wants}'
    else
      systemctl show --no-pager $info_service_name | jq --slurp --raw-input 'split("\n") | map(select(. != "") | split("=") | {"key": .[0], "value": (.[1:] | join("="))}) | from_entries' | jq --arg sli_opt $sli_opt -r '{Names: .Names, Description: .Description, Type: .Type, ActiveState: .ActiveState, LoadState: .LoadState, SubState: .SubState, Result: .Result, ExecMainStartTimestamp: .ExecMainStartTimestamp, MainPID: .MainPID, DropInPaths: .DropInPaths, ExecStart: .ExecStart, ExecStartPre: .ExecStartPre, ExecReload: .ExecReload, ExecStop: .ExecStop, PIDFile: .PIDFile, LimitMEMLOCK: .LimitMEMLOCK, LimitNOFILE: .LimitNOFILE, LimitNPROC: .LimitNPROC, After: .After, Before: .Before, Conflicts: .Conflicts, FailureAction: .FailureAction, FragmentPath: .FragmentPath, NotifyAccess: .NotifyAccess, PrivateNetwork: .PrivateNetwork, PrivateTmp: .PrivateTmp, ProtectHome: .ProtectHome, ProtectSystem: .ProtectSystem, Requires: .Requires, Restart: .Restart, RestartUSec: .RestartUSec, StartLimitAction: .StartLimitAction, StartLimitBurst: .StartLimitBurst, StartLimitIntervalUSec: .StartLimitIntervalUSec, TimeoutStartUSec: .TimeoutStartUSec, TimeoutStopUSec: .TimeoutStopUSec, UnitFilePreset: .UnitFilePreset, UnitFileState: .UnitFileState, WantedBy: .WantedBy, Wants: .Wants}'
    fi
  else
    echo "incorrect syntax"
    echo "missing servicename"
    echo "$0 service-info servicename"
  fi
}

parse_psrecord() {
  input_psrecord_file="$1"
  input_psrecord_sleep="$2"
  echo
  echo
  echo "##################################################################"
  echo "parsing & converting nginx psrecord data..."
  echo "waiting for psrecord to close its log..."
  sleep $input_psrecord_sleep
  echo "converter json $input_psrecord_file" > "$PSRECORD_LOG_JSON"
  converter json "$input_psrecord_file" > "$PSRECORD_LOG_JSON"
}

psrecord_to_csv() {
  json_file="$1"
  # Convert JSON to CSV
  jq -r '.[] | [.time, .cpuload, .realmem, .virtualmem] | @csv' $json_file > "$PSRECORD_LOG_CSV"
}

psrecord_start() {
  if [[ -f /usr/local/bin/psrecord && "$PSRECORD_LOCAL" = [yY] ]]; then
    if [ -f /usr/bin/cminfo ]; then
      spid=$(cminfo service-info nginx | jq -r '.MainPID')
    else
      spid=$(service_info_json nginx | jq -r '.MainPID')
    fi
  
    if [ -n "$spid" ]; then
      echo "start psrecord ..."
      sleep "${PSRECORD_DELAY}"
      echo "psrecord $spid --include-children --interval 0.1 --log ${PSRECORD_LOG} --plot $PSRECORD_PLOT_IMAGE &"
      psrecord $spid --include-children --interval 0.1 --log ${PSRECORD_LOG} --plot $PSRECORD_PLOT_IMAGE &
      psrecord_pid=$!
      echo
    fi
  fi
}

psrecord_end() {
  if [[ -f /usr/local/bin/psrecord && "$PSRECORD_LOCAL" = [yY] ]]; then
    if [ -n "$spid" ]; then
      kill $psrecord_pid
      wait $psrecord_pid 2>/dev/null
      parse_psrecord "${PSRECORD_LOG}" "$PSRECORD_DELAY"
      psrecord_to_csv "$PSRECORD_LOG_JSON"
      if [ -f psrecord.gnuplot ]; then
        ./psrecord.gnuplot "$PSRECORD_LOG_CSV" "$TIMESTAMP"
      fi
      echo "csv log: $PSRECORD_LOG_CSV"
      echo "json log: $PSRECORD_LOG_JSON"
      echo "psrecord chart: psrecord-logs/psrecord-$TIMESTAMP.png"
      echo "end psrecord"
    fi
  fi
}

parse_output_to_json() {
  local log_file="$1"
  local threads="$2"
  local connections="$3"
  local duration="$4"
  local warm_up_time="$5"
  local requests="$6"

  # If duration or requests is not provided, represent as null in the JSON output
  [ -z "$duration" ] && duration="null"
  [ -z "$requests" ] && requests="null"
  [ -z "$warm_up_time" ] && warm_up_time="null"

  awk -v threads="$threads" -v connections="$connections" -v duration="$duration" -v warm_up_time="$warm_up_time" -v requests="$requests" '
  function convert_time(str) {
    if (str ~ /^[0-9.]+s$/) {
      return str * 1000;
    } else if (str ~ /^[0-9.]+us$/) {
      return str / 1000;
    } else if (str ~ /^[0-9.]+ms$/) {
      return substr(str, 1, length(str)-2);
    }
  }

  /finished in/ {time=$3; sub(/,$/, "", time); req_per_sec=$4; mbs=$6}
  /requests:/ {total_req=$2; started_req=$4; done_req=$6; succeeded_req=$8; failed_req=$10; errored_req=$12; timeout_req=$14}
  /status codes:/ {status_2xx=$3; status_3xx=$5; status_4xx=$7; status_5xx=$9}
  /traffic:/ {total_traffic=$2; header_traffic=$5; data_traffic=$11; data_traffic_savings=$10}
  /time for request:/ {req_min=convert_time($4); req_max=convert_time($5); req_mean=convert_time($6); req_sd=$7; req_sd_pct=$8}
  /time for connect:/ {conn_min=convert_time($4); conn_max=convert_time($5); conn_mean=convert_time($6); conn_sd=$7; conn_sd_pct=$8}
  /time to 1st byte:/ {first_byte_min=convert_time($5); first_byte_max=convert_time($6); first_byte_mean=convert_time($7); first_byte_sd=$8; first_byte_sd_pct=$9}
  /req\/s/ {req_s_min=$3; req_s_max=$4; req_s_mean=$5; req_s_sd=$6; req_s_sd_pct=$7}
  /Cipher:/ {cipher=$2}
  /Server Temp Key:/ {tempkey=$4}
  /Application protocol:/ {protocol=$3}
  /UDP datagram:/ {udp_sent=$3; udp_received=$5}
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
      \"cipher\": \"%s\", \"tempkey\": \"%s\", \"protocol\": \"%s\",\
      \"threads\": \"%s\", \"connections\": \"%s\", \"duration\": \"%s\", \"warm_up_time\": \"%s\", \"requests\": \"%s\",\
      \"udp_sent\": \"%s\", \"udp_received\": \"%s\"\
    }", time, req_per_sec, mbs,\
    total_req, started_req, done_req, succeeded_req, failed_req, errored_req, timeout_req,\
    status_2xx, status_3xx, status_4xx, status_5xx,\
    total_traffic, header_traffic, data_traffic,\
    req_min, req_max, req_mean, req_sd, req_sd_pct,\
    conn_min, conn_max, conn_mean, conn_sd, conn_sd_pct,\
    first_byte_min, first_byte_max, first_byte_mean, first_byte_sd, first_byte_sd_pct,\
    req_s_min, req_s_max, req_s_mean, req_s_sd, req_s_sd, cipher, tempkey, protocol,\
    threads, connections, duration, warm_up_time, requests, udp_sent, udp_received
  }' $1
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
        -b|--batch)
            BATCH_MODE=1
            shift
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

if [ $BATCH_MODE -eq 1 ]; then
    psrecord_start
    # In batch mode, we run 4 times, each time increasing the number of connections
    for i in {1..4}; do
        CURRENT_CONNECTIONS=$(($CONNECTIONS * $i / 4))
        CURRENT_RAW_LOG="${RAW_LOG_PREFIX}-batch$i.log"
        if [ -n "$REQ_DURATION" ]; then
            h2load -t$THREADS${HTTP3_OPT} -c$CURRENT_CONNECTIONS -D$REQ_DURATION --warm-up-time=$WARM_UP_TIME -m$MAXCONCURRENT_STREAMS -H 'Accept-Encoding: gzip,br' $URI > "$CURRENT_RAW_LOG"
        else
            h2load -t$THREADS${HTTP3_OPT} -c$CURRENT_CONNECTIONS -n$REQUESTS -m$MAXCONCURRENT_STREAMS -H 'Accept-Encoding: gzip,br' $URI > "$CURRENT_RAW_LOG"
        fi
        # Parse h2load output and convert it to JSON format
        JSON_OUTPUT=$(parse_output_to_json "$CURRENT_RAW_LOG" "$THREADS" "$CURRENT_CONNECTIONS" "$REQ_DURATION" "$WARM_UP_TIME" "$REQUESTS")
        # Append JSON output to a file
        printf "%s\n" "$JSON_OUTPUT" >> "$STATS_JSON"
        # CSV log for request avg latency
        jq -r '.connections, .req_per_sec, .req_mean' < "$STATS_JSON" | awk 'ORS=NR%3?",":"\n"' > "$STATS_CSV"
        \cp -af "$STATS_CSV" output.csv
        # CSV log 2 for request max latency
        jq -r '.connections, .req_per_sec, .req_max' < "$STATS_JSON" | awk 'ORS=NR%3?",":"\n"' > "$STATS_MAX_CSV"
        \cp -af "$STATS_MAX_CSV" output2.csv
        # Display the JSON output
        printf "%s\n" "$JSON_OUTPUT"
    done
else
    psrecord_start
    # If not in batch mode, we run as before
    RAW_LOG="${RAW_LOG_PREFIX}.log"
    if [ -n "$REQ_DURATION" ]; then
        h2load -t$THREADS${HTTP3_OPT} -c$CONNECTIONS -D$REQ_DURATION --warm-up-time=$WARM_UP_TIME -m$MAXCONCURRENT_STREAMS -H 'Accept-Encoding: gzip,br' $URI > "$RAW_LOG"
    else
        h2load -t$THREADS${HTTP3_OPT} -c$CONNECTIONS -n$REQUESTS -m$MAXCONCURRENT_STREAMS -H 'Accept-Encoding: gzip,br' $URI > "$RAW_LOG"
    fi
    # Parse h2load output and convert it to JSON format
    JSON_OUTPUT=$(parse_output_to_json "$RAW_LOG" "$THREADS" "$CONNECTIONS" "" "" "$REQUESTS")
    # Save JSON output to a file
    printf "%s\n" "$JSON_OUTPUT" > "$STATS_JSON"
    # CSV log for request avg latency
    jq -r '.connections, .req_per_sec, .req_mean' < "$STATS_JSON" | awk 'ORS=NR%3?",":"\n"' > "$STATS_CSV"
    \cp -af "$STATS_CSV" output.csv
    # CSV log 2 for request max latency
    jq -r '.connections, .req_per_sec, .req_max' < "$STATS_JSON" | awk 'ORS=NR%3?",":"\n"' > "$STATS_MAX_CSV"
    \cp -af "$STATS_MAX_CSV" output2.csv
    # Display the JSON output
    printf "%s\n" "$JSON_OUTPUT"
fi
echo
echo "h2load benchmark JSON results: $STATS_JSON"
psrecord_end