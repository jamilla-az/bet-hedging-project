%% modeling temperature preference given 2018 breeding season
% created by jamilla a created on 2018-09-25 updated on 2019-10-31

%% load in temp pref and station temp data
load('stationData2018.mat'); %temp data for 2018
load('seasonalTempPref_2018.mat'); %seasonal collection 2018 temp pref data for D.mel

load('hedgeWeatherPack.mat'); %Kain et al 2015 2007-2011 seasonal normals data
load('seasonalAverages.mat'); %normals up to 2017 for the six locations

load('CollectionWeeks.mat'); %seasonal collection weeks and days for 2018

%% calculated AT vs BH trajectories for 2018

%stationData
stationData = charlotData;

%empirical data - sort by sex of fly if you want
dayNums = replaceWeeksWithDays(CollectionWeeks, tempPref.virginialabels);
sex = string(tempPref.virginialabels(:,19));
tpref = tempPref.rescaledVirginia;%(sex == 'M');
dayNumsbySex = dayNums;%(sex == 'M');

mu = mean(tpref);
va = var(tpref);

seasonStartTemp = 6.5;
seasonEndTemp = 10;

%simulated BH and AT mean pref dynamics
%Miami B/D needs to be calibrated on seasonal averages using
%calibratingBDrates.m
%%
fit = hedgeRealSeason(mu, va, w, stationData, '2018',...
                      seasonStartTemp,seasonEndTemp,...
                      1.0332, 0.0647);  
%% Boston/Virginia - can calibrate B/D successfully on 2018 data
fit = hedgeRealSeason(mu, va, w, stationData, '2018',...
                      seasonStartTemp,seasonEndTemp);               

%% plotting trajectories with with collection data overlaid
prefOverSeason_charlot = {fit{1,1}.prefHist.*12+18 ; fit{1,2}.prefHist.*12+18};%transform to degC
popOverSeason_charlot = {sum(fit{1,1}.pops,1); sum(fit{1,2}.pops,1)};
evoStrategy = {'BH','AT'};
seasonLength_charlot = fit{1,4};

%% plot predicted population data
g = gramm('x',seasonLength_boston,'y',popOverSeason_boston, ...
          'linestyle', evoStrategy);
g.geom_line();
g.set_color_options('map', 'd3_10'); %blue
g.set_text_options('base_size' , 14, 'label_scaling', 1,...
                   'legend_title_scaling',0.9,'legend_scaling',0.9);
g.set_names('linestyle','Strategy');
g.draw();

g.update('x',seasonLength_charlot,'y',popOverSeason_charlot,...
         'linestyle', evoStrategy);
g.geom_line();
g.set_color_options('map', 'brewer1'); %red
g.set_text_options('base_size' , 14, 'label_scaling', 1,...
                   'legend_title_scaling',0.9,'legend_scaling',0.9);
g.set_names('linestyle','Strategy');
g.draw();

g.update('x',seasonLength_miami,'y',popOverSeason_miami,...
         'linestyle', evoStrategy);
g.geom_line();
g.set_color_options('map', 'brewer2'); %light green
g.set_text_options('base_size' , 14, 'label_scaling', 1,...
                   'legend_title_scaling',0.9,'legend_scaling',0.9);
g.set_names('linestyle','Strategy');
g.axe_property('YScale','log')
%g.axe_property('YLim',[0.3 0.4]);
g.set_names('x','Day of the Year','y','Population');
g.draw();

%% plot seasonal dynamics
g = gramm('x',seasonLength_boston,'y',prefOverSeason_boston, 'color', evoStrategy);
g.geom_line();
g.set_color_options('map', 'brewer1');
g.set_text_options('base_size' , 14, 'label_scaling', 1,...
                   'legend_title_scaling',0.9,'legend_scaling',0.9);
g.set_names('color','Strategy');
%g.axe_property('YScale','log')
%g.axe_property('YLim',[0.3 0.4]);
g.set_names('x','Day of the Year','y','Thermal Preference');
g.draw();

