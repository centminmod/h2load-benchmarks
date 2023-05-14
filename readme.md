![GitHub last commit](https://img.shields.io/github/last-commit/centminmod/h2load-benchmarks) ![GitHub contributors](https://img.shields.io/github/contributors/centminmod/h2load-benchmarks) ![GitHub Repo stars](https://img.shields.io/github/stars/centminmod/h2load-benchmarks) ![GitHub watchers](https://img.shields.io/github/watchers/centminmod/h2load-benchmarks) ![GitHub Sponsors](https://img.shields.io/github/sponsors/centminmod) ![GitHub top language](https://img.shields.io/github/languages/top/centminmod/h2load-benchmarks) ![GitHub language count](https://img.shields.io/github/languages/count/centminmod/h2load-benchmarks)

```
./h2load-bench.sh 
Usage: ./h2load-bench.sh [-t threads] [-c connections] [-n requests] [-D duration] [-w warm-up] [-u uri]

Options:
  -t, --threads       Number of threads
  -c, --connections   Number of connections
  -n, --requests      Number of requests
  -D, --duration      Duration of the benchmark
  -w, --warm-up       Warm-up time before the benchmark
  -u, --uri           URI to request
  -h, --help          Display this help message
```

JSON parsed

```
./h2load-bench.sh -t 1 -c 10 -n 100 -u https://domain.com | jq
{
  "time": "23.16ms",
  "req_per_sec": "4317.60",
  "mbs": "8.39MB/s",
  "total_req": "100",
  "started_req": "100",
  "done_req": "100",
  "succeeded_req": "100",
  "failed_req": "0",
  "errored_req": "0",
  "timeout_req": "0",
  "status_2xx": "100",
  "status_3xx": "0",
  "status_4xx": "0",
  "status_5xx": "0",
  "total_traffic": "198.92KB",
  "header_traffic": "20.21KB",
  "data_traffic": "176.46KB",
  "req_min": "1.80ms",
  "req_max": "15.40ms",
  "req_mean": "9.63ms",
  "req_sd": "4.55ms",
  "req_sd_pct": "50.00%",
  "conn_min": "1.38ms",
  "conn_max": "20.70ms",
  "conn_mean": "7.15ms",
  "conn_sd": "6.15ms",
  "conn_sd_pct": "90.00%",
  "first_byte_min": "20.36ms",
  "first_byte_max": "22.51ms",
  "first_byte_mean": "21.37ms",
  "first_byte_sd": "716us",
  "first_byte_sd_pct": "60.00%",
  "req_s_min": "436.48",
  "req_s_max": "488.21",
  "req_s_mean": "464.66",
  "req_s_sd": "16.45",
  "req_s_sd_pct": "16.45",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2"
}
```

JSON parsed reduced array fields

```
cat h2load-logs/h2load-stats-20230514003924.json | jq -r '{
  "req_per_sec": .req_per_sec,
  "success_percentage": (100 * (.succeeded_req | tonumber) / (.total_req | tonumber)),
  "req_min": .req_min,
  "req_mean": .req_mean,
  "req_max": .req_max,
  "conn_min": .conn_min,
  "conn_mean": .conn_mean,
  "conn_max": .conn_max,
  "first_byte_min": .first_byte_min,
  "first_byte_mean": .first_byte_mean,
  "first_byte_max": .first_byte_max,
  "req_s_min": .req_s_min,
  "req_s_mean": .req_s_mean,
  "req_s_max": .req_s_max
}'

{
  "req_per_sec": "4317.60",
  "success_percentage": 100,
  "req_min": "1.80ms",
  "req_mean": "9.63ms",
  "req_max": "15.40ms",
  "conn_min": "1.38ms",
  "conn_mean": "7.15ms",
  "conn_max": "20.70ms",
  "first_byte_min": "20.36ms",
  "first_byte_mean": "21.37ms",
  "first_byte_max": "22.51ms",
  "req_s_min": "436.48",
  "req_s_mean": "464.66",
  "req_s_max": "488.21"
}
```

Raw log

```
cat h2load-logs/h2load-raw-20230514003924.log

starting benchmark...
spawning thread #0: 10 total client(s). 100 total requests
TLS Protocol: TLSv1.3
Cipher: TLS_AES_256_GCM_SHA384
Server Temp Key: X25519 253 bits
Application protocol: h2
progress: 10% done
progress: 20% done
progress: 30% done
progress: 40% done
progress: 50% done
progress: 60% done
progress: 70% done
progress: 80% done
progress: 90% done
progress: 100% done

finished in 23.16ms, 4317.60 req/s, 8.39MB/s
requests: 100 total, 100 started, 100 done, 100 succeeded, 0 failed, 0 errored, 0 timeout
status codes: 100 2xx, 0 3xx, 0 4xx, 0 5xx
traffic: 198.92KB (203690) total, 20.21KB (20700) headers (space savings 26.33%), 176.46KB (180700) data
                     min         max         mean         sd        +/- sd
time for request:     1.80ms     15.40ms      9.63ms      4.55ms    50.00%
time for connect:     1.38ms     20.70ms      7.15ms      6.15ms    90.00%
time to 1st byte:    20.36ms     22.51ms     21.37ms       716us    60.00%
req/s           :     436.48      488.21      464.66       16.45    60.00%
```