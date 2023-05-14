#!/usr/bin/gnuplot

set terminal pngcairo enhanced font "arial,12" fontscale 1.0 size 1280, 800
set output 'output.png'
set datafile separator ","
set key outside
set autoscale y2
set grid

# Apply a theme for a more modern look
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5
set style line 2 lc rgb '#dd181f' lt 1 lw 2 pt 5 ps 1.5

set border linewidth 1.5
set tics nomirror out scale 0.75
set format '%g'

set xlabel "User Connections" font "arial,12"
set ylabel "Requests/s" font "arial,12"
set y2label "Avg Response Time" font "arial,12"

set ytics nomirror
set y2tics

# Round the labels to whole numbers
round(x) = sprintf("%.0f", x)

plot "output.csv" using 1:2 title 'requests/s' with linespoints ls 1, \
     "output.csv" using 1:2:(round($2)) with labels notitle offset char 0,1, \
     "output.csv" using 1:3 title 'avg response time' axes x1y2 with linespoints ls 2, \
     "output.csv" using 1:3:(round($3)) axes x1y2 with labels notitle offset char 0,1