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
  "time": "40.63ms,",
  "req_per_sec": "2461.42",
  "mbs": "4.78MB/s",
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
  "req_min": "11.06ms",
  "req_max": "27.48ms",
  "req_mean": "18.62ms",
  "req_sd": "4.45ms",
  "req_sd_pct": "67.00%",
  "conn_min": "1.46ms",
  "conn_max": "27.61ms",
  "conn_mean": "7.79ms",
  "conn_sd": "7.46ms",
  "conn_sd_pct": "90.00%",
  "first_byte_min": "25.57ms",
  "first_byte_max": "38.68ms",
  "first_byte_mean": "30.06ms",
  "first_byte_sd": "4.82ms",
  "first_byte_sd_pct": "93",
  "req_s_min": "246.87",
  "req_s_max": "385.75",
  "req_s_mean": "327.49",
  "req_s_sd": "54.15",
  "req_s_sd_pct": "54.15",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2"
}
```

```
cat h2load-logs/h2load-raw-20230513235516.log

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

finished in 40.63ms, 2461.42 req/s, 4.78MB/s
requests: 100 total, 100 started, 100 done, 100 succeeded, 0 failed, 0 errored, 0 timeout
status codes: 100 2xx, 0 3xx, 0 4xx, 0 5xx
traffic: 198.92KB (203690) total, 20.21KB (20700) headers (space savings 26.33%), 176.46KB (180700) data
                     min         max         mean         sd        +/- sd
time for request:    11.06ms     27.48ms     18.62ms      4.45ms    67.00%
time for connect:     1.46ms     27.61ms      7.79ms      7.46ms    90.00%
time to 1st byte:    25.57ms     38.68ms     30.06ms      4.82ms    80.00%
req/s           :     246.87      385.75      327.49       54.15    60.00%
```