%% Heritability Total Analysis
% created by: jamilla a
% created on: 03-22-2019
% updated: 03-22-2019

%% load in data arrays for analysis
load('bostonTunnelTemps.mat'); %for degC transformation
load('parents_fltd.mat'); %filtered and degC transformed parental data

%% load in labels for crosses and make single array
cd Heritability
cd Heritability_Crosses

herit_crosses = [HeritabilityCrossesB1;HeritabilityCrossesB2;...
                 HeritabilityCrossesB3;HeritabilityCrossesB4];

             
%% load in heritability cross label array      
load('heritabilityCrosses.mat');

%% make struct with the tempPref of mom/dad, and avg tempPref of cross

midParent_tPref = heritCrossesTempPref(herit_crosses, parents_fltd);

%% load in midParent value struct and male F1 data     
load('midParentValues.mat');
load('F1_TempPref.mat');

%% filter male F1 data for activity and transform to degC
thresh = 0.25; 
%remove fly less than 1hr (0.25) of trial is spent active
subsampleRate = 300;
pauseDist = 5;
pauseTime = 3000;

F1data_fltd = activityThresholding(F1data_unfltd,...
                            F1data_unfltd(:,16), pauseDist, pauseTime, ...
                            subsampleRate, thresh);
                        
F1data_fltd = tempPrefToDegrees(F1data_fltd, F1data_fltd(:,16), ...
                F1data_fltd(:,17), bostonTunnelTemps);
%col 1 is occupancy, col 21 is degC pref                        

%% load filtered F1 data
load('F1_TemPref_fltd.mat');

%% make struct with midparent data and F1 averaged tempPref

heritParF1Data = summarizeF1TempPref(F1data_fltd, midParent_tPref);

%% plotting
%separate out a particular location of interest
idx = heritParF1Data.locations == 'PA';

F1_pref = heritParF1Data.avgDegC(idx);
Par_pref = heritParF1Data.midParent_degC(idx);

g = gramm('x', Par_pref, 'y', F1_pref);
g.geom_point();
g.stat_glm();
g.set_point_options('base_size',7);
g.set_color_options('chroma',0,'lightness',50);
g.set_text_options('base_size' , 14, 'label_scaling', 1);
g.set_names('x','Mid-Parent Preference','y','F1 Mean Preference');
g.set_title('FL');
g.axe_property('XLim',[21 27],'YLim',[21 27]);
set(gcf,'Renderer', 'painters');
set(gcf,'PaperOrientation','landscape');
g.draw();

%%
print('TX_Heritability_Occ','-dpdf','-fillpage')

%% calculate regression slope
reg_fit = fitlm(Par_pref, F1_pref) 
coefCI(reg_fit)

