function out=hedgeGeographyAll(mu,va,weather,stationData,startIdx, endIdx)
% hedgeGeographyAll reads in geographic weather data one location at a time
% and attempts to fit b and d parameters for the seasonal weather at
% that location. If the parameters are fit, runs a bet-hedging scenario at
% this location and collects summary data of this location and the model
% performance here.
%=========================================================================
% Usage:
% out=hedgeGeography(mu,va,weather,stationData,fitModels,n)
% Inputs:
%       * mu = mean light choice probability
%       * va = variance in light choice probability
%       * weather = struct of weather data, e.g. wp in hedgeWeatherPack.mat
%       * stationData = structure containing weather station locations and
%            seasonal temperature normal data. Variable "stationData" in
%            hedgeStationData.mat
%       * startIdx, endIdx = station indices to attempt to fit
% Output, a cell array, with rows = stations and columns as follows
%       1) output of hedgeAnalytic for the calibrated adaptive tracking strategy
%       2) output of hedgeAnalytic for the calibrated bet-hedging strategy
%       3) bet-hedging advantage ((final BH pop - final AT pop)/final AT pop
%          in %)
%       4) latitude of station
%       5) longitude of station
%       6) season length in days
%       7) mean seasonal temperature
%       8) max temperature differential across season
%       9) calibrated b parameter
%       10)  calibrated d parameter

%unpack list of stations
stationList=stationData.stationLatLongLabels(startIdx:endIdx);
longLatList = stationData.stationLatLongs(startIdx:endIdx,:);
n = size(stationList,1);
%initialize output
out=cell(n,10);

% for number of attempted stations
for i=1:n
    
    %get name of current station, delete second character for NOAA
    %comparability
    targetStation=stationList{i};
    targetStation(2)=[];
    
    %scan for this station among list of all stations, break when found
    for j=1:length(stationData.stationTemperatureLabels)
        if isequal( stationData.stationTemperatureLabels{j},targetStation)
            break; %break if matches station name with 2nd char deleted
        elseif isequal( stationData.stationTemperatureLabels{j},stationList{i})
            break; %break if matches full station name
        end
    end
    
    %build the annual temp data month by month
    normals=[];
    normals=[normals stationData.stationTemperatureData(j,2:32)];
    normals=[normals stationData.stationTemperatureData(j+1,2:29)];
    normals=[normals stationData.stationTemperatureData(j+2,2:32)];
    normals=[normals stationData.stationTemperatureData(j+3,2:31)];
    normals=[normals stationData.stationTemperatureData(j+4,2:32)];
    normals=[normals stationData.stationTemperatureData(j+5,2:31)];
    normals=[normals stationData.stationTemperatureData(j+6,2:32)];
    normals=[normals stationData.stationTemperatureData(j+7,2:32)];
    normals=[normals stationData.stationTemperatureData(j+8,2:31)];
    normals=[normals stationData.stationTemperatureData(j+9,2:32)];
    normals=[normals stationData.stationTemperatureData(j+10,2:31)];
    normals=[normals stationData.stationTemperatureData(j+11,2:32)];
    % convert from °Fx10 to °C
    normals=(normals/10-32)*5/9;
    
    %if it gets to be more than 10°C at least once
    if sum(normals>=10)>1
        seasonStart=find(normals>=6.5);     %find first day of >6.5°C
        seasonStart=seasonStart(1);
        seasonEnd=find(normals>=10);        %find last day of <10°C
        seasonEnd=seasonEnd(end);
    else
        continue;
    end
    
    %define season by those endpoints
    normals=normals(seasonStart:seasonEnd);
    
    %stats on this season
    %normalsStats=[length(normals) nanmean(normals) max(normals)-min(normals)];
    
    %position of this station
    lati=longLatList(i,1);
    longi=longLatList(i,2);
    
    %calibrate the b and d parameters under an adaptive tracking assumption
    calibModel=hedgeBDCalibrate(mu,va,normals,weather,0.04,0.01,'end');
    
    if isnan(calibModel.b) %try with higher b/d rates
       calibModel=hedgeBDCalibrate(mu,va,normals,weather,0.65,0.058,'end');
    end
    
    %extract the weather data
    hedgeWeatherPack.tempHist=normals;
    hedgeWeatherPack.cloudCover=zeros(size(normals));
    
    %run the model under the bet-hedging strategy, and the extracted
    %weather data
    if ~isnan(calibModel.b) %non NaN birth rate
        hedgeRun=hedgeAnalytic(0,weather,mu,va,calibModel.b,calibModel.d,0,0,7,0,'pre',hedgeWeatherPack);
        %if the model attained a very low value (and perhaps a numerically
        %unstable value)
        if min(sum(hedgeRun.pops))<.001
            for j=1:3; out{i,j}=NaN;end;  %ignore these results
            out{i,4}=lati;
            out{i,5}=longi;
            out{i,6}=length(calibModel.normalSeason);
            out{i,7}=mean(calibModel.normalSeason);
            out{i,8}=max(calibModel.normalSeason)-min(calibModel.normalSeason);
            out{i,9}=calibModel.b;
            out{i,10}=calibModel.d;
        else %otherwise output the pieces into the final cell array
            out{i,1}=calibModel;
            out{i,2}=hedgeRun;
            out{i,3}=((sum(hedgeRun.pops(:,end))-sum(calibModel.modelRun.pops(:,end)))/sum(calibModel.modelRun.pops(:,end)))*100;
            out{i,4}=lati;
            out{i,5}=longi;
            out{i,6}=length(calibModel.normalSeason);
            out{i,7}=mean(calibModel.normalSeason);
            out{i,8}=max(calibModel.normalSeason)-min(calibModel.normalSeason);
            out{i,9}=calibModel.b;
            out{i,10}=calibModel.d;
        end
    else %for NaN b,d rates
       for j=1:3; out{i,j}=NaN;end;  %ignore these results
       out{i,4}=lati;
       out{i,5}=longi;
       out{i,6}=length(calibModel.normalSeason);
       out{i,7}=mean(calibModel.normalSeason);
       out{i,8}=max(calibModel.normalSeason)-min(calibModel.normalSeason);
       out{i,9}=calibModel.b;
       out{i,10}=calibModel.d;
    end
    

end