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

```
./h2load-bench.sh -t 1 -c 10 -n 100 -u https://domain.com | jq
{
  "time": "28.00ms,",
  "req_per_sec": "3571.56",
  "mbs": "6.94MB/s",
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
  "req_min": "1.44ms",
  "req_max": "9.98ms",
  "req_mean": "6.00ms",
  "req_sd": "1.99ms",
  "req_sd_pct": "64.00%",
  "conn_min": "1.29ms",
  "conn_max": "9.41ms",
  "conn_mean": "5.32ms",
  "conn_sd": "2.72ms",
  "conn_sd_pct": "60.00%",
  "first_byte_min": "17.14ms",
  "first_byte_max": "25.78ms",
  "first_byte_mean": "20.97ms",
  "first_byte_sd": "3.19ms",
  "first_byte_sd_pct": "93",
  "req_s_min": "360.02",
  "req_s_max": "578.79",
  "req_s_mean": "464.86",
  "req_s_sd": "78.81",
  "req_s_sd_pct": "78.81"
}
```

```
cat h2load-logs/h2load-raw-20230513233833.log
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

finished in 28.00ms, 3571.56 req/s, 6.94MB/s
requests: 100 total, 100 started, 100 done, 100 succeeded, 0 failed, 0 errored, 0 timeout
status codes: 100 2xx, 0 3xx, 0 4xx, 0 5xx
traffic: 198.92KB (203690) total, 20.21KB (20700) headers (space savings 26.33%), 176.46KB (180700) data
                     min         max         mean         sd        +/- sd
time for request:     1.44ms      9.98ms      6.00ms      1.99ms    64.00%
time for connect:     1.29ms      9.41ms      5.32ms      2.72ms    60.00%
time to 1st byte:    17.14ms     25.78ms     20.97ms      3.19ms    50.00%
req/s           :     360.02      578.79      464.86       78.81    60.00%
```