%overlay empirical data
g.update('x', dayNumsbySex, 'y', tpref.*12+18);
g.geom_jitter('dodge', 0.7, 'alpha', 0.1);
g.stat_summary('type', 'sem','geom',{'point','errorbar'}, 'dodge',0.7);
g.set_color_options('chroma',0,'lightness',50);
g.set_text_options('base_size' , 14, 'label_scaling', 1);
g.set_names('x','Day of the Year','y','Thermal Preference');
g.axe_property('YLim',[18 30]);
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();

%% save fig as pdf
print('Miami2010Model_SeasonalCollect2018','-dpdf','-fillpage')

%% heatmap of temperatures over the breeding season 2018
%stationData
stationData = bostonData;

figure
colormap(jet);
image(stationData.stationTemperatureData(175:301)','CDataMapping','scaled');
colorbar
caxis([6 30])
yticks([])
xticks([])
fig = gcf;
fig.PaperOrientation = 'landscape';
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 3.75 11 1];
print('Boston2018Temps_day175_301','-dpdf')

%% smoothed temperatures over breeding season
tempByDay = normals; %smoothNormals(seasonLength);

figure
g1 = gramm('x', seasonLength, 'y', tempByDay, 'color', tempByDay);
g1.geom_line();
g1.set_continuous_color('colormap','hot');
g1.set_text_options('base_size' , 14, 'label_scaling', 1);
g1.set_names('x','Day','y','Average Temperature (ºC)');
g1.draw();

%% plot temp pref probability heat map in style of Kain et al Figure 5A
load('hedgeColorMaps.mat');
figure
colormap(blackbody);
image(calibBD.charlot2010.modelRun.pops,'CDataMapping','scaled');
colorbar
yticklabels(string(1:0.01:0))

%% plot sampling over time

%empirical data - collections
dayNums_boston = replaceWeeksWithDays(CollectionWeeks, tempPref.bostonlabels);
numFliesPerWeek_boston = sum(dayNums_boston == dayNums_boston');
[uniqDays_boston,idx, ~] = unique(dayNums_boston,'stable');
boston_tbl = table(uniqDays_boston, numFliesPerWeek_boston(idx)',...
                    'VariableNames',{'days' 'boston_counts'});

dayNums_charlot = replaceWeeksWithDays(CollectionWeeks, tempPref.virginialabels);
numFliesPerWeek_charlot = sum(dayNums_charlot == dayNums_charlot');
[uniqDays_charlot,idx, ~] = unique(dayNums_charlot,'stable');
charlot_tbl = table(uniqDays_charlot, numFliesPerWeek_charlot(idx)',...
                    'VariableNames',{'days' 'charlot_counts'});

dayNums_miami = replaceWeeksWithDays(CollectionWeeks, tempPref.miamilabels);
numFliesPerWeek_miami = sum(dayNums_miami == dayNums_miami');
[uniqDays_miami,idx, ~] = unique(dayNums_miami,'stable');
miami_tbl = table(uniqDays_miami, numFliesPerWeek_miami(idx)',...
                    'VariableNames',{'days' 'miami_counts'});

 
temp = outerjoin(boston_tbl,charlot_tbl, 'MergeKeys',true); %join on days
combTable = outerjoin(temp, miami_tbl, 'MergeKeys',true);

%%
figure
g1 = gramm('x', combTable.days, 'y', combTable.boston_counts);
g1.geom_line();
g1.draw();
g1.update('x', combTable.days, 'y', combTable.charlot_counts);
g1.geom_line();
g1.draw();
g1.update('x', combTable.days, 'y', combTable.miami_counts);
g1.geom_line();
g1.set_text_options('base_size' , 14, 'label_scaling', 1);
g1.set_names('x','Day','y','Number of Flies');
%g1.axe_property('YScale','log');
g1.draw();