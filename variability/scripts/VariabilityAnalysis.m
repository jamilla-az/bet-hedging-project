%% geographic variability analysis - analyze data
%jamilla akhund-zade
%created: 03-14-2019
%updated: 05-13-2019

%% load in variability data array
load('variability_unfltd.mat'); %3/14 - Nov and Dec 2018 data only
%%
load('variability2019_unfltd.mat'); % Jan 2019 data only
%% 
load('variabilityApr2019_unfltd.mat'); %Apr 2019 data only
%% activity thresholding

thresh = 0.25; 
%remove fly less than 1hr  of trial is spent active
subsampleRate = 30; %30 seconds since centroid vector downsampled from 10hz to 1hz
pauseDist = 5;
pauseTime = 300; %300 seconds - 5 min, centroid vector downsampled as above

variability = activityThresholding(variabilityApr2019, variabilityApr2019(:,16), ...
             pauseDist, pauseTime, subsampleRate, thresh);
         
idx = string(variability(:,15)) == ''; %filter out non labeled flies
variability = variability(~idx,:);
%% convert to deg C
load('bostonTunnelTemps.mat');
variability = tempPrefToDegrees(variability, variability(:,16), ...
                variability(:,17), bostonTunnelTemps);
%col 1 is occupancy, col 20 is degC pref

%% load filtered data
load('variability_fltd.mat');
load('variability2019_fltd.mat');
load('variabilityApr2019_fltd.mat');

%% plot sample tracks
%idx = 136;%very warm
idx = 65; %very cold
plot4hrTracks(variability(idx,:), 300, variability(idx,16))

%% create location origin vector

origin = string(variabilityApr2019_fltd(:,15));
origin = extractBefore(origin, 3);

%fix VA label
idx = origin == 'CM';
origin(idx) = repelem('VA', sum(idx),1);

%fix FL labels
idx = origin == 'MI';
origin(idx) = repelem('FL', sum(idx),1);

originApr2019 = cellstr(origin);
%% violin plots
data = variability2019_fltd;

tpref = cell2mat(data(:,20));
dist = cell2mat(data(:,2));
line = cellstr(data(:,15));

lineOrder = unique(string(data(:,15)));
%lineOrder = lineOrder([1:4,7:10,5:6,11:12,13:16]);

g = gramm('x', line, 'y', tpref, 'color',...
          origin2019);
g.stat_violin('normalization','area','fill','transparent');
g.set_names('x','Lines','y','Temp Pref (ºC)','color','Origin');
g.set_text_options('base_size' , 10,'label_scaling', 1.2);
g.set_order_options('x', lineOrder);
g.set_color_options('map', 'brewer1');
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();


%% std summary plots
data = variability2019_fltd;

tpref = cell2mat(data(:,20));
dist = cell2mat(data(:,2));
line = cellstr(data(:,15));

lineOrder = unique(string(data(:,15)));
%lineOrder = lineOrder([1:4,7:10,5:6,11:12,13:16]);

g = gramm('x', line, 'y', tpref, 'color',...
          origin2019);
g.stat_summary('type', 'std','geom',{'point','errorbar'},'dodge',0.7);
g.set_names('x','Lines','y','Temp Pref (ºC)','color','Origin');
g.set_text_options('base_size' , 10,'label_scaling', 1.2);
g.set_order_options('x', lineOrder);
g.set_color_options('map', 'brewer1');
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();

%% save fig as pdf
print('variability_2019only','-dpdf','-fillpage')

%% scatterplot of tpref vs dist traveled
%% data
data = variabilityApr2019_fltd;

groupTpref = groupStats(cell2mat(data(:,20)),string(data(:,15)), ...
    unique(string(data(:,15))));

groupDist = groupStats(cell2mat(data(:,2)),string(data(:,15)), ...
    unique(string(data(:,15))));

lineOrder = unique(string(data(:,15)));
uniqOrigin = extractBefore(lineOrder, 3);

%fix VA label
idx = uniqOrigin == 'CM';
uniqOrigin(idx) = repelem('VA', sum(idx),1);

%fix FL labels
idx = uniqOrigin == 'MI';
uniqOrigin(idx) = repelem('FL', sum(idx),1);

uniqOrigin = cellstr(uniqOrigin);

%% plot
g = gramm('x', groupTpref.std, 'y', groupDist.mean, 'color', uniqOrigin);
g.geom_point();
g.set_point_options('base_size', 7);
g.set_text_options('base_size' , 12,'label_scaling', 1.2);
g.set_names('x','Temp Pref (ºC) St Dev','y','Total px traveled','color','Origin');
g.set_color_options('map', 'brewer1');
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');

g.draw();

%% plot deviations from mean by location (combining the lines)
tpref = centerMean(cell2mat(variability(:,20)), string(variability(:,15)), ...
    unique(string(variability(:,15)))); %centered tpref

g = gramm('x', origin2018, 'y', tpref, 'color',...
          origin2018);
%g.stat_violin('normalization','area','fill','transparent');
g.stat_summary('type', 'std','geom',{'point','errorbar'},'dodge',0.7);
g.set_names('x','Origin','y','Temp Pref (ºC) Dev from Mean','color','Origin');
g.set_text_options('base_size' , 10,'label_scaling', 1.2);
g.set_color_options('map', 'brewer1');
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();

%% std summary plots - MA_11_38 and MA_3_33 retested lines
data1 = variability(string(variability(:,15)) == 'MA_11_38'|...
                    string(variability(:,15)) == 'MA_3_33',:);
                        
data2 = variability2019_fltd(string(variability2019_fltd(:,15)) == 'MA_11_38'|...
                            string(variability2019_fltd(:,15)) == 'MA_3_33',:);

tpref = [cell2mat(data1(:,20));cell2mat(data2(:,20))];
dist = [cell2mat(data1(:,2));cell2mat(data2(:,2))];
line = [cellstr(data1(:,15));cellstr(data2(:,15))];

lineOrder = unique(string(line));
%lineOrder = lineOrder([1:4,7:10,5:6,11:12,13:16]);
batch = cellstr([repelem('Dec',length(data1),1);repelem('Jan',length(data2),1)]);


g = gramm('x', line, 'y', tpref, 'color',...
          batch);
g.stat_summary('type', 'sem','geom',{'point','errorbar'},'dodge',0.7);
g.set_names('x','Lines','y','Temp Pref (ºC)','color','Batch');
g.set_text_options('base_size' , 10,'label_scaling', 1.2);
g.set_order_options('x', lineOrder);
g.set_color_options('map', 'brewer1');
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();



%% save temp pref occupancy, dist traveled, line/location info for Stan Analysis

data = variabilityApr2019_fltd;

stanInput = table(cell2mat(data(:,1)), cell2mat(data(:,20)), cell2mat(data(:,2)),....
                  string(data(:,15)), originApr2019, 'VariableNames',...
                  {'occ', 'degC','dist', 'line', 'origin'});
             
writetable(stanInput, 'variabilityApr2019StanInput_degC.csv');