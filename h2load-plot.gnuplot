#!/usr/bin/gnuplot

set terminal pngcairo enhanced font "arial,13" fontscale 1.0 size 1280, 800
set output 'output.png'
set datafile separator ","
set key outside below right
set autoscale y2
set grid

# Apply a theme for a more modern look
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5
set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 ps 1.5

set border linewidth 1.0
set tics nomirror out scale 0.75
set format '%g'
set offsets 0.1, 0.1, 0.1, 0.1

set xlabel "User Connections" font "arial,12"
set ylabel "Requests/s" font "arial,12"
set y2label "Avg Response Time" font "arial,12"

set ytics nomirror
set y2tics

set title "h2load HTTP/2 HTTPS Benchmark"

# Round the labels to whole numbers
round(x) = sprintf("%.0f", x)

# Format the labels based on time units and round up average response time labels
format_time(x, unit) = \
    (unit eq "s") ? sprintf("%.0fs", int(x + 0.5)) : \
    (unit eq "ms") ? sprintf("%.0fms", int(x + 0.5)) : \
    (unit eq "us") ? sprintf("%.0fus", int(x + 0.5)) : \
    sprintf("%.0f", x)

# Adjust the bottom margin
set bmargin 5

# Add text label for GitHub link
set label at screen 0.06, 0.02 "https://github.com/centminmod/h2load-benchmarks" left font "arial,12"

plot "output.csv" using 1:2 title 'requests/s' with linespoints ls 1, \
     "output.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
     "output.csv" using 1:3 title 'avg response time' axes x1y2 with linespoints ls 2, \
     "output.csv" using 1:3:(format_time($3, strcol(3))) axes x1y2 with labels notitle offset char 0,1