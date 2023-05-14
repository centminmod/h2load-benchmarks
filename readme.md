![GitHub last commit](https://img.shields.io/github/last-commit/centminmod/h2load-benchmarks) ![GitHub contributors](https://img.shields.io/github/contributors/centminmod/h2load-benchmarks) ![GitHub Repo stars](https://img.shields.io/github/stars/centminmod/h2load-benchmarks) ![GitHub watchers](https://img.shields.io/github/watchers/centminmod/h2load-benchmarks) ![GitHub Sponsors](https://img.shields.io/github/sponsors/centminmod) ![GitHub top language](https://img.shields.io/github/languages/top/centminmod/h2load-benchmarks) ![GitHub language count](https://img.shields.io/github/languages/count/centminmod/h2load-benchmarks)

```
./h2load-bench.sh 
Usage: ./h2load-bench.sh [-t threads] [-c connections] [-n requests] [-D duration] [-w warm-up] [-u uri] [-b batch]

Options:
  -t, --threads       Number of threads
  -c, --connections   Number of connections
  -n, --requests      Number of requests
  -D, --duration      Duration of the benchmark
  -w, --warm-up       Warm-up time before the benchmark
  -u, --uri           URI to request
  -b, --batch         Enable batch mode
  -h, --help          Display this help message
```

JSON parsed

```
./h2load-bench.sh -t 1 -c 10 -n 100 -u https://domain.com | jq
{
  "time": "38.44ms",
  "req_per_sec": "2601.59",
  "mbs": "5.05MB/s",
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
  "req_min": "1.70ms",
  "req_max": "13.72ms",
  "req_mean": "8.74ms",
  "req_sd": "2.81ms",
  "req_sd_pct": "69.00%",
  "conn_min": "1.55ms",
  "conn_max": "12.47ms",
  "conn_mean": "7.50ms",
  "conn_sd": "3.50ms",
  "conn_sd_pct": "60.00%",
  "first_byte_min": "25.43ms",
  "first_byte_max": "35.52ms",
  "first_byte_mean": "30.03ms",
  "first_byte_sd": "4.73ms",
  "first_byte_sd_pct": "60.00%",
  "req_s_min": "280.64",
  "req_s_max": "390.65",
  "req_s_mean": "329.72",
  "req_s_sd": "51.35",
  "req_s_sd_pct": "51.35",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "10",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "100"
}
```

JSON parsed reduced array fields

```
cat h2load-logs/h2load-stats-20230514034938.json | jq -r '{
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
  "req_s_max": .req_s_max,
  "threads": .threads,
  "connections": .connections,
  "duration": .duration,
  "warm_up_time": .warm_up_time,
  "requests": .requests
}'

{
  "req_per_sec": "2601.59",
  "success_percentage": 100,
  "req_min": "1.70ms",
  "req_mean": "8.74ms",
  "req_max": "13.72ms",
  "conn_min": "1.55ms",
  "conn_mean": "7.50ms",
  "conn_max": "12.47ms",
  "first_byte_min": "25.43ms",
  "first_byte_mean": "30.03ms",
  "first_byte_max": "35.52ms",
  "req_s_min": "280.64",
  "req_s_mean": "329.72",
  "req_s_max": "390.65",
  "threads": "1",
  "connections": "10",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "100"
}
```

Raw log

```
cat h2load-logs/h2load-raw-20230514034938.log

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

finished in 38.44ms, 2601.59 req/s, 5.05MB/s
requests: 100 total, 100 started, 100 done, 100 succeeded, 0 failed, 0 errored, 0 timeout
status codes: 100 2xx, 0 3xx, 0 4xx, 0 5xx
traffic: 198.92KB (203690) total, 20.21KB (20700) headers (space savings 26.33%), 176.46KB (180700) data
                     min         max         mean         sd        +/- sd
time for request:     1.70ms     13.72ms      8.74ms      2.81ms    69.00%
time for connect:     1.55ms     12.47ms      7.50ms      3.50ms    60.00%
time to 1st byte:    25.43ms     35.52ms     30.03ms      4.73ms    60.00%
req/s           :     280.64      390.65      329.72       51.35    70.00%
```

`-b` batch mode will take the connections value `-c 100` and divide it into 4 quarters for 4 `h2load` runs incrementing the by each quarter so `-c 25`, `-c 50`, `-c 75`, `-c 100`.

```
./h2load-bench.sh -t 1 -c 100 -n 100 -b -u https://domain.com | jq
{
  "time": "29.23ms",
  "req_per_sec": "3421.14",
  "mbs": "6.67MB/s",
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
  "total_traffic": "199.54KB",
  "header_traffic": "20.12KB",
  "data_traffic": "176.46KB",
  "req_min": "2.02ms",
  "req_max": "20.49ms",
  "req_mean": "12.82ms",
  "req_sd": "5.36ms",
  "req_sd_pct": "74.00%",
  "conn_min": "2.29ms",
  "conn_max": "12.94ms",
  "conn_mean": "8.26ms",
  "conn_sd": "3.91ms",
  "conn_sd_pct": "60.00%",
  "first_byte_min": "4.63ms",
  "first_byte_max": "28.97ms",
  "first_byte_mean": "20.91ms",
  "first_byte_sd": "9.22ms",
  "first_byte_sd_pct": "80.00%",
  "req_s_min": "137.82",
  "req_s_max": "852.87",
  "req_s_mean": "254.77",
  "req_s_sd": "195.35",
  "req_s_sd_pct": "195.35",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "25",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "100"
}
{
  "time": "43.77ms",
  "req_per_sec": "2284.46",
  "mbs": "4.48MB/s",
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
  "total_traffic": "200.73KB",
  "header_traffic": "20.12KB",
  "data_traffic": "176.46KB",
  "req_min": "6.04ms",
  "req_max": "25.54ms",
  "req_mean": "12.19ms",
  "req_sd": "6.05ms",
  "req_sd_pct": "80.00%",
  "conn_min": "1.02ms",
  "conn_max": "35.02ms",
  "conn_mean": "20.63ms",
  "conn_sd": "11.49ms",
  "conn_sd_pct": "54.00%",
  "first_byte_min": "18.46ms",
  "first_byte_max": "42.55ms",
  "first_byte_mean": "33.73ms",
  "first_byte_sd": "8.65ms",
  "first_byte_sd_pct": "70.00%",
  "req_s_min": "46.98",
  "req_s_max": "108.10",
  "req_s_mean": "64.84",
  "req_s_sd": "22.75",
  "req_s_sd_pct": "22.75",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "50",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "100"
}
{
  "time": "59.83ms",
  "req_per_sec": "1671.32",
  "mbs": "3.30MB/s",
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
  "total_traffic": "201.93KB",
  "header_traffic": "20.12KB",
  "data_traffic": "176.46KB",
  "req_min": "8.32ms",
  "req_max": "33.61ms",
  "req_mean": "22.43ms",
  "req_sd": "8.11ms",
  "req_sd_pct": "50.00%",
  "conn_min": "1.34ms",
  "conn_max": "48.24ms",
  "conn_mean": "30.81ms",
  "conn_sd": "11.82ms",
  "conn_sd_pct": "62.67%",
  "first_byte_min": "17.70ms",
  "first_byte_max": "56.59ms",
  "first_byte_mean": "52.04ms",
  "first_byte_sd": "7.42ms",
  "first_byte_sd_pct": "96.00%",
  "req_s_min": "17.65",
  "req_s_max": "56.39",
  "req_s_mean": "26.49",
  "req_s_sd": "10.84",
  "req_s_sd_pct": "10.84",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "75",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "100"
}
{
  "time": "76.82ms",
  "req_per_sec": "1301.73",
  "mbs": "2.58MB/s",
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
  "total_traffic": "203.13KB",
  "header_traffic": "20.12KB",
  "data_traffic": "176.46KB",
  "req_min": "7.67ms",
  "req_max": "39.63ms",
  "req_mean": "22.28ms",
  "req_sd": "11.01ms",
  "req_sd_pct": "57.00%",
  "conn_min": "2.44ms",
  "conn_max": "64.84ms",
  "conn_mean": "39.49ms",
  "conn_sd": "18.11ms",
  "conn_sd_pct": "64.00%",
  "first_byte_min": "51.88ms",
  "first_byte_max": "74.22ms",
  "first_byte_mean": "66.13ms",
  "first_byte_sd": "6.87ms",
  "first_byte_sd_pct": "71.00%",
  "req_s_min": "13.47",
  "req_s_max": "19.26",
  "req_s_mean": "15.30",
  "req_s_sd": "1.82",
  "req_s_sd_pct": "1.82",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "100",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "100"
}
```