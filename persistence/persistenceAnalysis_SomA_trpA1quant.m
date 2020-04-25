%persistence analysis (10/31 - 11/3) - SomA trpA1 quantification
%jamilla akhund-zade
%created: 11-02-2018
%last updated: 04-22-2020

%% load raw data
cd Lab_Lines
cd Lab_Line_Persistence_4hr
cd SomA_Persistence_4hr
cd trpA1_quant

%batch 1
expmts1 = struct();
files = dir('**/*.mat');
hotSide = {'L', 'R'};
[expmts1, tempPrefOrig1] = createTempPref(expmts1, files, hotSide, [0 1]);

%batch 2
expmts2 = struct();
files = dir('**/*.mat');
hotSide = {'R', 'L'};
[expmts2, tempPrefOrig2] = createTempPref(expmts2, files, hotSide, [0 1]);

%batch 3
expmts3 = struct();
files = dir('**/*.mat');
hotSide = {'L', 'R'};
[expmts3, tempPrefOrig3] = createTempPref(expmts3, files, hotSide, [0 1]);


%% attach labels
SomA20181031B1 = sortrows(SomA20181031B1,1);
SomA20181101B1 = sortrows(SomA20181101B1,1);

batch1labels = [SomA20181031B1;SomA20181101B1];

SomA20181101B2 = sortrows(SomA20181101B2,1);
SomA20181102B2 = sortrows(SomA20181102B2,1);

batch2labels = [SomA20181101B2;SomA20181102B2];

SomA20181102B3 = sortrows(SomA20181102B3,1);
SomA20181103B3 = sortrows(SomA20181103B3,1);

batch3labels = [SomA20181102B3;SomA20181103B3];
%% combine into single array
%load('batch1labels.mat');
%batch 1
tempPref1 = [tempPrefOrig1(:,1:9) batch1labels]; %tempPrefOrig1(:,10)];

%batch 2
tempPref2 = [tempPrefOrig2(:,1:9) batch2labels];% tempPrefOrig2(:,10)];

%batch 3
tempPref3 = [tempPrefOrig3(:,1:9) batch3labels];% tempPrefOrig3(:,10)];

%% activity filtering by batch
thresh = 0.25; 
%remove fly less than 1hr  of trial is spent active
subsampleRate = 300;
pauseDist = 5;
pauseTime = 3000; %5min

tempPref1 = tempPref1(cell2mat(tempPref1(:,2))>1000,:); %take out missing flies
tempPref1 = activityThresholding(tempPref1, tempPref1(:,16),...
                        pauseDist, pauseTime, subsampleRate,...
                        thresh); %activity thresh

tempPref2 = tempPref2(cell2mat(tempPref2(:,2))>1000,:); %take out missing flies
tempPref2 = activityThresholding(tempPref2, tempPref2(:,16),...
                        pauseDist, pauseTime, subsampleRate,...
                        thresh); %activity thresh
                    
tempPref3 = tempPref3(cell2mat(tempPref3(:,2))>1000,:); %take out missing flies
tempPref3 = activityThresholding(tempPref3, tempPref3(:,16),...
                        pauseDist, pauseTime, subsampleRate,...
                        thresh); %activity thresh

%% persistence analysis by batch

%batch 1
load('bostonTunnelTemps.mat');
tempPref1 = tempPref1(string(tempPref1(:,15)) == 'SomA',:); %SomA only
tempPref1 = tempPrefToDegrees(tempPref1, tempPref1(:,16), tempPref1(:,20),...
                                bostonTunnelTemps);

Day1 = tempPref1(cell2mat(tempPref1(:,12)) == 1,:); %separate into days
Day2 = tempPref1(cell2mat(tempPref1(:,12)) == 2,:);

[~,idx1,idx2] = intersect(cell2mat(Day1(:,11)),...
                cell2mat(Day2(:,11)), 'sorted'); %find only those flies tested on both days

Day1 = Day1(idx1,:); %filter by index of those flies
Day2 = Day2(idx2,:);

%batch 2
load('bostonTunnelTemps.mat');
tempPref2 = tempPref2(string(tempPref2(:,15)) == 'SomA',:); %SomA only
tempPref2 = tempPrefToDegrees(tempPref2, tempPref2(:,16), tempPref2(:,20),...
                                bostonTunnelTemps);

Day1 = tempPref2(cell2mat(tempPref2(:,12)) == 1,:); %separate into days
Day2 = tempPref2(cell2mat(tempPref2(:,12)) == 2,:);

[~,idx1,idx2] = intersect(cell2mat(Day1(:,11)),...
                cell2mat(Day2(:,11)), 'sorted'); %find only those flies tested on both days

Day1 = Day1(idx1,:); %filter by index of those flies
Day2 = Day2(idx2,:); 

%batch 3
load('bostonTunnelTemps.mat');
tempPref3 = tempPref3(string(tempPref3(:,15)) == 'SomA',:); %SomA only
tempPref3 = tempPrefToDegrees(tempPref3, tempPref3(:,16), tempPref3(:,20),...
                                bostonTunnelTemps);

Day1 = tempPref3(cell2mat(tempPref3(:,12)) == 1,:); %separate into days
Day2 = tempPref3(cell2mat(tempPref3(:,12)) == 2,:);

