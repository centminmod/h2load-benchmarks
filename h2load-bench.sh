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
PSRECORD_LOCAL='n'
PSRECORD_DELAY='15'

# Ensure the h2load-logs directory exists
mkdir -p h2load-logs psrecord-logs

# Initialize our own variables
THREADS=""
CONNECTIONS=""
REQUESTS=""
REQ_DURATION=""
WARM_UP_TIME=""
URIS=""
BATCH_MODE=0
MAXCONCURRENT_STREAMS='100'
BENCHMARK_RUNS=11
COMPRESS="gzip,br"
FORMAT="json"

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
OPTIONS=ht:c:n:D:w:u:bC:f:
LONGOPTS=usage,threads:,connections:,requests:,duration:,warm-up:,uri:,batch,compress:,format:

usage() {
    echo "Usage: $0 [-t threads] [-c connections] [-n requests] [-D duration] [-w warm-up] [-u uri1,uri2,...] [-b batch] [-C compress] [-f format]"
    echo
    echo "Options:"
    echo "  -t, --threads       Number of threads"
    echo "  -c, --connections   Number of connections"
    echo "  -n, --requests      Number of requests"
    echo "  -D, --duration      Duration of the benchmark"
    echo "  -w, --warm-up       Warm-up time before the benchmark"
    echo "  -u, --uri           Comma-separated list of URIs to request"
    echo "  -b, --batch         Enable batch mode"
    echo "  -C, --compress      Compression option (gzip, br, zstd, none)"
    echo "  -f, --format        Output format (json or markdown)"
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
  local uri="$7"

  # If duration or requests is not provided, represent as null in the JSON output
  [ -z "$duration" ] && duration="null"
  [ -z "$requests" ] && requests="null"
  [ -z "$warm_up_time" ] && warm_up_time="null"

  awk -v threads="$threads" -v connections="$connections" -v duration="$duration" -v warm_up_time="$warm_up_time" -v requests="$requests" -v uri="$uri" '
  function convert_time(str) {
      if (str ~ /^[0-9.]+s$/) {
          return substr(str, 1, length(str)-1);
      } else if (str ~ /^[0-9.]+us$/) {
          return substr(str, 1, length(str)-2) / 1000000;
      } else if (str ~ /^[0-9.]+ms$/) {
          return substr(str, 1, length(str)-2) / 1000;
      }
      return str;
  }

  function format_time_with_unit(value) {
      if (value >= 1) {
          return sprintf("%.4fs", value);
      } else if (value >= 0.001) {
          return sprintf("%.4fms", value * 1000);
      } else {
          return sprintf("%.4fus", value * 1000000);
      }
  }

  /finished in/ {time=$3; sub(/,$/, "", time); req_per_sec=$4; mbs=$6}
  /requests:/ {total_req=$2; started_req=$4; done_req=$6; succeeded_req=$8; failed_req=$10; errored_req=$12; timeout_req=$14}
  /status codes:/ {status_2xx=$3; status_3xx=$5; status_4xx=$7; status_5xx=$9}
  /traffic:/ {total_traffic=$2; header_traffic=$5; data_traffic=$11; data_traffic_savings=$10}
  /time for request:/ {req_min=convert_time($4); req_max=convert_time($5); req_mean=convert_time($6); req_sd=convert_time($7); req_sd_pct=$8}
  /time for connect:/ {conn_min=convert_time($4); conn_max=convert_time($5); conn_mean=convert_time($6); conn_sd=convert_time($7); conn_sd_pct=$8}
  /time to 1st byte:/ {first_byte_min=convert_time($5); first_byte_max=convert_time($6); first_byte_mean=convert_time($7); first_byte_sd=convert_time($8); first_byte_sd_pct=$9}
  /req\/s/ {req_s_min=$3; req_s_max=$4; req_s_mean=$5; req_s_sd=$6; req_s_sd_pct=$7}
  /Cipher:/ {cipher=$2}
  /Server Temp Key:/ {tempkey=$4}
  /Application protocol:/ {protocol=$3}
  /UDP datagram:/ {udp_sent=$3; udp_received=$5}
  END {
    printf "{\
      \"uri\": \"%s\",\
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
    }", uri, format_time_with_unit(time), req_per_sec, mbs,\
    total_req, started_req, done_req, succeeded_req, failed_req, errored_req, timeout_req,\
    status_2xx, status_3xx, status_4xx, status_5xx,\
    total_traffic, header_traffic, data_traffic,\
    format_time_with_unit(req_min), format_time_with_unit(req_max), format_time_with_unit(req_mean), format_time_with_unit(req_sd), req_sd_pct,\
    format_time_with_unit(conn_min), format_time_with_unit(conn_max), format_time_with_unit(conn_mean), format_time_with_unit(conn_sd), conn_sd_pct,\
    format_time_with_unit(first_byte_min), format_time_with_unit(first_byte_max), format_time_with_unit(first_byte_mean), format_time_with_unit(first_byte_sd), first_byte_sd_pct,\
    req_s_min, req_s_max, req_s_mean, req_s_sd, req_s_sd_pct, cipher, tempkey, protocol,\
    threads, connections, duration, warm_up_time, requests, udp_sent, udp_received
  }' $log_file
}

