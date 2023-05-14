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

`-b` batch mode will take the connections value `-c 200` and divide it into 4 quarters for 4 `h2load` runs incrementing the by each quarter so `-c 50`, `-c 100`, `-c 150`, `-c 200`.

```
./h2load-bench.sh -t 1 -c 200 -n 5000 -b -u https://domain.com | jq
{
  "time": "579.35ms",
  "req_per_sec": "8630.32",
  "mbs": "16.72MB/s",
  "total_req": "5000",
  "started_req": "5000",
  "done_req": "5000",
  "succeeded_req": "5000",
  "failed_req": "0",
  "errored_req": "0",
  "timeout_req": "0",
  "status_2xx": "5000",
  "status_3xx": "0",
  "status_4xx": "0",
  "status_5xx": "0",
  "total_traffic": "9.69MB",
  "header_traffic": "1005.86KB",
  "data_traffic": "8.62MB",
  "req_min": "1.63ms",
  "req_max": "266.78ms",
  "req_mean": "126.42ms",
  "req_sd": "64.60ms",
  "req_sd_pct": "59.42%",
  "conn_min": "1.82ms",
  "conn_max": "79.92ms",
  "conn_mean": "39.90ms",
  "conn_sd": "28.02ms",
  "conn_sd_pct": "56.00%",
  "first_byte_min": "77.77ms",
  "first_byte_max": "289.59ms",
  "first_byte_mean": "206.96ms",
  "first_byte_sd": "90.70ms",
  "first_byte_sd_pct": "68.00%",
  "req_s_min": "173.07",
  "req_s_max": "238.71",
  "req_s_mean": "197.23",
  "req_s_sd": "24.47",
  "req_s_sd_pct": "24.47",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "50",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "5000"
}
{
  "time": "606.02ms",
  "req_per_sec": "8250.51",
  "mbs": "15.99MB/s",
  "total_req": "5000",
  "started_req": "5000",
  "done_req": "5000",
  "succeeded_req": "5000",
  "failed_req": "0",
  "errored_req": "0",
  "timeout_req": "0",
  "status_2xx": "5000",
  "status_3xx": "0",
  "status_4xx": "0",
  "status_5xx": "0",
  "total_traffic": "9.69MB",
  "header_traffic": "1005.86KB",
  "data_traffic": "8.62MB",
  "req_min": "8.13ms",
  "req_max": "482.92ms",
  "req_mean": "206.28ms",
  "req_sd": "103.64ms",
  "req_sd_pct": "72.92%",
  "conn_min": "6.38ms",
  "conn_max": "367.57ms",
  "conn_mean": "88.53ms",
  "conn_sd": "127.52ms",
  "conn_sd_pct": "80.00%",
  "first_byte_min": "22.05ms",
  "first_byte_max": "517.59ms",
  "first_byte_mean": "291.65ms",
  "first_byte_sd": "152.24ms",
  "first_byte_sd_pct": "65.00%",
  "req_s_min": "82.93",
  "req_s_max": "176.05",
  "req_s_mean": "101.56",
  "req_s_sd": "13.18",
  "req_s_sd_pct": "13.18",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "100",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "5000"
}
{
  "time": "648.79ms",
  "req_per_sec": "7706.62",
  "mbs": "14.94MB/s",
  "total_req": "5000",
  "started_req": "5000",
  "done_req": "5000",
  "succeeded_req": "5000",
  "failed_req": "0",
  "errored_req": "0",
  "timeout_req": "0",
  "status_2xx": "5000",
  "status_3xx": "0",
  "status_4xx": "0",
  "status_5xx": "0",
  "total_traffic": "9.69MB",
  "header_traffic": "1005.86KB",
  "data_traffic": "8.62MB",
  "req_min": "5.96ms",
  "req_max": "501.82ms",
  "req_mean": "230.13ms",
  "req_sd": "113.57ms",
  "req_sd_pct": "61.78%",
  "conn_min": "11.52ms",
  "conn_max": "465.90ms",
  "conn_mean": "201.58ms",
  "conn_sd": "167.95ms",
  "conn_sd_pct": "55.33%",
  "first_byte_min": "55.12ms",
  "first_byte_max": "622.59ms",
  "first_byte_mean": "431.24ms",
  "first_byte_sd": "169.49ms",
  "first_byte_sd_pct": "79.33%",
  "req_s_min": "51.32",
  "req_s_max": "118.51",
  "req_s_mean": "58.81",
  "req_s_sd": "11.88",
  "req_s_sd_pct": "11.88",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "150",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "5000"
}
{
  "time": "679.84ms",
  "req_per_sec": "7354.65",
  "mbs": "14.26MB/s",
  "total_req": "5000",
  "started_req": "5000",
  "done_req": "5000",
  "succeeded_req": "5000",
  "failed_req": "0",
  "errored_req": "0",
  "timeout_req": "0",
  "status_2xx": "5000",
  "status_3xx": "0",
  "status_4xx": "0",
  "status_5xx": "0",
  "total_traffic": "9.69MB",
  "header_traffic": "1005.86KB",
  "data_traffic": "8.62MB",
  "req_min": "65.45ms",
  "req_max": "574.53ms",
  "req_mean": "327.92ms",
  "req_sd": "143.53ms",
  "req_sd_pct": "44.50%",
  "conn_min": "17.09ms",
  "conn_max": "535.81ms",
  "conn_mean": "63.13ms",
  "conn_sd": "64.57ms",
  "conn_sd_pct": "97.00%",
  "first_byte_min": "82.61ms",
  "first_byte_max": "667.70ms",
  "first_byte_mean": "388.37ms",
  "first_byte_sd": "156.98ms",
  "first_byte_sd_pct": "48.00%",
  "req_s_min": "37.12",
  "req_s_max": "301.78",
  "req_s_mean": "77.30",
  "req_s_sd": "39.89",
  "req_s_sd_pct": "39.89",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "200",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "5000"
}
```

Then run `h2load-plot.gnuplot` to generate chart `output.png`

```
./h2load-plot.gnuplot
```

![h2load batch benchmark chart](charts/output.png "h2load batch benchmark chart")