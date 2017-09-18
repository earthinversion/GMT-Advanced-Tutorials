#!/bin/bash
ctr="-Xc -Yc"
for i in 1 2 3 4
do
	fig[i]="GMT_example1-${i}.ps"
done 

gmt set GMT_FFT kiss #uses Kiss FFT algorithm

#we use "gmt fitcircle" to find the parameters of a great circle
# most closely fitting the x,y points in "sat.xyg":
cpos=`gmt fitcircle sat.xyg -L2 -Fm --IO_COL_SEPARATOR=/` #-Fm specifies to return mean data coordinates -> 330.169184777/-18.4206532702
ppos=`gmt fitcircle sat.xyg -L2 -Fn --IO_COL_SEPARATOR=/` #-Fn specifies to return north pole of the great circle -> 52.7451972868/21.2040074195


# Now we use "gmt project" to project the data in both sat.xyg and ship.xyg
# into data.pg, where g is the same and p is the oblique longitude around
# the great circle.
#We use -Q to get the p distance in kilometers, and -S
# to sort the output into increasing p values.

gmt project  sat.xyg -C$cpos -T$ppos -S -Fpz -Q > sat.pg
gmt project ship.xyg -C$cpos -T$ppos -S -Fpz -Q > ship.pg

# -I : Report the min/max of the first n columns to the nearest multiple of the provided increments
R=`gmt info -I100/25 sat.pg ship.pg` #-> -R-1200/1200/-75/200 : min1/max1/min2/max2


gmt psxy $R -BWeSn \
	-Bxa500f100+l"Distance along great circle" -Bya100f25+l"Gravity anomaly (mGal)" \
	-JX8i/5i $ctr -K -Wthick sat.pg > ${fig[1]}
gmt psxy -R -JX -O -Sp0.03i -Gblue ship.pg >> ${fig[1]}
# Ship data and sat data vary greatly at p~=250 km.
# We can do further investigation into the data using the cross-spectral analysis.
# But, before that we need to find out the spacing between the data


# gmt math : -T -> If there is no time column (only data columns), give -T with no arguments, -i0 -> first column selected
# gmt math: DIFF-> Forward difference between adjacent elements
gmt math ship.pg -T -i0 DIFF = | gmt pshistogram  -W0.1 -Gblue \
	-JX3i -K -X2i -Y1.5i -Bx+l"@~D@~p values" -BeWnS+t"@:12:Histogram for Ship @~D@~p values@::" \
	> ${fig[2]}
gmt math sat.pg -T -i0 DIFF = | gmt pshistogram  -W0.1 -Gblue \
	-JX3i -O -X5i -Bx+l"@~D@~p values" -BeWnS+t"@:12:Histogram for Satellite @~D@~p values@::" >> ${fig[2]}


# We need a starting and ending values for delta p which work for both the ship and sat data
#-AF -> report range for each file separately
gmt gmtinfo ship.pg sat.pg -I1 -Af -C -i0  --IO_COL_SEPARATOR=/ #-C -> Report the min/max values per column in separate columns
#-1168/1171
#-1171/1170
bounds="-1168/1170"

# Now we can use $bounds in gmt math to make a sampling points file for gmt sample1d:
gmt math -T$bounds/1 -N1/0 T = samp.x #-N0/1 specifies 2 number of columns and the time column is the first one, 
#T: Table with t-coordinates

# Now we can resample the gmt projected satellite data:
# sample1d reads a multi-column ASCII [or binary] data set from file [or standard input] 
# and interpolates the time-series or spatial profile at locations where the user needs the values.
# -Nknotfile: knotfile is an optional ASCII file with the time locations where the data set will be resampled in the first column. 
gmt sample1d sat.pg -Nsamp.x > samp_sat.pg

#the same procedure applied to the ship data could alias information at shorter wavelengths.  
#So we have to use "gmt filter1d" to resample the ship data. Since we observed spikes in the ship
# data, we use a median filter to clean up the ship values.
#filter1d is a general time domain filter for multiple column time series data. 
#The user specifies which column is the time (i.e., the independent variable).

