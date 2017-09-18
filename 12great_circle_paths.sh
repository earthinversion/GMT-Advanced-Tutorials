#!/bin/bash
#		GMT EXAMPLE 23
#
# Purpose:	Plot distances from Rome and draw shortest paths
# GMT modules:	grdmath, grdcontour, pscoast, psxy, pstext, grdtrack
# Unix progs:	echo, cat, awk
#
ctr="-Xc -Yc"

for i in 1
do
	fig[i]="Figures/GMT_example12-${i}.ps"
done
# Position and name of central point:

lon=12.50
lat=41.99
name="Rome"

# Calculate distances (km) to all points on a global 1x1 grid

gmt grdmath -Rg -I1 $lon $lat SDIST = dist.nc

# Location info for 5 other cities + label justification

cat << END > cities.d
105.87	21.02	HANOI		LM
282.95	-12.1	LIMA		LM
178.42	-18.13	SUVA		LM
237.67	47.58	SEATTLE		RM
28.20	-25.75	PRETORIA	LM
END

gmt pscoast -Rg -JH90/9i -Glightgreen -Slightblue -A1000 -Dc -Bg30 \
	-B+t"Distances from $name to the World" -K -Wthinnest > ${fig[1]}

gmt grdcontour dist.nc -A1000+v+u" km"+fbrown -Glz-/z+ -S8 -C500 -O -K -J \
	-Wathin,white -Wcthinnest,white,- >> ${fig[1]}

# For each of the cities, plot great circle arc to Rome with gmt psxy
gmt psxy -R -J -O -K -Wthickest,red -Fr$lon/$lat cities.d >> ${fig[1]}

# Plot red squares at cities and plot names:
gmt psxy -R -J -O -K -Ss0.2 -Gblue -Wthinnest cities.d >> ${fig[1]}
awk '{print $1, $2, $4, $3}' cities.d | gmt pstext -R -J -O -K -Dj0.15/0 \
	-F+f12p,Courier-Bold,red+j -N >> ${fig[1]}
# Place a yellow star at Rome
echo "$lon $lat" | gmt psxy -R -J -O -K -Sa0.2i -Gyellow -Wthin >> ${fig[1]}

# Sample the distance grid at the cities and use the distance in km for labels

gmt grdtrack -Gdist.nc cities.d \
	| awk '{printf "%s %s %d km\n", $1, $2, int($NF+0.5)}' \
	| gmt pstext -R -J -O -D0/-0.2i -N -Gwhite -W -C0.02i -F+f12p,Helvetica-Bold+jCT >> ${fig[1]}

# Clean up after ourselves:

rm -f cities.d dist.nc
gv ${fig[1]}