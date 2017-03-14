proc import datafile='/home/jagarlka0/DM/rock_songs.xls'
out=songs dbms=xls replace; 
getnames=yes; 
run;

proc univariate data=songs noprint;
var plays;
histogram /kernel normal(noprint);
inset median mode normal(ksdpval)/position=ne;
run;

proc means mean median mode q1 q3 skewness max;
run;
