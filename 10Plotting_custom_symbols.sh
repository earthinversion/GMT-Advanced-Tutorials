#!/bin/bash

# Purpose:	Extend GMT to plot custom symbols

# Plot a world-map with volcano symbols of different sizes
# on top given locations and sizes in hotspots.d
ctr="-Xc -Yc"

for i in 1
do
	fig[i]="Figures/GMT_example10-${i}.ps"
done

cat > hotspots1.d << END
55.5	-21.0	0.5
63.0	-49.0	0.5
END
cat > hotspots2.d << END
-12.0	-37.0	0.5
-28.5	29.34	0.5
END
cat > hotspots3.d << END
48.4	-53.4	0.5
155.5	-40.4	0.5
END
cat > hotspots4.d << END
-155.5	19.6	0.5
-138.1	-50.9	0.5
-153.5	-21.0	0.5
-116.7	-26.3	0.5
-16.5	64.4	0.5
END
gmt pscoast -Rg -JR9i -Bx60 -By30 -B+t"Hotspot Islands and Cities" -Gdarkgreen -Slightblue \
	-Dc -A5000 -K > ${fig[1]}

gmt psxy -R -J hotspots1.d -Skvolcano -O -K -Wthinnest -Gred >> ${fig[1]}
gmt psxy -R -J hotspots2.d -SkCustomSymbols/sun -O -K -Wthinnest -Gred >> ${fig[1]}
gmt psxy -R -J hotspots3.d -SkCustomSymbols/hurricane -O -K -Wthinnest -Gblue >> ${fig[1]}
gmt psxy -R -J hotspots4.d -SkCustomSymbols/astroid -O -K -Wthinnest -Gyellow >> ${fig[1]}

# Overlay a few bullseyes at NY, Cairo, and Perth

cat > cities.d << END
286	40.45	0.8
31.15	30.03	0.5
115.49	-31.58	0.4
END

gmt psxy -R -J cities.d -SkCustomSymbols/bullseye -O >> ${fig[1]}

rm -f hotspots*.d cities.d gmt*

gv ${fig[1]}