average_results() {
    local json_files=("$@")
    local avg_json="{}"
    
    # Fields that need averaging and additional statistics
    local stat_fields=(time req_per_sec mbs req_min req_max req_mean req_sd req_sd_pct conn_min conn_max conn_mean conn_sd conn_sd_pct first_byte_min first_byte_max first_byte_mean first_byte_sd first_byte_sd_pct req_s_min req_s_max req_s_mean req_s_sd req_s_sd_pct)
    
    # Other fields that need averaging
    local avg_fields=(total_req started_req done_req succeeded_req failed_req errored_req timeout_req status_2xx status_3xx status_4xx status_5xx total_traffic header_traffic data_traffic threads connections requests udp_sent udp_received)
    
    # Fields that need reporting (last value)
    local report_fields=(cipher tempkey protocol duration warm_up_time uri)

    # Fields that should not have units added
    local no_unit_fields=(req_per_sec req_s_min req_s_max req_s_mean req_s_sd req_s_sd_pct)
    
    format_number() {
        printf "%.4f" "$1"
    }

    for field in "${stat_fields[@]}" "${avg_fields[@]}"; do
        local values=()
        local sum=0
        local count=0
        local unit=""
        for file in "${json_files[@]}"; do
            value=$(jq -r ".$field" "$file" | sed 's/[^0-9.]//g')
            if [[ -z "$value" || "$value" == "null" ]]; then
                continue
            fi
            if [[ "$field" =~ ^(req_|conn_|first_byte_) && ! " ${no_unit_fields[@]} " =~ " ${field} " ]]; then
                original=$(jq -r ".$field" "$file")
                if [[ "$original" =~ us$ ]]; then
                    value=$(echo "$value / 1000000" | bc -l)
                elif [[ "$original" =~ ms$ ]]; then
                    value=$(echo "$value / 1000" | bc -l)
                fi
                unit="s"
            elif [[ "$field" =~ _traffic$ ]]; then
                unit="KB"
            elif [[ "$field" == "mbs" ]]; then
                unit="MB/s"
            fi
            values+=($value)
            sum=$(echo "$sum + $value" | bc -l)
            count=$((count + 1))
        done
        if [ $count -ne 0 ]; then
            avg=$(format_number $(echo "$sum / $count" | bc -l))
            if [[ " ${stat_fields[@]} " =~ " ${field} " ]]; then
                IFS=$'\n' sorted=($(sort -n <<<"${values[*]}"))
                unset IFS
                min=$(format_number ${sorted[0]})
                max=$(format_number ${sorted[-1]})
                index=$(echo "($count * 0.95) - 1" | bc)
                pc95=$(format_number ${sorted[${index%.*}]})
                if [[ " ${no_unit_fields[@]} " =~ " ${field} " ]]; then
                    avg_json=$(echo "$avg_json" | jq --arg field "$field" --arg min "$min" --arg max "$max" --arg avg "$avg" --arg pc95 "$pc95" \
                        '. + {($field): $avg, ($field + "_min"): $min, ($field + "_max"): $max, ($field + "_95pc"): $pc95}')
                else
                    avg_json=$(echo "$avg_json" | jq --arg field "$field" --arg min "$min" --arg max "$max" --arg avg "$avg" --arg pc95 "$pc95" --arg unit "$unit" \
                        '. + {($field): ($avg + $unit), ($field + "_min"): ($min + $unit), ($field + "_max"): ($max + $unit), ($field + "_95pc"): ($pc95 + $unit)}')
                fi
            else
                if [[ -n "$unit" && ! " ${no_unit_fields[@]} " =~ " ${field} " ]]; then
                    avg_json=$(echo "$avg_json" | jq --arg field "$field" --arg avg "$avg" --arg unit "$unit" '. + {($field): ($avg + $unit)}')
                else
                    avg_json=$(echo "$avg_json" | jq --arg field "$field" --arg avg "$avg" '. + {($field): $avg}')
                fi
            fi
        fi
    done
    
    for field in "${report_fields[@]}"; do
        value=$(jq -r ".$field" "${json_files[-1]}")
        avg_json=$(echo "$avg_json" | jq --arg field "$field" --arg value "$value" '. + {($field): $value}')
    done
    
    echo "$avg_json"
}

json_to_markdown() {
    local json_array="$1"
    local domain_count=$(echo "$json_array" | jq length)
    
    # Create the header based on the number of domains
    local header="| Field"
    for ((i=0; i<$domain_count; i++)); do
        header+=" | ${URI_ARRAY[$i]}"
    done
    header+=" |\n|-------"
    for ((i=0; i<$domain_count; i++)); do
        header+="|-------"
    done
    header+="|\n"
    
    local markdown="$header"
    
    # Get all unique keys from all JSON objects
    local keys
    if [ "$domain_count" -eq 1 ]; then
        keys=$(echo "$json_array" | jq -r '.[0] | keys[]' | sort)
    else
        keys=$(echo "$json_array" | jq -r '.[0] * .[1] | keys[]' | sort)
    fi

    for key in $keys; do
        local row="| $key"
        for ((i=0; i<$domain_count; i++)); do
            local value=$(echo "$json_array" | jq -r ".[$i][\"$key\"] // \"N/A\"")
            row+=" | $value"
        done
        row+=" |\n"
        markdown+="$row"
    done
    
    echo -e "$markdown"
}

