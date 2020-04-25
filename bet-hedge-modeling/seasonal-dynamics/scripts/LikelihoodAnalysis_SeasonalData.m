%% calculate BH or AT likelihoood for collected seasonal data
% jamilla a
% created 2018-09-12
% updated 2019-10-31

%% load in temp pref and station temp data
load('stationData2018.mat'); %temp data for 2018
load('seasonalTempPref_2018.mat'); %seasonal collection 2018 temp pref data for D.mel

load('hedgeWeatherPack.mat'); %Kain et al 2015 2007-2011 seasonal normals data

load('CollectionWeeks.mat'); %seasonal collection weeks and days for 2018

%% load in collection weeks
%convert to yyyymmdd format and then to double
for i = 1:length(CollectionWeeks)
    t = ['0' char(string(CollectionWeeks(i,1)))];
    CollectionWeeks{i,1} = str2double(datestr(datenum(t,'mm/dd/yyyy'),...
                            'yyyymmdd'));
end

%% calc AT vs BH trajectories over the collection weeks - Boston

%stationData
stationData = bostonData;

%empirical data - sort by sex of fly
dayNums = replaceWeeksWithDays(CollectionWeeks, tempPref.bostonlabels);
sex = string(tempPref.bostonlabels(:,19));
tpref = tempPref.rescaledBoston;%(sex == 'M');
dayNumsbySex = dayNums;%(sex == 'M');

mu = mean(tpref);
va = var(tpref);
sigma = sqrt(va);

seasonStartTemp = 6.5;
seasonEndTemp = 10;

%simulated trajectories - by sex stationData = Data;
fit = hedgeRealSeason(mu, va, w, stationData, '2018',...
                      seasonStartTemp,seasonEndTemp);

bhmeanpref = fit{1,1}.prefHist; %extract mean preference over fly season
atmeanpref = fit{1,2}.prefHist; 

%% bootstrap data to calc dist of logLiks

bostonLogLik.Bootstrp = logLikBootstrap(bhmeanpref, atmeanpref,...
                       tpref, dayNums, fit{1,4}, sigma, 1000);


%% calculate log likelihood

bostonLogLik.all = calculateLogLikelihood(bhmeanpref, atmeanpref,...
                       tpref, dayNums, fit{1,4}, sigma);
                 

%% plot dist of log liks

g = gramm('x', bostonLogLik.Bootstrp.ratio);
g.stat_density();
g.geom_vline('x', sum(bostonLogLik.all(:,3))); 
%g.axe_property('XLim', [-30 10]);
g.set_names('x', 'log likelihood ratio')
g.set_text_options('base_size', 16);
g.draw;
%g.export('file_name','MiamiLogLikRatio_Bootstrp', 'file_type', 'pdf')

%% calc AT vs BH trajectories over the collection weeks - Virginia

%stationData
stationData = charlotData;

%empirical data - sort by sex of fly if you like
dayNums = replaceWeeksWithDays(CollectionWeeks, tempPref.virginialabels);
sex = string(tempPref.virginialabels(:,19));
tpref = tempPref.rescaledVirginia;%(sex == 'M');
dayNumsbySex = dayNums;%(sex == 'M');

mu = mean(tpref); %observed data
va = var(tpref);
sigma = sqrt(va);

seasonStartTemp = 6.5;
seasonEndTemp = 10;

%simulated trajectories - by sex stationData = Data;
fit = hedgeRealSeason(mu, va, w, stationData, '2018',...
                      seasonStartTemp,seasonEndTemp);

bhmeanpref = fit{1,1}.prefHist; %extract mean preference over fly season
atmeanpref = fit{1,2}.prefHist; 

%% bootstrap data to calc dist of logLiks

virginiaLogLik.Bootstrp = logLikBootstrap(bhmeanpref, atmeanpref,...
                       tpref, dayNums, fit{1,4}, sigma, 1000);

%% calc log lik
virginiaLogLik.all =  calculateLogLikelihood(bhmeanpref, atmeanpref,...
                       tpref, dayNums, fit{1,4}, sigma); 

%% plot dist of log liks

g = gramm('x', virginiaLogLik.Bootstrp.ratio);
g.stat_density();
g.geom_vline('x', sum(virginiaLogLik.all(:,3))); 
%g.axe_property('XLim', [-30 10]);
g.set_names('x', 'log likelihood ratio')
g.set_text_options('base_size', 16);
g.draw;
%g.export('file_name','MiamiLogLikRatio_Bootstrp', 'file_type', 'pdf')


%% calc AT vs BH trajectories over the collection weeks - Miami
%stationData
stationData = miamiData;

%empirical data - sort by sex of fly if you like
dayNums = replaceWeeksWithDays(CollectionWeeks, tempPref.miamilabels);
sex = string(tempPref.miamilabels(:,19));
tpref = tempPref.rescaledMiami;%(sex == 'M');
dayNumsbySex = dayNums;%(sex == 'M');

mu = mean(tpref); %observed data
va = var(tpref);
sigma = sqrt(va);

seasonStartTemp = 6.5;
seasonEndTemp = 10;

%simulated trajectories - by sex stationData = Data;
%b,d calculated using climate normals not 2018 data
fit = hedgeRealSeason(mu, va, w, stationData, '2018',...
                      seasonStartTemp,seasonEndTemp,...
                      1.0332, 0.0647);%,...
                      %calibDB_new.miami2010_log_Obs_a4.b,...
                      %calibDB_new.miami2010_log_Obs_a4.d);

bhmeanpref = fit{1,1}.prefHist; %extract mean preference over fly season
atmeanpref = fit{1,2}.prefHist; 


%% bootstrap data to calc dist of logLiks

miamiLogLik.Bootstrp = logLikBootstrap(bhmeanpref, atmeanpref,...
                       tpref, dayNums, fit{1,4}, sigma, 1000);


%% calc log lik
miamiLogLik.all =  calculateLogLikelihood(bhmeanpref, atmeanpref,...
                       tpref, dayNums, fit{1,4}, sigma); 


%% plot dist of log liks

g = gramm('x', miamiLogLik.Bootstrp.ratio);
g.stat_density();
g.geom_vline('x', sum(miamiLogLik.all(:,3))); 
%g.axe_property('XLim', [-30 10]);
g.set_names('x', 'log likelihood ratio')
g.set_text_options('base_size', 16);
g.draw;
%g.export('file_name','MiamiLogLikRatio_Bootstrp', 'file_type', 'pdf')

