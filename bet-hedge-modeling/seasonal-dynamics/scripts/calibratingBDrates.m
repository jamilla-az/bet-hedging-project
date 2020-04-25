%% calibrating birth/death (B/D) parameters
% created by jamilla a created on 2018-09-25 updated on 2020-04-23

%% Modeling Begins with B/D calibration
%% search results for b and d parameters
load('stationData2018.mat'); %temp data for 2018 (3 structs: FL, MA, VA)
load('seasonalTempPref_2018.mat'); %seasonal collection 2018 temp pref data for D.mel

load('hedgeWeatherPack.mat'); %Kain et al 2015 2007-2011 seasonal normals data
load('seasonalAverages.mat'); %climate normals 1981-2010 for the seven locations

load('CollectionWeeks.mat'); %seasonal collection weeks and days for 2018

%load('stationDataBatch.mat') %~1500 calibrated stations from Kain et al
%% load in seasonal averages
field = 'miami';

%demarcate the fly season
seasonStart = find(wAverages.(field).stationTemperatureData >= 6.5, 1,'first');
seasonEnd = find(wAverages.(field).stationTemperatureData >= 10, 1,'last');
flySeason = wAverages.(field).stationTemperatureData;

%% make weather struct
weather.flySeasonInterval=seasonStart:seasonEnd;
weather.normal=flySeason;

%% B D calibration using hedgeBDCalibrate hill-climbing algorithm

%mu = 0.4354; %mean of FL, MA, VA means
%va = 0.0148; %mean of FL, MA, VA vars

mu = mean(tempPref.rescaledMiami);
va = var(tempPref.rescaledMiami);

bCurrent = 0.65; %0.04;
dCurrent = 0.058; %0.01;
BDoutput = hedgeBDCalibrate(mu, va, flySeason(seasonStart:seasonEnd), ...
    weather, bCurrent, dCurrent,'end');

shadeDiff = 7;

b=BDoutput.b_list(end);
d=BDoutput.d_list(end);

at_run=hedgeAnalytic(1,weather,mu,va,b,d,0,0,shadeDiff,0,'001',0);
bh_run=hedgeAnalytic(0,weather,mu,va,b,d,0,0,shadeDiff,0,'001',0); 

disp(sum(at_run.pops(:,end)))
disp(sum(bh_run.pops(:,end)))
disp(log(sum(bh_run.pops(:,end))/sum(at_run.pops(:,end))));
%disp(sum(BDoutput.modelRun.pops(:,end)))
%disp(mu - at_run.prefHist(end))

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

%%
figure;
clims=[0 10];
imagesc(bh_run.tau);
%imagesc(batch{3,2}.pops, clims);
colorbar

%% plot tau over time for 500 random thermal preferences
figure;
cmap = parula(101);
wt = at_run.pops(:,1);
rand_pref = randsample(1:101, 500, true, wt);
for i=1:length(rand_pref)
    plot(at_run.tau(rand_pref(i),:),'LineWidth',2,'Color', cmap(rand_pref(i),:))
    hold on
end
hold off
colorbar;
set(gca,'FontSize',12);
ylim([5 35]);
xlabel('Day Num','FontSize',14);
ylabel('Thermal Experience (tau)', 'FontSize',14);

%% plot distribution of std in thermal experience
figure;
plot(nanstd(at_run.tau,1), 'LineWidth',2);
xlabel('Day Num','FontSize',14);
ylabel('St Dev Thermal Experience', 'FontSize',14);
ylim([0 3]);
%% plot normals for diff locations
figure;
plot(wAverages.miami.stationTemperatureData,'LineWidth',2);
hold on
plot(wAverages.charlot.stationTemperatureData,'LineWidth',2);
plot(wAverages.boston.stationTemperatureData,'LineWidth',2);
hold off
xlabel('Day Num','FontSize',14);
ylabel('Avg Temp ºC', 'FontSize',14);
legend('FL','VA','MA');

%% plot raw and adjusted normals
figure;
plot(wAverages.miami.stationTemperatureData,'LineWidth',2);
hold on
plot(wAverages.miami.stationTemperatureData+7,'LineWidth',2);
%plot(wAverages.boston.stationTemperatureData,'LineWidth',2);
hold off
xlabel('Day Num','FontSize',14);
ylabel('Avg Temp ºC', 'FontSize',14);
legend('Miami','Miami+7');

%% plot dist of average temps for all calibrated stations
figure;
histogram(cell2mat(batch(:,7)));
hold on
line([mean(wAverages.miami.stationTemperatureData) mean(wAverages.miami.stationTemperatureData)],...
    [0 200],'Color','red', 'LineWidth',2);
line([mean(wAverages.boston.stationTemperatureData) mean(wAverages.boston.stationTemperatureData)],...
    [0 200],'Color', 'black','LineWidth',2);
line([mean(wAverages.charlot.stationTemperatureData) mean(wAverages.charlot.stationTemperatureData)],...
    [0 200],'LineWidth',2);
hold off
xlabel('Avg Seasonal Temp','FontSize',14);
legend('dist','FL','MA','VA');
