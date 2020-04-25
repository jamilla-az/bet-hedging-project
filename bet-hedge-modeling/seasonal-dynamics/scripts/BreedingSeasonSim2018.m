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
stationData = miamiData;

%empirical data - sort by sex of fly if you want
dayNums = replaceWeeksWithDays(CollectionWeeks, tempPref.miamilabels);
sex = string(tempPref.miamilabels(:,19));
tpref = tempPref.rescaledMiami;%(sex == 'M');
dayNumsbySex = dayNums;%(sex == 'M');

mu = mean(tpref);
va = var(tpref);

seasonStartTemp = 6.5;
seasonEndTemp = 10;

%simulated BH and AT mean pref dynamics
%Miami B/D needs to be calibrated on seasonal averages using
%calibratingBDrates.m
%Boston/Virginia - can calibrate B/D successfully on 2018 data
fit = hedgeRealSeason(mu, va, w, stationData, '2018',...
                      seasonStartTemp,seasonEndTemp,...
                      1.0332, 0.0647);               

%% plotting trajectories with with collection data overlaid
prefOverSeason = {fit{1,1}.prefHist.*12+18 ; fit{1,2}.prefHist.*12+18};%transform to degC
popOverSeason = {sum(fit{1,1}.pops,1); sum(fit{1,2}.pops,1)};
evoStrategy = {'BH','AT'};
seasonLength = fit{1,4};

% plot simulated data
g = gramm('x',seasonLength,'y',popOverSeason, 'color', evoStrategy);
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

%empirical data - sort by sex of fly
dayNums = replaceWeeksWithDays(CollectionWeeks, tempPref.bostonlabels);
numFliesPerWeek = sum(dayNums == dayNums');

figure
g1 = gramm('x', dayNums, 'y', numFliesPerWeek);
g1.geom_line();
g1.set_text_options('base_size' , 14, 'label_scaling', 1);
g1.set_names('x','Day','y','Number of Flies');
g1.axe_property('YLim',[0 Inf]);
g1.draw();