gmt filter1d ship.pg -Fm1 -T$bounds/1 -E | gmt sample1d -Nsamp.x > samp_ship.pg #-Fm1: applies median filter of width 1


# Now we plot them again to see if we have done the right thing:
#
gmt psxy $R -JX8i/5i -X2i -Y1.5i -K -Wthick samp_sat.pg \
	-Bxa500f100+l"Distance along great circle" -Bya100f25+l"Gravity anomaly (mGal)" \
	-BWeSn > ${fig[3]}
gmt psxy -R -JX -O -Sp0.03i -Gblue samp_ship.pg >> ${fig[3]}


# Now to do the cross-spectra, assuming that the ship is the input and the sat is the output 
# data, we do this:
# gmtconvert : -A -> The records from the input files should be pasted horizontally, not appended vertically 
# gmt convert: 2nd column of samp_ship.pg and 2nd column of samp_sat.pg is pasted horizontally

#spectrum1d reads X [and Y] values from the first [and second] columns on standard input [or x[y]file]. 
#These values are treated as timeseries X(t) [Y(t)] sampled at equal intervals spaced dt units apart. 
#There may be any number of lines of input. spectrum1d will create file[s] containing auto- [and cross- ] 
#spectral density estimates by Welch’s method of ensemble averaging of multiple overlapped windows, 
#using standard error estimates from Bendat and Piersol.
#-S256 specifies number of samples per window for ensemble averaging
#-D1 sets the spacing between samples in the time series
#-W writes wavelength rather than frequency
#-C: read the first two columns of input as samples of two time series
# -T: Disable the writing of a single composite results file to stdout.
gmt convert -A samp_ship.pg samp_sat.pg -o1,3 | gmt spectrum1d -S256 -D1 -W -C -T


# Now we want to plot the spectra. The following commands will plot the ship and sat 
# power in one diagram and the coherency on another diagram, both on the same page.  
# We end by adding a map legends and some labels on the plots.
# For that purpose we often use -Jx1i and specify positions in inches directly:
#
gmt psxy spectrum.coh -Bxa1f3p+l"Wavelength (km)" -Bya0.25f0.05+l"Coherency@+2@+" \
	-BWeSn+g240/255/240 -JX-4il/3.75i -R1/1000/0/1 -P -K -X2.5i -Sc0.07i -Gpurple \
	-Ey/0.5p -Y1.5i > ${fig[4]}
echo "Coherency@+2@+" | gmt pstext -R -J -F+cTR+f18p,Helvetica-Bold -Dj0.1i \
	-O -K  >> ${fig[4]}
gmt psxy spectrum.xpower -Bxa1f3p -Bya1f3p+l"Power (mGal@+2@+ km)" \
	-BWeSn+t"Ship and Satellite Gravity"+g240/255/240 \
	-Gred -ST0.07i -O -R1/1000/0.1/10000 -JX-4il/3.75il -Y4.2i -K -Ey/0.5p >> ${fig[4]}
gmt psxy spectrum.ypower -R -JX -O -K -Gblue -Sc0.07i -Ey/0.5p >> ${fig[4]}
echo "Input Power" | gmt pstext -R0/4/0/3.75 -Jx1i -F+cTR+f18p,Helvetica-Bold -Dj0.1i -O -K >> ${fig[4]}
gmt pslegend -R -J -O -DjBL+w1.2i+o0.25i -F+gwhite+pthicker --FONT_ANNOT_PRIMARY=14p,Helvetica-Bold << EOF >> ${fig[4]}
S 0.1i T 0.07i red - 0.3i Ship
S 0.1i c 0.07i blue - 0.3i Satellite
EOF
gv ${fig[4]}

rm *.conf *.history *.x *.pg *.admit *.coh *gain *power *.phase