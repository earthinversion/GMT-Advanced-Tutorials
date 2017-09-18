#!/bin/bash

# Purpose:      Illustrate use of map inserts


ctr="-Xc -Yc"

for i in 1 2 3
do
	fig[i]="Figures/GMT_example14-${i}.ps"
done

# Bottom map of Australia
gmt pscoast -R110E/170E/44S/9S -JM6i -P -Baf -BWSne -Wfaint -N2/1p  -EAU+gbisque -Gbrown -Sazure1 -Da -K $ctr --FORMAT_GEO_MAP=dddF > ${fig[1]}
gmt psbasemap -R -J -O -K -DjTR+w1.5i+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c+s >> ${fig[1]}
read x0 y0 w h < tmp
gmt pscoast -Rg -JG120/30S/$w -Da -Gbrown -A5000 -Bg -Wfaint -EAU+gbisque -O -K -X$x0 -Y$y0 >> ${fig[1]}
gmt psxy -R -J -O -T  -X-${x0} -Y-${y0} >> ${fig[1]}


# Determine size of insert map of Europe
gmt mapproject -R15W/35E/30N/48N -JM2i -W > tmp
read w h < tmp
gmt pscoast -R10W/5E/35N/44N -JM6i -Baf -BWSne -EES+gbisque -Gbrown -Wfaint -N1/1p -Sazure1 -Df -Y4.5i --FORMAT_GEO_MAP=dddF -P -K > ${fig[2]}
gmt psbasemap -R -J -O -K -DjTR+w$w/$h+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c+s >> ${fig[2]}
read x0 y0 w h < tmp
gmt pscoast -R15W/35E/30N/48N -JM$w -Da -Gbrown -B0 -EES+gbisque -O -K -X$x0 -Y$y0 --MAP_FRAME_TYPE=plain >> ${fig[2]}
gmt psxy -R -J -O -T -X-${x0} -Y-${y0} >> ${fig[2]}



# Determine size of insert map of Taiwan
twinset="-R100/140/5/40"
gmt mapproject ${twinset} -JM2i -W > tmp
read w h < tmp
gmt pscoast -R117E/124E/20N/28N -JM6i -Baf -BWSne -ETW+gbisque -Gbrown -Wthick -A5000 -N1/1p -Sazure1 -Df --FORMAT_GEO_MAP=dddF -P -K $ctr> ${fig[3]}
gmt psbasemap -R -J -O -K -DjTR+w$w/$h+o0.15i/0.1i+stmp -F+gwhite+p1p+c0.1c+s >> ${fig[3]}
read x0 y0 w h < tmp
gmt pscoast ${twinset} -JM$w -Da -Gbrown -B0 -ETW+gbisque -O -K -X$x0 -Y$y0 --MAP_FRAME_TYPE=plain >> ${fig[3]}
gmt psxy -R -J -O -T -X-${x0} -Y-${y0} >> ${fig[3]}
rm -f tmp

gv ${fig[3]}