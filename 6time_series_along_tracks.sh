#!/bin/bash

# Purpose:	Make wiggle plot along track from geoid deflections
ctr="-Xc -Yc"
for i in 1
do
	fig[i]="Figures/GMT_example6-${i}.ps"
done


gmt pswiggle Data/tracks.txt -R185/250/-68/-42 -K -Jm0.13i -Ba10f5 -BWSne+g240/255/240 -G+red \
	-G-blue -Z2000 -Wthinnest -S240/-67/500/@~m@~rad --FORMAT_GEO_MAP=dddF > ${fig[1]} #-S dras simple vertical scale
#-Zanomaly_scale
gmt psxy -R -J -O -K Data/ridge2.xy -Wthicker >> ${fig[1]}

gmt psxy -R -J -O -K Data/fz2.xy -Wthinner,- >> ${fig[1]}
# Take label from segment header and plot near coordinates of last record of each track
gmt convert -El Data/tracks.txt | gmt pstext -R -J -F+f10p,Helvetica-Bold+a50+jRM+h \
	-D-0.05i/-0.05i -O -K >> ${fig[1]}
#-El -> extract last record of each segement e.g.
# > 107
#222.267	-66.2309	-3
gmt pslegend -R -J -O -DjTR+w2.2i+o0.2i -F+pthick+ithinner+gwhite --FONT_ANNOT_PRIMARY=18p,Times-Italic<< EOF >> ${fig[1]}
S 0.1i - 0.15i - thicker 0.3i Ridge
S 0.1i - 0.15i - thinner,- 0.3i Fractures
EOF

gv ${fig[1]}

rm -f *.history