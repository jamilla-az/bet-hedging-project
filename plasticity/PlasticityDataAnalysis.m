%plasticity analysis - load in data
%jamilla akhund-zade
%created: 09-24-2019
%updated: 09-24-2019

%% load in data
load('plasticity.mat')

%% filter for activity
%% activity thresholding

thresh = 0.25; 
%remove fly less than 1hr  of trial is spent active
subsampleRate = 30; %30 seconds since centroid vector downsampled from 10hz to 1hz
pauseDist = 5;
pauseTime = 300; %300 seconds - 5 min, centroid vector downsampled as above

plasticity_fltd = activityThresholding(plasticity, plasticity(:,16), ...
             pauseDist, pauseTime, subsampleRate, thresh);
         
idx = string(plasticity_fltd(:,15)) == ''; %filter out non labeled flies
plasticity_fltd = plasticity_fltd(~idx,:);
%% convert to deg C
load('bostonTunnelTemps.mat');
plasticity_fltd = tempPrefToDegrees(plasticity_fltd, plasticity_fltd(:,16), ...
                plasticity_fltd(:,17), bostonTunnelTemps);
%col 1 is occupancy, col 20 is degC pref

%% load in filtered data

load('plasticity_fltd.mat')

%% violin plot of temp pref

data = plasticity_fltd;

tpref = cell2mat(data(:,20));
dist = cell2mat(data(:,2));
inctemp = cellstr(num2str(cell2mat(data(:,14))));

g = gramm('x', inctemp, 'y', tpref);
g.stat_violin('normalization','area','fill','transparent');
g.stat_summary('type','bootci','geom',{'point','black_errorbar'})
g.set_names('x','Incubator Temp (ºC)','y','Temp Pref (ºC)');
g.set_text_options('base_size' , 12,'label_scaling', 1.2);
%g.set_color_options('map', 'brewer1');
g.set_color_options('chroma',0,'lightness',50);
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();

%% violin plot of dist traveled

g = gramm('x', inctemp, 'y', dist);
g.stat_violin('normalization','area','fill','transparent');
g.stat_summary('type','bootci','geom',{'point','black_errorbar'})
g.set_names('x','Incubator Temp (ºC)','y','Distance Traveled (px)');
g.set_text_options('base_size' , 12,'label_scaling', 1.2);
g.set_color_options('map', 'brewer1');
%g.set_color_options('chroma',0,'lightness',50);
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();

%% BF test of differences of variance

vartestn(tpref,inctemp,'TestType','BrownForsythe')

%% matlab output for stan analysis

data = plasticity_fltd;

stanInput = table(cell2mat(data(:,1)), cell2mat(data(:,20)), cell2mat(data(:,2)),....
                  string(data(:,15)), cell2mat(data(:,14)), 'VariableNames',...
                  {'occ', 'degC','dist', 'line', 'inctemp'});
             
writetable(stanInput, 'plasticityStanInput_degC.csv');
