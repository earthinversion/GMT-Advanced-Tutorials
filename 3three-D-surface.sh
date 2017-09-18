#!/bin/bash
# Purpose: Generate grid and show monochrome 3-D perspective

#
ctr="-Xc -Yc"
for i in 1
do
	fig[i]="Figures/GMT_example3-${i}.ps"
done 


gmt grdmath -R-15/15/-15/15 -I0.3 X Y HYPOT DUP 2 MUL PI MUL 8 DIV COS EXCH NEG 10 DIV \
	EXP MUL = sombrero.nc #-Igrid_spacing, X, Y grid with X and Y coordinates, HYPOT - hypotenuse, DUP - duplicate, EXCH - exchange A and B on stack
gmt makecpt -Chot -T-5/5 -N > g.cpt
gmt grdgradient sombrero.nc -A225 -Gintensity.nc -Nt0.75
gmt grdview sombrero.nc -JX6i -JZ2i -B5 -Bz0.5 -BSEwnZ -N-1+gwhite -Qs -Iintensity.nc -X1.5i \
	-Cg.cpt -R-15/15/-15/15/-1/1 -K -p120/30 > ${fig[1]}
echo "4.1 5.5 z(r) = cos (2@~p@~r/8) @~\327@~e@+-r/10@+" | gmt pstext -R0/11/0/8.5 -Jx1i \
	-F+f50p,ZapfChancery-MediumItalic+jBC -O >> ${fig[1]}
rm -f g.cpt sombrero.nc intensity.nc *.history

gv ${fig[1]}

