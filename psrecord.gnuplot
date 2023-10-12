#!/usr/bin/gnuplot -c

# Get the file path and timestamp from the command-line arguments
datafile = ARG1
timestamp = ARG2

# Set default values for title variables and labels
title1 = "psrecord Nginx CPU Usage For h2load Benchmark"
title2 = "psrecord Nginx Memory Usage For h2load Benchmark"
data_legend1 = 'Nginx CPU usage'
data_legend2 = 'Nginx Memory usage'

set terminal pngcairo enhanced font "arial,13" fontscale 1.0 size 1280, 1280
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

set xlabel "Time (s)" font "arial,12"
set ylabel "Nginx CPU usage (%)" font "arial,12"
set y2label "Nginx Memory usage (MB)" font "arial,12"

set ytics nomirror
set y2tics

# data label sizes
set label font "arial,9"

# Adjust the bottom margin
set bmargin 5

# Add text label for GitHub link
set label at screen 0.06, 0.02 "https://github.com/centminmod/psrecord-benchmarks" left font "arial,12"

# Use the timestamp in the output file name
set output sprintf('psrecord-logs/psrecord-%s.png', timestamp)
set title title1 font "arial,12"
set y2label "Nginx Memory usage (MB)" font "arial,12"
plot datafile using 1:2 title data_legend1 with linespoints ls 1, \
     datafile using 1:2:(sprintf("%d", $2)) with labels notitle offset char 0,1, \
     datafile using 1:(column(3)) title data_legend2 axes x1y2 with linespoints ls 2, \
     datafile using 1:(column(3)):(sprintf("%d", column(3))) axes x1y2 with labels notitle offset char 0,1