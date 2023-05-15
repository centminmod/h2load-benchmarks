![GitHub last commit](https://img.shields.io/github/last-commit/centminmod/h2load-benchmarks) ![GitHub contributors](https://img.shields.io/github/contributors/centminmod/h2load-benchmarks) ![GitHub Repo stars](https://img.shields.io/github/stars/centminmod/h2load-benchmarks) ![GitHub watchers](https://img.shields.io/github/watchers/centminmod/h2load-benchmarks) ![GitHub Sponsors](https://img.shields.io/github/sponsors/centminmod) ![GitHub top language](https://img.shields.io/github/languages/top/centminmod/h2load-benchmarks) ![GitHub language count](https://img.shields.io/github/languages/count/centminmod/h2load-benchmarks)

# Requirements

```
yum -y install nghttp2 gnuplot jq
```

# Usage

Includes a [Batch Mode](#batch-mode) with charting support.

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

# Batch Mode

`-b` batch mode will take the connections value `-c 200` and divide it into 4 quarters for 4 `h2load` runs incrementing the by each quarter so `-c 50`, `-c 100`, `-c 150`, `-c 200`.

```
./h2load-bench.sh -t 1 -c 400 -n 10000 -b -u https://domain.com | jq
{
  "time": "1.09s",
  "req_per_sec": "9165.04",
  "mbs": "17.76MB/s",
  "total_req": "10000",
  "started_req": "10000",
  "done_req": "10000",
  "succeeded_req": "10000",
  "failed_req": "0",
  "errored_req": "0",
  "timeout_req": "0",
  "status_2xx": "10000",
  "status_3xx": "0",
  "status_4xx": "0",
  "status_5xx": "0",
  "total_traffic": "19.37MB",
  "header_traffic": "1.96MB",
  "data_traffic": "17.23MB",
  "req_min": "23.13",
  "req_max": "450.53",
  "req_mean": "263.59",
  "req_sd": "89.85ms",
  "req_sd_pct": "66.37%",
  "conn_min": "2.44",
  "conn_max": "350.00",
  "conn_mean": "170.02",
  "conn_sd": "115.06ms",
  "conn_sd_pct": "62.00%",
  "first_byte_min": "225.98",
  "first_byte_max": "645.23",
  "first_byte_mean": "470.97",
  "first_byte_sd": "147.48ms",
  "first_byte_sd_pct": "52.00%",
  "req_s_min": "91.85",
  "req_s_max": "95.19",
  "req_s_mean": "92.75",
  "req_s_sd": "1.06",
  "req_s_sd_pct": "1.06",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "100",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "10000"
}
{
  "time": "1.24s",
  "req_per_sec": "8057.98",
  "mbs": "15.62MB/s",
  "total_req": "10000",
  "started_req": "10000",
  "done_req": "10000",
  "succeeded_req": "10000",
  "failed_req": "0",
  "errored_req": "0",
  "timeout_req": "0",
  "status_2xx": "10000",
  "status_3xx": "0",
  "status_4xx": "0",
  "status_5xx": "0",
  "total_traffic": "19.38MB",
  "header_traffic": "1.96MB",
  "data_traffic": "17.23MB",
  "req_min": "6.50",
  "req_max": "636.99",
  "req_mean": "438.00",
  "req_sd": "172.99ms",
  "req_sd_pct": "61.55%",
  "conn_min": "5.62",
  "conn_max": "1080",
  "conn_mean": "293.98",
  "conn_sd": "254.28ms",
  "conn_sd_pct": "60.00%",
  "first_byte_min": "686.81",
  "first_byte_max": "1180",
  "first_byte_mean": "906.66",
  "first_byte_sd": "121.46ms",
  "first_byte_sd_pct": "71.50%",
  "req_s_min": "40.52",
  "req_s_max": "45.34",
  "req_s_mean": "43.31",
  "req_s_sd": "1.07",
  "req_s_sd_pct": "1.07",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "200",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "10000"
}
{
  "time": "1.17s",
  "req_per_sec": "8532.37",
  "mbs": "16.54MB/s",
  "total_req": "10000",
  "started_req": "10000",
  "done_req": "10000",
  "succeeded_req": "10000",
  "failed_req": "0",
  "errored_req": "0",
  "timeout_req": "0",
  "status_2xx": "10000",
  "status_3xx": "0",
  "status_4xx": "0",
  "status_5xx": "0",
  "total_traffic": "19.38MB",
  "header_traffic": "1.96MB",
  "data_traffic": "17.23MB",
  "req_min": "11.71",
  "req_max": "992.65",
  "req_mean": "479.59",
  "req_sd": "225.89ms",
  "req_sd_pct": "67.71%",
  "conn_min": "13.03",
  "conn_max": "993.82",
  "conn_mean": "345.54",
  "conn_sd": "352.23ms",
  "conn_sd_pct": "78.00%",
  "first_byte_min": "342.87",
  "first_byte_max": "1140",
  "first_byte_mean": "830.06",
  "first_byte_sd": "285.88ms",
  "first_byte_sd_pct": "74.67%",
  "req_s_min": "28.47",
  "req_s_max": "32.22",
  "req_s_mean": "29.97",
  "req_s_sd": "1.21",
  "req_s_sd_pct": "1.21",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "300",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "10000"
}
{
  "time": "1.56s",
  "req_per_sec": "6397.04",
  "mbs": "12.40MB/s",
  "total_req": "10000",
  "started_req": "10000",
  "done_req": "10000",
  "succeeded_req": "10000",
  "failed_req": "0",
  "errored_req": "0",
  "timeout_req": "0",
  "status_2xx": "10000",
  "status_3xx": "0",
  "status_4xx": "0",
  "status_5xx": "0",
  "total_traffic": "19.39MB",
  "header_traffic": "1.96MB",
  "data_traffic": "17.23MB",
  "req_min": "73.40",
  "req_max": "1110",
  "req_mean": "582.73",
  "req_sd": "306.33ms",
  "req_sd_pct": "54.50%",
  "conn_min": "15.32",
  "conn_max": "1400",
  "conn_mean": "623.92",
  "conn_sd": "405.47ms",
  "conn_sd_pct": "58.50%",
  "first_byte_min": "266.48",
  "first_byte_max": "1560",
  "first_byte_mean": "1300",
  "first_byte_sd": "413.59ms",
  "first_byte_sd_pct": "86.00%",
  "req_s_min": "16.04",
  "req_s_max": "93.74",
  "req_s_mean": "27.32",
  "req_s_sd": "25.37",
  "req_s_sd_pct": "25.37",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "1",
  "connections": "400",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "10000"
}
```

Then run `h2load-plot.gnuplot` to generate chart `output.png`, `output-avg.png` and `output-max.png`

```
./h2load-plot.gnuplot
```

`output.png`

![h2load batch benchmark chart](charts/output.png "h2load batch benchmark chart")

`output-avg.png`

![h2load batch benchmark chart - avg response time](charts/output-avg.png "h2load batch benchmark chart - avg response time")

`output-max.png`

![h2load batch benchmark chart - max response time](charts/output-max.png "h2load batch benchmark chart - max response time")

