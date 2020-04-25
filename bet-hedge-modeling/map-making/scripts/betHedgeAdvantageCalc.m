function betHedgeAdvantageCalc(startIdx,endIdx) %load these from command line
 
%wrapper function for batch submission to cluster of `hedgeGeographyAll.m`

load('hedgeStationData.mat');
load('hedgeWeatherPack.mat');

mu = 0.4354; %mean of FL, MA, VA means (seasonal collections)
va = 0.0148; %mean of FL, MA, VA vars (seasonal collections)

stations = hedgeGeographyAll(mu,va,w,stationData,startIdx, endIdx);

filename = sprintf('stn_%d_%d',startIdx, endIdx);
save(filename,'stations');
exit;