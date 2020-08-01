function out = hedgeRealSeason(mu,va,weather, stationData, year,...
                               startTemp,endTemp,...
                               varargin)
% hedgeRealSeason reads in station specific weather data and attempts to
% fit b and d parameters for the seasonal weather at that location. If the
% parameters are fit, runs a bet-hedging scenario at this location and
% collects summary data of this location and the model performance here.
%=========================================================================
% Usage: out=hedgeRealSeason(mu,va,weather,stationData,fitModels,n) Inputs:
%       * mu = mean light choice probability
%       * va = variance in light choice probability
%       * weather = struct of weather data, e.g. wp in
%       hedgeWeatherPack.mat, needed to run hedgeAnalytic
%       * stationData = specific station data: station name, lat/long,
%       temperature.
%       * startTemp/endTemp = what avg temp should be at start and end of
%       seasons
%       * varargin = specified birth and death rates if need be; use
%       hedgeBDCalibrate.m
% Output, a cell array, with columns as follows
%       1) output of hedgeAnalytic for the calibrated bet-hedging
%        strategy 
%       2) output of hedgeAnalytic for the calibrated adaptive tracking strategy 
%       3) final population size of the bet-hedging strategy 
%       4) length of the season in days 
%       5) station lat/longs 
%       6) stationName
%       7) seasonal temp smoothed by 2 month sliding window 
%       8) output of hedgeBDCalibrate or specified b/d parameters 
%       9) calibrated (specified) b parameter 
%       10) calibrated (specified) d parameter

 if strcmp(year,'2017') == 1
    normals = stationData.stationTemperatureData2017; 
 else
   normals = stationData.stationTemperatureData; 
 end
 
    %smooth over a 2month sliding window
    [smoothNormals,~] = smoothdata(normals,'movmean',60);
    
    %define season by those endpoints
    seasonStart = find(smoothNormals > startTemp,1,'first');
    seasonEnd = find(smoothNormals > endTemp,1,'last');

    
    %define season by those endpoints
    dayNum = 1:365;
    dayNum = dayNum(seasonStart:seasonEnd); %length of season
    normals=normals(seasonStart:seasonEnd); %seasonal temps
    dayNum(isnan(normals)) = []; %remove NaNs
    normals(isnan(normals)) = []; %remove NaNs
    
    %calibrate the b and d parameters under a adaptive tracking assumption
    
    if length(varargin) == 2
        calibModel = struct();
        calibModel.b = varargin{1};
        calibModel.d = varargin{2};
    else
        calibModel=hedgeBDCalibrate(mu,va,normals,weather,0.04,0.01,'end');
        if isnan(calibModel.b) == 1
           calibModel.b = 0.045;
           calibModel.d = 0.012;
        end
    end

    
    %extract the weather data
    hedgeWeatherPack.tempHist=normals;
    hedgeWeatherPack.cloudCover=zeros(size(normals)); %normals./normals*0; 3/7/2019 jamilla a
    
    %run the model under the bet-hedging strategy/adaptive tracking, and
    %the extracted weather data
    hedgeRun=hedgeAnalytic(0,weather,mu,va,calibModel.b,calibModel.d,0,0,7,0,'pre',hedgeWeatherPack);
    hedgeRun_at=hedgeAnalytic(1,weather,mu,va,calibModel.b,calibModel.d,0,0,7,0,'pre',hedgeWeatherPack);
    
    out{1,1} = hedgeRun;
    out{1,2} = hedgeRun_at;
    out{1,3} = sum(hedgeRun.pops(:,end))-100;
    out{1,4} = dayNum;
    out{1,5} = stationData.stationLatLongs;
    out{1,6} = stationData.stationLatLongLabels;
    out{1,7} = smoothNormals(seasonStart:seasonEnd);
    out{1,8} = calibModel;
    out{1,9} = calibModel.b;
    out{1,10} = calibModel.d;
    