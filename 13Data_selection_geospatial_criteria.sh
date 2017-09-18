#!/bin/bash

# Purpose:	Extract subsets of data based on geospatial criteria

# Highlight oceanic earthquakes within 3000 km of Hobart and > 1000 km from dateline
ctr="-Xc -Yc"

for i in 1
do
	fig[i]="Figures/GMT_example13-${i}.ps"
done


echo "147:13 -42:48 6000" > point.txt
cat << END > dateline.txt
> Our proxy for the dateline
180	0
180	-90
>another line
120 0
120 -90
END
R=`gmt info -I10 Data/oz_quakes.d`
gmt pscoast $R -JM9i -K -Gtan -Sdarkblue -Wthin,white -Dl -A500 -Ba20f10g10 -BWeSn > ${fig[1]}
gmt psxy -R -J -O -K Data/oz_quakes.d -Sc0.05i -Gred >> ${fig[1]}
gmt select Data/oz_quakes.d -L500k/dateline.txt -Nk/s -C3000k/point.txt -fg -R -Il -fo > Data/selected_quakes.txt #long, lat, depth, mag
gmt select Data/oz_quakes.d -L500k/dateline.txt -Nk/s -C3000k/point.txt -fg -R -Il \
	| gmt psxy -R -JM -O -K -Sc0.05i -Ggreen >> ${fig[1]}
#-Nk/s for condition wet areas only
gmt psxy point.txt -R -J -O -K -SE- -Wfat,white >> ${fig[1]}
gmt pstext point.txt -R -J -F+f14p,Helvetica-Bold,white+jLT+tHobart \
	-O -K -D0.1i/-0.1i >> ${fig[1]}
gmt psxy -R -J -O -K point.txt -Wfat,white -S+0.2i >> ${fig[1]}
gmt psxy -R -J -O dateline.txt -Wfat,white -A >> ${fig[1]}
rm -f point.txt dateline.txt

gv ${fig[1]}