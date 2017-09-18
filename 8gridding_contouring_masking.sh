#!/bin/bash

# Purpose:	Gridding and clipping when data are missing

# We first convert a large ASCII file to binary with gmtconvert since the binary file will read 
# and process much faster. Our lower left plot illustrates the results of gridding using a nearest 
# neighbor technique (nearneighbor) which is a local method: No output is given where there are no data. 
# Next (lower right), we use a minimum curvature technique (surface) which is a global method. Hence, 
# the contours cover the entire map although the data are only available for portions of the area 
# (indicated by the gray areas plotted using psmask). The top left scenario illustrates how we can create
#  a clip path (using psmask) based on the data coverage to eliminate contours outside the constrained area. 
#  Finally (top right) we simply employ pscoast to overlay gray land masses to cover up the unwanted contours,
#   and end by plotting a star at the deepest point on the map with psxy.
ctr="-Xc -Yc"
for i in 1
do
	fig[i]="Figures/GMT_example8-${i}.ps"
done

gmt convert Data/ship.xyz -bo > ship.b #-bo selects native binary output
#
region=`gmt info ship.b -I1 -bi3d` #-bi3d: selects native binary input, 3 number of columns, 8 byte double precision float 
# echo $region
gmt nearneighbor $region -I10m -S40k -Gship.nc ship.b -bi #-I10m-> grid spacing 10 arc minutes, 
#-S40k : 40km search radius
#-Goutput_grdfile

gmt grdcontour ship.nc -JM3i -P -B2 -BWSne -C250 -A1000 -Gd2i -Y2i -K> ${fig[1]}
#-Gd2i: 2i distance between labels in the plot
# #
gmt blockmedian $region -I10m ship.b -b3d > ship_10m.b
gmt surface $region -I10m ship_10m.b -Gship.nc -bi
gmt psmask $region -I10m ship.b -J -O -K -T -Glightgray -bi3d -X3.6i >> ${fig[1]}
gmt grdcontour ship.nc -J -B -C250 -L-8000/0 -A1000 -Gd2i -O -K >> ${fig[1]}
# #
gmt psmask $region -I10m ship_10m.b -bi3d -J -B -O -K -X-3.6i -Y3.75i >> ${fig[1]}
gmt grdcontour ship.nc -J -C250 -A1000 -L-8000/0 -Gd2i -O -K >> ${fig[1]}
gmt psmask -C -O -K >> ${fig[1]}
# #
gmt grdclip ship.nc -Sa-1/NaN -Gship_clipped.nc
gmt grdcontour ship_clipped.nc -J -B -C250 -A1000 -L-8000/0 -Gd2i -O -K -X3.6i >> ${fig[1]}
gmt pscoast $region -J -O -K -Ggray -Wthinnest >> ${fig[1]}
gmt grdinfo -C -M ship.nc | gmt psxy -R -J -O -K -Sa0.15i -Wthick,red -Gred -i11,12 >> ${fig[1]}
echo "-0.3 3.6 Gridding with missing data" | gmt pstext -R0/3/0/4 -Jx1i \
	-F+f24p,Helvetica-Bold+jCB -O -N >> ${fig[1]}



rm -f ship.b ship_10m.b ship.nc ship_clipped.nc gmt*

gv ${fig[1]}