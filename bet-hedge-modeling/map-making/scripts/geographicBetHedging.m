%% geographic distribution of bet-hedging advantage 
% created by jamilla a created on 2019-09-06 updated on 2019-10-31

%% modeling BH advantage
%%
load('stationDataAll.mat'); %BH advantage calculated for 7501 stations using betHedgeAdvantageCalc.m
load('hedgeColorMaps.mat'); %colormaps for viz
load('hedgeStateBoundaries.mat'); %state boundaries for viz

load('hedgeWeatherPack.mat'); %Kain et al 2015 2007-2011 seasonal normals data
load('stationDataBatch.mat'); %Kain et al BH advantage for ~1500 weather stations
load('seasonalAverages.mat'); %climate normals for the seven sampling locations

%load in posterior estimates for means/vars of each sampling location 
%Berkeley (BE), Pasadena (CA), Boston (MA), Miami (FL), Philly (PA),
%Houston (TX), Charlottesville (VA) from Variability Expt data
%transfmean/var is transformed from degC metric to a 0-1 metric on a linear gradient
%mean/var is reported in degC
%load('siteMeansVars.mat')

%lat longs for all sampling locations
load('allSamplingLocations_LatLong.mat') ;
               
%% modeling BH advantage across all US stations with climate normal data

%filter out NaNs out of 7501 station sample
stationBatchAll_filt = stationBatchAll(~isnan(stationBatchAll(:,1)),:);
%% upload new state boundaries
bounds_48_PR = imread('North_america98_48&PR.png');
bounds_48_PR = bounds_48_PR(:,:,1);
bounds_48_PR = bounds_48_PR<255;

%scale map
heatmapPoints = [55 47;636 351; 610 56; 96 185; 135 40;...
    328 271; 494 279; 351 36; 651 347; 630 81];
boundaryPoints = [1 12; 627 351; 599 22; 46 166; 83 5;...
    296 262; 475 271; 321 1; 651 346; 622 51];

tform = fitgeotrans(boundaryPoints,heatmapPoints, 'affine');
reg_bounds = imwarp(bounds_48_PR,tform);

new_bounds = false(361, 661);
new_bounds(351-size(reg_bounds,1)+1:351,651-size(reg_bounds,2)+1:651) = reg_bounds; 
imshowpair(bounds_48_PR, new_bounds);
%% plot map
%scaled map colors
kayenta2=interp1([1 488 512 513 537 1024],...
    [0 0 1; 0 1 1; .25 0.45 0.45; 0.45 0.45 .25; 1 1 0; 1 0 0],1:1024);

sigma = [0.04 0; 0 0.04]; 
displayBool = [1 1 0 0];
hedgeMakeStationMap_new(stationBatchAll_filt, sigma, new_bounds,...
    kayenta2, displayBool);

%% spot checks of outliers
%north texas and oklahoma

load('stn_3001_4500.mat');
idx = find(cell2mat(stations3001_4500(:,3)) > 4);

%%
at_run = stations3001_4500{idx(1),1}.modelRun;
bh_run = stations3001_4500{idx(1),2};

%%
figure;
plot(sum(at_run.pops,1), 'LineWidth',2);
hold on
plot(sum(bh_run.pops,1),'LineWidth',2);
hold off
xlabel('Day Num','FontSize',14);
ylabel('Pop Size', 'FontSize',14);
legend('AT','BH');

%%
figure;
plot(at_run.prefHist,'LineWidth',2);
hold on
plot(bh_run.prefHist,'LineWidth',2);
hold off
xlabel('Day Num','FontSize',14);
ylabel('Preference', 'FontSize',14);

legend('AT','BH');
%% calc BH at a particular sampling location

% extract lat-longs of sampling locations
latLongs_sampleLoc = table2array(allSamplingLocationsLatLong(:,3:4));

%extract all station bh advantage data and lat-longs
latLongs = stationBatchAll_filt(:,2:3);
BvHs=log(stationBatchAll_filt(:,4));

%% 
%for each station in stationBatchAll_filt, evaluate the pdf of a bivariate normal
%distribution that is centered at the sampling location

BvHsToLoc = NaN(size(latLongs_sampleLoc,1),1);

for j=1:size(latLongs_sampleLoc,1)
    mu = latLongs_sampleLoc(j,:); %sampling location
    sigma = [0.04 0; 0 0.04]; %covariance matrix - how wide/symmetrical is the dist
    %calculate weights to the surrounding weather stations
    weightsToLoc = mvnpdf(latLongs,mu,sigma);
    %calculate bh adv at each sampling location given the surrounding weather stations
    BvHsToLoc(j) = sum(weightsToLoc.*BvHs)/sum(weightsToLoc);
end

allSamplingLocationsLatLong.BHadv = BvHsToLoc;