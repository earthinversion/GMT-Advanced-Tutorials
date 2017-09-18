#!/bin/bash

# Purpose:	Illustrates clipping of images using coastlines
ctr="-Xc -Yc"

for i in 1
do
	fig[i]="Figures/GMT_example9-${i}.ps"
done
# First generate geoid image w/ shading
gmt grd2cpt Data/india_geoid.nc -Crainbow > geoid.cpt
gmt grdgradient Data/india_geoid.nc -Nt1 -A45 -Gindia_geoid_i.nc
gmt grdimage Data/india_geoid.nc -Iindia_geoid_i.nc -JM6.5i -Cgeoid.cpt -P -K $ctr > ${fig[1]}

# Then use gmt pscoast to initiate clip path for land

gmt pscoast -RData/india_geoid.nc -J -O -K -Dl -Gc >> ${fig[1]}

# Now generate topography image w/shading

gmt makecpt -Ctopo -T-10000/10000 -N > shade.cpt
gmt grdgradient Data/india_topo.nc -Nt1 -A45 -Gindia_topo_i.nc
gmt grdimage Data/india_topo.nc -Iindia_topo_i.nc -J -Cshade.cpt -O -K >> ${fig[1]}

# Finally undo clipping and overlay basemap

gmt pscoast -R -J -O -K -Q -B10f5 -B+t"Clipping of Images" >> ${fig[1]}

# Put a color legend on top of the land mask

gmt psscale -DjTR+o0.3i/0.1i+w4i/0.2i+h -R -J -Cgeoid.cpt -Bx5f1 -By+lm -I -O -K >> ${fig[1]}

# Add a text paragraph

gmt pstext -R -J -O -M -Gwhite -Wthinner -TO -D-0.1i/0.1i -F+f12,Times-Roman+jRB >> ${fig[1]} << END
> 90 -10 12p 3i j
@_@%5%INFO@%%@_:  We first plot the color geoid image
for the entire region, followed by a gray-shaded @#etopo5@#
image that is clipped so it is only visible inside the coastlines.
END

# Clean up

rm -f geoid.cpt shade.cpt *_i.nc
gv ${fig[1]}