run_benchmark() {
    local output_file=$1
    local uri=$2
    local compress_header=""
    
    case "$COMPRESS" in
        gzip)
            compress_header="Accept-Encoding: gzip"
            ;;
        br)
            compress_header="Accept-Encoding: br"
            ;;
        zstd)
            compress_header="Accept-Encoding: zstd"
            ;;
        none)
            compress_header="Accept-Encoding: identity"
            ;;
        *)
            compress_header="Accept-Encoding: $COMPRESS"
            ;;
    esac
    
    if [ -n "$REQ_DURATION" ]; then
        h2load -t$THREADS${HTTP3_OPT} -c$CONNECTIONS -D$REQ_DURATION --warm-up-time=$WARM_UP_TIME -m$MAXCONCURRENT_STREAMS -H "$compress_header" $uri > "$output_file"
    else
        h2load -t$THREADS${HTTP3_OPT} -c$CONNECTIONS -n$REQUESTS -m$MAXCONCURRENT_STREAMS -H "$compress_header" $uri > "$output_file"
    fi
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
            URIS="$2"
            shift 2
            ;;
        -b|--batch)
            BATCH_MODE=1
            shift
            ;;
        -C|--compress)
            COMPRESS="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
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

# Main execution
psrecord_start

IFS=',' read -ra URI_ARRAY <<< "$URIS"
FINAL_JSON_OUTPUT="["

for ((i=0; i<${#URI_ARRAY[@]}; i++)); do
    URI=${URI_ARRAY[$i]}
    echo "Running benchmark for $URI"
    
    if [ $BATCH_MODE -eq 1 ]; then
        batch_results=()
        for j in {1..4}; do
            CURRENT_CONNECTIONS=$(($CONNECTIONS * $j / 4))
            json_outputs=()
            for run in $(seq 1 $BENCHMARK_RUNS); do
                CURRENT_RAW_LOG="${RAW_LOG_PREFIX}-${i}-batch${j}-run${run}.log"
                run_benchmark "$CURRENT_RAW_LOG" "$URI"
                JSON_OUTPUT=$(parse_output_to_json "$CURRENT_RAW_LOG" "$THREADS" "$CURRENT_CONNECTIONS" "$REQ_DURATION" "$WARM_UP_TIME" "$REQUESTS" "$URI")
                echo "$JSON_OUTPUT" > "${STATS_JSON%.json}-${i}-batch${j}-run${run}.json"
                json_outputs+=("${STATS_JSON%.json}-${i}-batch${j}-run${run}.json")
            done
            AVG_JSON_OUTPUT=$(average_results "${json_outputs[@]}")
            echo "$AVG_JSON_OUTPUT" > "${STATS_JSON%.json}-${i}-batch${j}-avg.json"
            batch_results+=("$AVG_JSON_OUTPUT")
        done
        if [ $i -gt 0 ]; then
            FINAL_JSON_OUTPUT="${FINAL_JSON_OUTPUT},"
        fi
        FINAL_JSON_OUTPUT="${FINAL_JSON_OUTPUT}$(jq -s '.' <<< "${batch_results[@]}")"
    else
        json_outputs=()
        for run in $(seq 1 $BENCHMARK_RUNS); do
            RAW_LOG="${RAW_LOG_PREFIX}-${i}-run${run}.log"
            run_benchmark "$RAW_LOG" "$URI"
            JSON_OUTPUT=$(parse_output_to_json "$RAW_LOG" "$THREADS" "$CONNECTIONS" "$REQ_DURATION" "$WARM_UP_TIME" "$REQUESTS" "$URI")
            echo "$JSON_OUTPUT" > "${STATS_JSON%.json}-${i}-run${run}.json"
            json_outputs+=("${STATS_JSON%.json}-${i}-run${run}.json")
        done
        AVG_JSON_OUTPUT=$(average_results "${json_outputs[@]}")
        echo "$AVG_JSON_OUTPUT" > "${STATS_JSON%.json}-${i}-avg.json"
        
        if [ $i -gt 0 ]; then
            FINAL_JSON_OUTPUT="${FINAL_JSON_OUTPUT},"
        fi
        FINAL_JSON_OUTPUT="${FINAL_JSON_OUTPUT}${AVG_JSON_OUTPUT}"
    fi
done

FINAL_JSON_OUTPUT="${FINAL_JSON_OUTPUT}]"
echo "$FINAL_JSON_OUTPUT" > "$STATS_JSON"

if [ "$FORMAT" = "markdown" ]; then
    json_to_markdown "$FINAL_JSON_OUTPUT"
else
    echo "$FINAL_JSON_OUTPUT"
fi

psrecord_end