#!/bin/bash
# Purpose:	Make 3-D bar graph on top of perspective map

#
ctr="-Xc -Yc"
for i in 1
do
	fig[i]="Figures/GMT_example7-${i}.ps"
done

gmt pscoast -Rd -JX8id/5id -Dc -Sazure2 -Gwheat -Wfaint -A5000 -p200/40 -K > ${fig[1]}
awk '{print $1, $2, $3}' Data/agu2008.d \
	| gmt pstext -R -J -O -K -p -Ggray@30 -D-0.25i/0 \
	-F+f30p,Helvetica-Bold,firebrick=thinner+jRM >> ${fig[1]}
gmt psxyz Data/agu2008.d -R-180/180/-90/90/1/50000 -J -JZ3.5i -So0.3i -Gblue -Wthinner \
	--FONT_TITLE=30p,Times-Bold --MAP_TITLE_OFFSET=-0.7i -O -p --FORMAT_GEO_MAP=dddF \
	-Bx60 -By30 -Bza10000+lMembership -BWSneZ+t"AGU Membership 2008" >> ${fig[1]}
rm -f .gmt*



gv ${fig[1]}