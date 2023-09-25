set terminal x11
set datafile separator ','
set key off
splot 'in' using 1:2:3 with points palette pointsize 3 pointtype 20
