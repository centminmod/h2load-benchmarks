![GitHub last commit](https://img.shields.io/github/last-commit/centminmod/h2load-benchmarks) ![GitHub contributors](https://img.shields.io/github/contributors/centminmod/h2load-benchmarks) ![GitHub Repo stars](https://img.shields.io/github/stars/centminmod/h2load-benchmarks) ![GitHub watchers](https://img.shields.io/github/watchers/centminmod/h2load-benchmarks) ![GitHub Sponsors](https://img.shields.io/github/sponsors/centminmod) ![GitHub top language](https://img.shields.io/github/languages/top/centminmod/h2load-benchmarks) ![GitHub language count](https://img.shields.io/github/languages/count/centminmod/h2load-benchmarks)

# Requirements

```
yum -y install nghttp2 gnuplot jq
```

# Usage

Includes a [Batch Mode](#batch-mode) with charting support. Example charting for:

* [VPS benchmarks](#batch-mode-vps) 
* [Dedicated server benchmarks](#batch-mode-dedicated-server).
* [Comparison Charts](#comparison-charts)

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

`-b` batch mode will take the connections value `-c 400` and divide it into 4 quarters for 4 `h2load` runs incrementing the by each quarter so `-c 100`, `-c 200`, `-c 300`, `-c 400`.

## Batch Mode VPS

Run on 2 CPU KVM VPS with 2GB memory, 50GB NVMe disk.

```
lscpu
Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              2
On-line CPU(s) list: 0,1
Thread(s) per core:  1
Core(s) per socket:  1
Socket(s):           2
NUMA node(s):        1
Vendor ID:           GenuineIntel
BIOS Vendor ID:      Red Hat
CPU family:          6
Model:               158
Model name:          Intel(R) Xeon(R) E-2286G CPU @ 4.00GHz
BIOS Model name:     RHEL 7.6.0 PC (i440FX + PIIX, 1996)
Stepping:            10
CPU MHz:             4008.000
BogoMIPS:            8016.00
Hypervisor vendor:   KVM
Virtualization type: full
L1d cache:           32K
L1i cache:           32K
L2 cache:            4096K
L3 cache:            16384K
NUMA node0 CPU(s):   0,1
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_good nopl xtopology cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti ssbd ibrs ibpb stibp fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt xsaveopt xsavec xgetbv1 arat md_clear
```

Run `h2load-bench.sh` wrapper script with h2load with 1 thread `-t 1`.

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

## Batch Mode Dedicated Server

Run on dedicated server Intel Xeon E-2276G 6 cores / 12 threads with 32GB memory, 2x960GB NVMe raid 1.

```
lscpu
Architecture:        x86_64
CPU op-mode(s):      32-bit, 64-bit
Byte Order:          Little Endian
CPU(s):              12
On-line CPU(s) list: 0-11
Thread(s) per core:  2
Core(s) per socket:  6
Socket(s):           1
NUMA node(s):        1
Vendor ID:           GenuineIntel
BIOS Vendor ID:      Intel(R) Corporation
CPU family:          6
Model:               158
Model name:          Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
BIOS Model name:     Intel(R) Xeon(R) E-2276G CPU @ 3.80GHz
Stepping:            10
CPU MHz:             3800.000
CPU max MHz:         4900.0000
CPU min MHz:         800.0000
BogoMIPS:            7584.00
Virtualization:      VT-x
L1d cache:           32K
L1i cache:           32K
L2 cache:            256K
L3 cache:            12288K
NUMA node0 CPU(s):   0-11
Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp md_clear flush_l1d arch_capabilities
```

Run `h2load-bench.sh` wrapper script with h2load with 1 thread `-t 1`.

```
./h2load-bench.sh -t 3 -c 400 -n 10000 -b -u https://domain.com | jq
{
  "time": "232.01ms",
  "req_per_sec": "43100.85",
  "mbs": "93.12MB/s",
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
  "total_traffic": "21.61MB",
  "header_traffic": "1.97MB",
  "data_traffic": "19.45MB",
  "req_min": "0.26",
  "req_max": "101.58",
  "req_mean": "49.10",
  "req_sd": "21.76ms",
  "req_sd_pct": "61.35%",
  "conn_min": "3.41",
  "conn_max": "57.55",
  "conn_mean": "13.98",
  "conn_sd": "8.60ms",
  "conn_sd_pct": "86.00%",
  "first_byte_min": "18.64",
  "first_byte_max": "127.35",
  "first_byte_mean": "47.10",
  "first_byte_sd": "22.96ms",
  "first_byte_sd_pct": "63.00%",
  "req_s_min": "424.95",
  "req_s_max": "1345.96",
  "req_s_mean": "563.78",
  "req_s_sd": "225.18",
  "req_s_sd_pct": "225.18",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "3",
  "connections": "100",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "10000"
}
{
  "time": "221.05ms",
  "req_per_sec": "45238.43",
  "mbs": "97.76MB/s",
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
  "total_traffic": "21.61MB",
  "header_traffic": "1.97MB",
  "data_traffic": "19.45MB",
  "req_min": "0.503",
  "req_max": "138.31",
  "req_mean": "65.04",
  "req_sd": "28.23ms",
  "req_sd_pct": "61.28%",
  "conn_min": "3.90",
  "conn_max": "132.27",
  "conn_mean": "26.85",
  "conn_sd": "18.40ms",
  "conn_sd_pct": "92.50%",
  "first_byte_min": "35.87",
  "first_byte_max": "197.16",
  "first_byte_mean": "82.18",
  "first_byte_sd": "37.62ms",
  "first_byte_sd_pct": "63.50%",
  "req_s_min": "226.51",
  "req_s_max": "1043.53",
  "req_s_mean": "319.90",
  "req_s_sd": "92.43",
  "req_s_sd_pct": "92.43",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "3",
  "connections": "200",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "10000"
}
{
  "time": "238.45ms",
  "req_per_sec": "41937.86",
  "mbs": "90.65MB/s",
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
  "total_traffic": "21.61MB",
  "header_traffic": "1.97MB",
  "data_traffic": "19.45MB",
  "req_min": "0.577",
  "req_max": "116.77",
  "req_mean": "53.87",
  "req_sd": "21.94ms",
  "req_sd_pct": "63.34%",
  "conn_min": "20.56",
  "conn_max": "165.39",
  "conn_mean": "73.63",
  "conn_sd": "43.30ms",
  "conn_sd_pct": "61.67%",
  "first_byte_min": "58.70",
  "first_byte_max": "220.93",
  "first_byte_mean": "126.92",
  "first_byte_sd": "47.64ms",
  "first_byte_sd_pct": "57.67%",
  "req_s_min": "140.89",
  "req_s_max": "275.23",
  "req_s_mean": "193.71",
  "req_s_sd": "34.96",
  "req_s_sd_pct": "34.96",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "3",
  "connections": "300",
  "duration": "null",
  "warm_up_time": "null",
  "requests": "10000"
}
{
  "time": "253.56ms",
  "req_per_sec": "39439.02",
  "mbs": "85.26MB/s",
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
  "total_traffic": "21.62MB",
  "header_traffic": "1.97MB",
  "data_traffic": "19.45MB",
  "req_min": "12.21",
  "req_max": "118.32",
  "req_mean": "53.53",
  "req_sd": "22.87ms",
  "req_sd_pct": "70.19%",
  "conn_min": "15.00",
  "conn_max": "166.24",
  "conn_mean": "76.29",
  "conn_sd": "39.52ms",
  "conn_sd_pct": "59.25%",
  "first_byte_min": "57.12",
  "first_byte_max": "250.64",
  "first_byte_mean": "129.16",
  "first_byte_sd": "52.36ms",
  "first_byte_sd_pct": "55.50%",
  "req_s_min": "99.58",
  "req_s_max": "435.06",
  "req_s_mean": "226.64",
  "req_s_sd": "97.16",
  "req_s_sd_pct": "97.16",
  "cipher": "TLS_AES_256_GCM_SHA384",
  "tempkey": "X25519",
  "protocol": "h2",
  "threads": "3",
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

![h2load batch benchmark chart](charts/dedicated/1t-output.png "h2load batch benchmark chart")

`output-avg.png`

![h2load batch benchmark chart - avg response time](charts/dedicated/1t-output-avg.png "h2load batch benchmark chart - avg response time")

`output-max.png`

![h2load batch benchmark chart - max response time](charts/dedicated/1t-output-max.png "h2load batch benchmark chart - max response time")

# Comparison Charts

You can take 2 separate `-b` batch mode runs, renaming the 1st runs' `output.csv` and `output2.csv` files to `1t-output.csv` and `1t-output2.csv` and then edit the labels/legends and run `h2load-plot-vps-vs-dedicated.gnuplot` script to compare 2 runs. Below is comparing above [VPS benchmarks](#batch-mode-vps) and [Dedicated server benchmarks](#batch-mode-dedicated-server) runs with dedicated csv files renamed.

`compared-output.png`

![h2load batch benchmark comparison VPS vs Dedicated chart](charts/compared-output.png "h2load batch benchmark comparison VPS vs Dedicated chart")

`compared-output-avg.png`

![h2load batch benchmark comparison VPS vs Dedicated chart - avg response time](charts/compared-output-avg.png "h2load batch benchmark comparison VPS vs Dedicated chart - avg response time")

`compared-output-max.png`

![h2load batch benchmark comparison VPS vs Dedicated chart - max response time](charts/compared-output-max.png "h2load batch benchmark comparison VPS vs Dedicated chart - max response time")