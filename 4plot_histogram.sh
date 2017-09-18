#!/bin/bash
# Purpose:	Make standard and polar histograms

ctr="-Xc -Yc"
for i in 1
do
	fig[i]="Figures/GMT_example4-${i}.ps"
done

gmt psrose Data/fractures.d -: -A10r -S1.8in -P -Gorange -R0/1/0/360 -X2.5i -Y2i -K -Bx0.2g0.2 \
	-By30g30 -B+glightblue -W1p > ${fig[1]} #-Ar -> draw rose diagram, -Sn to normalize input radius
gmt pshistogram -Bxa2000f1000+l"Topography (m)" -Bya10f5+l"Frequency"+u" %" \
	-BWSne+t"Histograms"+glightblue Data/v3206.t -R-6000/0/0/30 -JX4.8i/2.4i -Gorange -O \
	-Y5.0i -X-0.5i -L1p -Z1 -W250 >> ${fig[1]} #-L1p-> bar outline thickness, Z1->frequency in percent, -Wbin_width

gv ${fig[1]}