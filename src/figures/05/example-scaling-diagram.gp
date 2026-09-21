OUT = "figures/05/example-scaling-diagram.tex"
DATA  = "figures/05/example-scaling-data.dat"

set terminal epslatex color size 5.4in,3.1in font ",10"
set output OUT

set xlabel "Nodes"
set logscale x 2
set xtics (1,2,4,8,16,32,64)
set grid

set ylabel  "Mean runtime [s]"
set y2label "Speedup  T(1)/T(p)"
set logscale y
set logscale y2
set ytics  nomirror
set y2tics nomirror

set key top center horizontal

plot \
    DATA using 1:($2-$4):($2+$4) axes x1y1 with filledcurves fc rgb "#1f77b4" fs transparent solid 0.2 title "±stddev", \
    DATA using 1:2               axes x1y1 with linespoints lw 5 pt 7 ps 2 lc rgb "#1f77b4" title "mean time", \
    DATA using 1:5               axes x1y2 with linespoints lw 5 pt 5 ps 2 lc rgb "#d62728" title "speedup", \
    x                            axes x1y2 with lines lw 2 dt 2 lc rgb "#888888" title "ideal"

print "wrote ", OUT
