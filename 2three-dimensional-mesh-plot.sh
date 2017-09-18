#!/bin/bash
# Purpose:	3-D mesh and color plot of Hawaiian topography and geoid

#
ctr="-Xc -Yc"
for i in 1 2
do
	fig[i]="Figures/GMT_example2-${i}.ps"
done 
gmt makecpt -C255,100 -T-10/10/10 -N > zero.cpt #-C: specifies the color to build linear continuous cpt, -T: zmin, zmax, zinc
gmt grdcontour Data/HI_geoid4.nc -R195/210/18/25 -Jm0.45i -p60/30 -C1 -A5+o -Gd4i -K -P \
	-X1.25i -Y1.25i > ${fig[1]} #-pazm/elev, -Ccontour_interval, -Aannot_interval+o->rounded rectangle box, Gd-> distances between the labels on the plots
gmt pscoast -R -J -p -B2 -BNEsw -Gchocolate -W0.1,blue -O -K -TdjBR+o0.1i+w1i+l >> ${fig[1]} #-Td draws a map directional rose on the map at the
# location defined by the reference and anchor points, -G-> filling of dry areas

#-Rxmin/xmax/ymin/ymax/zmin/zmax if -Jz specified
gmt grdview Data/HI_topo4.nc -R195/210/18/25/-6/4 -J -Jz0.34i -p -Czero.cpt -O -K \
	-N-6+glightgray -Qsm -B2 -Bz2+l"Topo (km)" -BneswZ -Y2.2i >> ${fig[1]}
echo '3.25 5.75 H@#awaiian@# R@#idge@#' | gmt pstext -R0/10/0/10 -Jx1i \
	-F+f60p,ZapfChancery-MediumItalic+jCB -O >> ${fig[1]}
rm -f zero.cpt
#
gmt grdgradient Data/HI_geoid4.nc -A0 -Gg_intens.nc -Nt0.75 -fg #-Aazm, -Goutput_grdfile, -Nt-> normalization using cumulative cauchy distribution
gmt grdgradient Data/HI_topo4.nc -A0 -Gt_intens.nc -Nt0.75 -fg #-fg -> geographic grids in meters
gmt grdimage Data/HI_geoid4.nc -Ig_intens.nc -R195/210/18/25 -JM6.75i -p60/30 -CData/geoid.cpt -E100 \
	-K -P -X1.25i -Y1.25i > ${fig[2]} #-Iintensity_file, -Eresolution
gmt pscoast -R -J -p -B2 -BNEsw -Gblack -O -K >> ${fig[2]}
gmt psbasemap -R -J -p -O -K -TdjBR+o0.1i+w1i+l --COLOR_BACKGROUND=red --FONT=red \
	--MAP_TICK_PEN_PRIMARY=thinner,red >> ${fig[2]}
gmt psscale -R -J -p240/30 -DJBC+o0/0.5i+w5i/0.3i+h -CData/geoid.cpt -I -O -K -Bx2+l"Geoid (m)" >> ${fig[2]}
gmt grdview Data/HI_topo4.nc -It_intens.nc -R195/210/18/25/-6/4 -J -JZ3.4i -p60/30 -CData/topo.cpt \
	-O -K -N-6+glightgray -Qc100 -B2 -Bz2+l"Topo (km)" -BneswZ -Y2.2i >> ${fig[2]}
echo '3.25 5.75 H@#awaiian@# R@#idge@#' | gmt pstext -R0/10/0/10 -Jx1i \
	-F+f60p,ZapfChancery-MediumItalic+jCB -O >> ${fig[2]}
rm -f *_intens.nc

gv ${fig[2]}

rm -f *.history