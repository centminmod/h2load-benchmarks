#!/usr/bin/gnuplot

# Set default values for title variables and labels
title1 = "h2load HTTP/2 HTTPS Benchmark - Average Response Time (ms)"
title2 = "h2load HTTP/2 HTTPS Benchmark - Maximum Response Time (ms)"
title3 = "Average Response Time"
title4 = "Maximum Response Time"
data_legend1 = 'requests/s'
data_legend2 = 'requests/s'
data_legend3 = 'avg response time'
data_legend4 = 'max response time'

set terminal pngcairo enhanced font "arial,13" fontscale 1.0 size 1280, 800
set datafile separator ","
set key outside below right
set autoscale y2
set grid

# Apply a theme for a more modern look
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5
set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 ps 1.5

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
set bmargin 5

# Add text label for GitHub link
set label at screen 0.06, 0.02 "https://github.com/centminmod/h2load-benchmarks" left font "arial,12"

# Apply logscale to y-axis
set logscale y

# Separate plot for output.csv
set output 'output-avg.png'
set title title1 font "arial,12"
set y2label "Avg Response Time" font "arial,12"
plot "output.csv" using 1:2 title data_legend1 with linespoints ls 1, \
     "output.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "output.csv" using 1:(column(3)) title data_legend3 axes x1y2 with linespoints ls 2, \
      "output.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,1

# Separate plot for output2.csv
set output 'output-max.png'
set title title2 font "arial,12"
set y2label "Max Response Time" font "arial,12"
plot "output2.csv" using 1:2 title data_legend2 with linespoints ls 1, \
     "output2.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "output2.csv" using 1:(column(3)) title data_legend4 axes x1y2 with linespoints ls 2, \
      "output2.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,1

# Multiplot for both
set terminal pngcairo enhanced font "arial,13" fontscale 1.0 size 1280, 1600
set output 'output.png'
set multiplot layout 2,1 title "h2load HTTP/2 HTTPS Benchmark"

# Plot for output.csv
set title title3 font "arial,12"
set y2label "Avg Response Time" font "arial,12"
plot "output.csv" using 1:2 title data_legend1 with linespoints ls 1, \
     "output.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "output.csv" using 1:(column(3)) title data_legend3 axes x1y2 with linespoints ls 2, \
      "output.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,1

# Plot for output2.csv
set title title4 font "arial,12"
set y2label "Max Response Time" font "arial,12"
plot "output2.csv" using 1:2 title data_legend2 with linespoints ls 1, \
     "output2.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
      "output2.csv" using 1:(column(3)) title data_legend4 axes x1y2 with linespoints ls 2, \
      "output2.csv" using 1:(column(3)):(format_time(column(3))) axes x1y2 with labels notitle offset char 0,1

unset multiplot
