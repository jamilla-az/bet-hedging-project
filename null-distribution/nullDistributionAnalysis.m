%% create null distribution for temp pref occupancy
%created by jamilla a
%created on 03-20-2019
%updated on 03-20-2019

%% load in observed data tracks (unfiltered)
%variability data
load('variability_unfltd.mat');

%filter out blanks 
variability = variability_unfltd(cell2mat(variability_unfltd(:,2)) > 2000,:);
variability = variability(~isnan(cell2mat(variability(:,1))),:);
variability = variability(string(variability(:,15)) ~= "",:);

%filter for a particular line just to start
lines = unique(string(variability(:,15)));

%MA_11_38 for example
var_line = variability(string(variability(:,15)) == "MA_11_38",:);

%% create bout array

%create roi bounds and centers (left, right, centerL, centerR)
roiBounds = splitROI(cell2mat(var_line(:,4:7)), cell2mat(var_line(:,8:9)));

%divide tracks into bouts
[hotBouts, coldBouts, middleBouts] = createBoutArray(var_line(:,3), ...
                                    roiBounds(:,3:4), var_line(:,16));
                                
%% create null distribution
% create N_IT populations of simulated flies (pop size nFlies)
n_it = 100;
subsampleRate = 30;
pauseDist = 5;
pauseThresh = 300;

simFlyTracks = nullDistribution(hotBouts, coldBouts, middleBouts, n_it, ...
                                subsampleRate, pauseDist, pauseThresh);
                            
%% load in filtered data
load('variability_fltd.mat');

%filter for a particular line just to start
lines = unique(string(variability(:,15)));

%MA_11_38 for example
var_line = variability(string(variability(:,15)) == "MA_11_38",:);

%store observed and simulated parameters
simFlyTracks.fltd.observed_data = var_line;
simFlyTracks.fltd.observed_var = var(cell2mat(var_line(:,1)));
simFlyTracks.fltd.observed_mean = mean(cell2mat(var_line(:,1)));
simFlyTracks.fltd.observed_median = median(cell2mat(var_line(:,1)));


simFlyTracks.fltd.simulated_mean_pop = cellfun(@mean, simFlyTracks.fltd.simulated_occupancy);
simFlyTracks.fltd.simulated_mean = mean(simFlyTracks.fltd.simulated_mean_pop);

simFlyTracks.fltd.simulated_median_pop = cellfun(@median, simFlyTracks.fltd.simulated_occupancy);
simFlyTracks.fltd.simulated_median = mean(simFlyTracks.fltd.simulated_median_pop);

%%
load('MA_11_38_nullDist_BoutResampling.mat');

%% transform sim occupancy to temp pref

%scale to average min and max of the tunnel temps in observed data
minTpref = mean(cell2mat(simFlyTracks.fltd.observed_data(:,22)));
maxTpref = mean(cell2mat(simFlyTracks.fltd.observed_data(:,21)));

simFlyTracks.fltd.simulated_tprefDegC = cell(100,1);
%calculate tpref in deg C for all simulated flies
for k = 1:length(simFlyTracks.fltd.simulated_occupancy)
    track = simFlyTracks.fltd.simulated_occupancy{k};
    simFlyTracks.fltd.simulated_tprefDegC{k} = track*maxTpref + (1-track)*minTpref;
end 

%% load in observed data tracks (unfiltered) - SomA
load('SomA_trpA1_quant_boxlabel.mat', 'SomAtrpA1quant')
load('bostonTunnelTemps.mat');

%filter for SomA flies and day 1 data only
tempPref = SomAtrpA1quant(string(SomAtrpA1quant(:,15)) == 'SomA',:); %SomA only
% tempPref = tempPrefToDegrees(tempPref, tempPref(:,16), tempPref(:,20),...
%                                 bostonTunnelTemps);

tempPref_d1 = tempPref(cell2mat(tempPref(:,12)) == 1,:);

%filter out blanks 
tempPref_d1 = tempPref_d1(cell2mat(tempPref_d1(:,2)) > 2000,:);
tempPref_d1 = tempPref_d1(~isnan(cell2mat(tempPref_d1(:,1))),:);
tempPref_d1 = tempPref_d1(string(tempPref_d1(:,15)) ~= "",:);

%subsample centroid data to 1Hz
for i=1:length(tempPref_d1)
    idx = 1:10:length(tempPref_d1{i,3}); %subsample to 1Hz to lower file size
    tempPref_d1{i,3} = tempPref_d1{i,3}(idx);
end
%% create bout array

