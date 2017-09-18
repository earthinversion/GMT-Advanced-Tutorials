#!/bin/bash

# Purpose:	Make a basemap with earthquakes and isochrons etc
ctr="-Xc -Yc"
for i in 1
do
	fig[i]="Figures/GMT_example5-${i}.ps"
done
gmt pscoast -R-50/0/-10/20 -JM9i -K -Slightblue -GP300/26:FtanBdarkbrown -Dh -Wthinnest \
	-B10 $ctr --FORMAT_GEO_MAP=dddF > ${fig[1]}
gmt psxy -R -J -O -K Data/fz.xy -Wthinner,-  >> ${fig[1]}
gmt psxy Data/quakes.xym -R -J -O -K -h1 -Sci -i0,1,2s0.01 -Gred -Wthinnest >> ${fig[1]} #-h1 skips header record
gmt psxy -R -J -O -K Data/isochron.xy -Wthin,blue >> ${fig[1]}
gmt psxy -R -J -O -K Data/ridge.xy -Wthicker,orange >> ${fig[1]}
gmt pslegend -R -J -O -K -DjTR+w2.2i+o0.2i -F+pthick+ithinner+gwhite --FONT_ANNOT_PRIMARY=18p,Times-Italic<< EOF >> ${fig[1]}
S 0.1i c 0.08i red thinnest 0.3i ISC Earthquakes
S 0.1i - 0.15i - thin,blue 0.3i Isochron
S 0.1i - 0.15i - thicker,orange 0.3i Ridge
S 0.1i - 0.15i - thinner,- 0.3i Fractures
EOF
#
gmt pstext -R -J -O -F+f30,Helvetica-Bold,white=thin >> ${fig[1]} << END
-43 -5 SOUTH
-43 -8 AMERICA
 -7 11 AFRICA
END

gv ${fig[1]}
rm *.history