[~,idx1,idx2] = intersect(cell2mat(Day1(:,11)),...
                cell2mat(Day2(:,11)), 'sorted'); %find only those flies tested on both days

Day1 = Day1(idx1,:); %filter by index of those flies
Day2 = Day2(idx2,:); 

%% pull out tempPref on both days and find flies with persistent behavior 

%make array of tempPref day1, housing #, tempPref day2
compareArray = [cell2mat(Day1(:,1)) cell2mat(Day1(:,11)) cell2mat(Day2(:,1))];
compareArrayDeg= [cell2mat(Day1(:,22)) cell2mat(Day1(:,11)) cell2mat(Day2(:,22))];

idx = [(compareArrayDeg(:,1) - compareArrayDeg(:,3)) compareArrayDeg(:,2)];
idx(abs(idx(:,1))<1,:)
idx(abs(idx(:,1))<1.5,:)

%% correlate with transcript quant
load('SomA_trpA1_quant_boxlabel.mat', 'SomAtrpA1quant')
load('SomAquantTranscripts.mat')
load('bostonTunnelTemps.mat');

%% activity filtering on entire data set
thresh = 0.25; 
%remove fly less than 1hr  of trial is spent active
subsampleRate = 300;
pauseDist = 5;
pauseTime = 3000;

tempPref = activityThresholding(SomAtrpA1quant, SomAtrpA1quant(:,16),...
                        pauseDist, pauseTime, subsampleRate,...
                        thresh);
                    
tempPref = tempPref(string(tempPref(:,15)) == 'SomA',:); %SomA only
tempPref = tempPrefToDegrees(tempPref, tempPref(:,16), tempPref(:,20),...
                                bostonTunnelTemps);

tempPref_d1 = tempPref(cell2mat(tempPref(:,12)) == 1,:);
tempPref_d2 = tempPref(cell2mat(tempPref(:,12)) == 2,:);

%% plot SomA Day 1 - Day 2 persistence 
[~,idx1,idx2] = intersect(cell2mat(tempPref_d1(:,11)),...
                cell2mat(tempPref_d2(:,11)),'sorted'); %find only those flies tested on both days

Day1 = tempPref_d1(idx1,:);
Day2 = tempPref_d2(idx2,:);

%% plot behavior on Day 1 vs Day 2 
g = gramm('x', Day1(:,22), 'y', Day2(:,22));
g.geom_point();
g.stat_glm();
g.set_text_options('base_size' , 16, 'label_scaling', 1);
g.set_names('x','Day 1 Preference (ºC)', 'y','Day 2 Preference (ºC)')
%g.axe_property('XLim',[-0.5 0.5],'YLim',[-0.5 0.5]);
g.set_color_options('chroma',0,'lightness',30);
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();
set(g.results.geom_point_handle,'MarkerSize',7);

[r,p] = corrcoef(cell2mat(Day1(:,22)), cell2mat(Day2(:,22)))

%% export as PDF
print('SomA_Day1vsDay2','-dpdf','-fillpage')

%%
[~,idx1,idx2] = intersect(cell2mat(tempPref_d1(:,11)),...
                cell2mat(SomAquantTranscripts(:,7)), 'sorted'); %find only those flies tested on both days

Day1 = tempPref_d1(idx1,:); %filter by index of those flies

[~,idx1,idx2] = intersect(cell2mat(tempPref_d2(:,11)),...
                cell2mat(SomAquantTranscripts(:,7)), 'sorted'); %find only those flies tested on both days

Day2 = tempPref_d2(idx1,:); %filter by index of those flies
trpA1ratio = SomAquantTranscripts(idx2,:); 

avgTPref = (cell2mat(Day1(:,22)) + cell2mat(Day2(:,22)))/2;

%% plot behavior vs. transcript expression 
%g = gramm('x', Day2(:,22), 'y', trpA1ratio(:,5));
g = gramm('x', avgTPref, 'y', trpA1ratio(:,6));
g.geom_point();
g.stat_glm();
g.set_text_options('base_size' , 16, 'label_scaling', 1);
g.set_names('x','Averaged Preference (ºC)', 'y','trpA1:CG16779 ratio')
%g.axe_property('XLim',[-0.5 0.5],'YLim',[-0.5 0.5]);
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();
set(g.results.geom_point_handle,'MarkerSize',7);

[r,p] = corrcoef(avgTPref, cell2mat(trpA1ratio(:,6)))
%[r,p] = corrcoef(cell2mat(Day2(:,22)), cell2mat(trpA1ratio(:,5)))

%%
print('AvgTPref_trpA1quant','-dpdf','-fillpage')
%% plot behavior on day1 vs day2
g = gramm('x', Day1(:,22), 'y', Day2(:,22));
g.geom_point();
g.stat_glm();
g.set_text_options('base_size' , 16, 'label_scaling', 1);
g.set_names('x','Day 1 Preference (ºC)', 'y','Day 2 Preference (ºC)')
%g.axe_property('XLim',[-0.5 0.5],'YLim',[-0.5 0.5]);
g.draw();
set(g.results.geom_point_handle,'MarkerSize',7);

[r,p] = corrcoef(cell2mat(Day1(:,22)), cell2mat(Day2(:,22)))
