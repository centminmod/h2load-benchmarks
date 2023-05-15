#!/usr/bin/gnuplot

set terminal pngcairo enhanced font "arial,13" fontscale 1.0 size 1300, 1300
set datafile separator ","
set key outside below right
set autoscale y2
set grid

# Apply a theme for a more modern look
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5
set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 ps 1.5
set style line 3 lc rgb '#00ad60' lt 2 lw 2 pt 7 ps 1.5 dt (5,2,2,2,2,2)
set style line 4 lc rgb '#dd831f' lt 2 lw 2 pt 5 ps 1.5 dt (5,2,2,2,2,2)

set border 11 linewidth 1.0
set tics nomirror out scale 0.75
set format '%g'
set offsets 0.1, 0.1, 0.1, 0.1

set xlabel "User Connections" font "arial,12"
set ylabel "Requests/s" font "arial,12"
set y2label "Avg Response Time (ms)" font "arial,12"

set ytics nomirror
set y2tics

# Round the labels to whole numbers
round(x) = sprintf("%.0f", x)

# Format the labels based on time units
format_time(x) = sprintf("%.0fms", x)

# data label sizes
set label font "arial,9"

# Adjust the bottom margin
set bmargin 8

# Add text label for GitHub link
set label at screen 0.06, 0.02 "https://github.com/centminmod/h2load-benchmarks" left font "arial,12"

# Apply logscale to y-axis
set logscale y

# Separate plot for output.csv (VPS)
set output 'compared-output-avg.png'
set title "h2load HTTP/2 HTTPS Benchmark - Average Response Time (ms)"
set y2label "Avg Response Time" font "arial,12"
plot "output.csv" using 1:2 title 'VPS requests/s' with linespoints ls 1, \
     "output.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "output.csv" using 1:(column(3)) title 'VPS avg response time' axes x1y2 with linespoints ls 2, \
      "output.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,-1, \
      "1t-output.csv" using 1:2 title 'Dedicated requests/s' with linespoints ls 3, \
      "1t-output.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "1t-output.csv" using 1:(column(3)) title 'Dedicated avg response time' axes x1y2 with linespoints ls 4, \
      "1t-output.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,-1

# Separate plot for output2.csv (VPS)
set output 'compared-output-max.png'
set title "h2load HTTP/2 HTTPS Benchmark - Maximum Response Time (ms)"
set y2label "Max Response Time" font "arial,12"
plot "output2.csv" using 1:2 title 'VPS requests/s' with linespoints ls 1, \
     "output2.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "output2.csv" using 1:(column(3)) title 'VPS max response time' axes x1y2 with linespoints ls 2, \
      "output2.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,-1, \
      "1t-output2.csv" using 1:2 title 'Dedicated requests/s' with linespoints ls 3, \
      "1t-output2.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "1t-output2.csv" using 1:(column(3)) title 'Dedicated max response time' axes x1y2 with linespoints ls 4, \
      "1t-output2.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,-1

# Multiplot for both (VPS and Dedicated)
set terminal pngcairo enhanced font "arial,13" fontscale 1.0 size 1280, 1600
set output 'compared-output.png'
set multiplot layout 2,1 title "h2load HTTP/2 HTTPS Benchmark"

# Plot for output.csv (VPS)
set title "Average Response Time"
set y2label "Avg Response Time" font "arial,12"
plot "output.csv" using 1:2 title 'VPS requests/s' with linespoints ls 1, \
     "output.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "output.csv" using 1:(column(3)) title 'VPS avg response time' axes x1y2 with linespoints ls 2, \
      "output.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,-1, \
      "1t-output.csv" using 1:2 title 'Dedicated requests/s' with linespoints ls 3, \
      "1t-output.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "1t-output.csv" using 1:(column(3)) title 'Dedicated avg response time' axes x1y2 with linespoints ls 4, \
      "1t-output.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,-1

# Plot for output2.csv (VPS)
set title "Maximum Response Time"
set y2label "Max Response Time" font "arial,12"
plot "output2.csv" using 1:2 title 'VPS requests/s' with linespoints ls 1, \
     "output2.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "output2.csv" using 1:(column(3)) title 'VPS max response time' axes x1y2 with linespoints ls 2, \
      "output2.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,-1, \
      "1t-output2.csv" using 1:2 title 'Dedicated requests/s' with linespoints ls 3, \
      "1t-output2.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "1t-output2.csv" using 1:(column(3)) title 'Dedicated max response time' axes x1y2 with linespoints ls 4, \
      "1t-output2.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,-1

unset multiplot