%create roi bounds and centers (left, right, centerL, centerR)
roiBounds = splitROI(cell2mat(tempPref_d1(:,4:7)), cell2mat(tempPref_d1(:,8:9)));

%divide tracks into bouts
[hotBouts, coldBouts, middleBouts] = createBoutArray(tempPref_d1(:,3), ...
                                    roiBounds(:,3:4), tempPref_d1(:,16));
                                
%% create null distribution
% create N_IT populations of simulated flies (pop size nFlies)
n_it = 100;
subsampleRate = 30;
pauseDist = 5;
pauseThresh = 300;

simFlyTracks = nullDistribution(hotBouts, coldBouts, middleBouts, n_it, ...
                                subsampleRate, pauseDist, pauseThresh);
         
%% store observed and simulated parameters
thresh = 0.25; 
%remove fly less than 1hr  of trial is spent active
subsampleRate = 30;
pauseDist = 5;
pauseTime = 300;

tempPref_fltd = activityThresholding(tempPref_d1, tempPref_d1(:,16),...
                        pauseDist, pauseTime, subsampleRate,...
                        thresh); %activity threshold obs data
tempPref_fltd = tempPrefToDegrees(tempPref_fltd, tempPref_fltd(:,16), tempPref_fltd(:,20),...
                                bostonTunnelTemps); %convert obs data to degC


simFlyTracks.fltd.observed_data = tempPref_fltd;
simFlyTracks.fltd.observed_var = var(cell2mat(tempPref_fltd(:,1)));
simFlyTracks.fltd.observed_mean = mean(cell2mat(tempPref_fltd(:,1)));
simFlyTracks.fltd.observed_median = median(cell2mat(tempPref_fltd(:,1)));


simFlyTracks.fltd.simulated_mean_pop = cellfun(@mean, simFlyTracks.fltd.simulated_occupancy);
simFlyTracks.fltd.simulated_mean = mean(simFlyTracks.fltd.simulated_mean_pop);

simFlyTracks.fltd.simulated_median_pop = cellfun(@median, simFlyTracks.fltd.simulated_occupancy);
simFlyTracks.fltd.simulated_median = mean(simFlyTracks.fltd.simulated_median_pop);

%% transform sim occupancy to temp pref

%scale to average min and max of the tunnel temps in observed data
minTpref = mean(cell2mat(simFlyTracks.fltd.observed_data(:,24)));
maxTpref = mean(cell2mat(simFlyTracks.fltd.observed_data(:,23)));

simFlyTracks.fltd.simulated_tprefDegC = cell(100,1);
%calculate tpref in deg C for all simulated flies
for k = 1:length(simFlyTracks.fltd.simulated_occupancy)
    track = simFlyTracks.fltd.simulated_occupancy{k};
    simFlyTracks.fltd.simulated_tprefDegC{k} = track*maxTpref + (1-track)*minTpref;
end 

%%
load('SomA_null_dist_sampling.mat');
%% plotting
%use ksdensity with bootstrap resampling and areaBar to give the shaded
%95CI

%% store kde vals for simulated fly tracks
x = linspace(18, 30); %pick standard set of points
kde_sim = NaN(100,100); %make empty matrix to fill in

%calculate kde over x for all simulated tracks
for k = 1:length(simFlyTracks.fltd.simulated_tprefDegC)
    [kde_sim(k,:), ~] = ksdensity(simFlyTracks.fltd.simulated_tprefDegC{k}, x);
end 

%% store kde vals for observed data - resampled
x = linspace(18, 30); %pick standard set of points
kde_obs = NaN(100,100); %make empty matrix to fill in

for k = 1:100
    boot_sample = datasample(cell2mat(simFlyTracks.fltd.observed_data(:,22)),...
                             length(cell2mat(simFlyTracks.fltd.observed_data(:,22))));                   
    [kde_obs(k,:), ~] = ksdensity(boot_sample, x);
end 

%% plotting

%calculate error (2 std) on kde_sim and kde_obs at each point in x

kde_sim_error = std(kde_sim, 0, 1);
kde_obs_error = std(kde_obs, 0, 1);

figure;
areaBar(x, mean(kde_sim, 1), 2*kde_sim_error, [0.4 0.4 0.4], [0.8 0.8 0.8])
hold on
areaBar(x, mean(kde_obs, 1), 2*kde_obs_error, [0 0 1], [0.8 0.8 1])
ylim([0,1])
hold off

%% p-value

[h,p] = kstest2(mean(kde_sim, 1), mean(kde_obs, 1))



