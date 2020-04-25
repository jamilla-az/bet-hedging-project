%% create occupancy vs dist trav plot using tempOFF and fit a curve

%% load RAL535 data (1hr duration)
expmts = struct();
cd tempOFF_RAL535
files = dir('**/*.mat');
hotSide = {'L', 'L', 'L', 'L', 'L', 'L'};

%downsample to 10Hz only - comment out lines 42-43 in twoChoicePref.m fxn
[expmts, tempPref] = createTempPref(expmts, files, hotSide, [0 1]);

%add in tunnel number information - based on current box 3 tunnel numbering
%peltiers from the pilot assay where this data came from are currently
%odd tunnels for box3 
tempPref(:,10) = num2cell(repmat(1:2:39,1,6)');

%vector of ON (1) or OFF (0) tests
tempPref(:,11) = num2cell([repelem(1,20,1);repelem(0,20,1);repelem(1,20,1);...
                  repelem(0,20,1);repelem(1,20,1);repelem(0,20,1)]);

tempPref = tempPref(cell2mat(tempPref(:,2)) >= 1000,:); 
%distance threshold of 1000px traveled

%off array
tempOFF535 = tempPref(cell2mat(tempPref(:,11)) == 0,:);


%% do tunnel calibration and turn tempOFF occupancy into "ºC" data
% box 3 odd tunnels were kept from the pilot iteration of the assay where
% this data was collected from

%add hot Side 'L' to each fly and box 3 ID
tempOFF535(:,12) = cellstr(repelem('L',length(tempOFF535),1));
tempOFF535(:,13) = num2cell(repelem(3,length(tempOFF535),1));

%load in boston tunnel data
load('bostonTunnelTemps.mat')

%calculate the preference in degC
tempOFF535 = tempPrefToDegrees(tempOFF535, tempOFF535(:,12), tempOFF535(:,13), bostonTunnelTemps);

%col 14 is the degC metric and col 1 is the occupancy metric 
%% calculate occupancy var by distance traveled

[tPref, distTrav] = occupancyByDistTrav(tempOFF535);

%occupancy metric
meanDist = nanmean(distTrav(1:end,[1:46 48:end]) ,2);
varPref = nanvar(tPref(1:end,[1:46 48:end]), 0 ,2);

%transform into degC
hotTunnelTemps = cell2mat(tempOFF535(:,15))';
coldTunnelTemps = cell2mat(tempOFF535(:,16))';

tPref_c = hotTunnelTemps.*tPref + coldTunnelTemps.*(1-tPref); %transformation
meanDist_c = nanmean(distTrav(1:end,[1:46 48:end]) ,2);
varPref_c = nanvar(tPref_c(1:end,[1:46 48:end]), 0 ,2);


%% fit curve to occupancy
%least sq approach
[powerFit, gof] = fit(meanDist(~isnan(meanDist)),...
            varPref(~isnan(varPref)), 'power1');

%least sq approach that is robust to outliers 
[powerFit_bisq, gof_bisq] = fit(meanDist(~isnan(meanDist)),...
            varPref(~isnan(varPref)), 'power1', 'Robust', 'Bisquare');

%minimize least abs resid value, extreme values have lower impact on fit       
[powerFit_lar, gof_lar] = fit(meanDist(~isnan(meanDist)),...
            varPref(~isnan(varPref)), 'power1', 'Robust', 'LAR');
        
%% fit curve to degC

%least sq approach
[powerFit_c, gof_c] = fit(meanDist_c(~isnan(meanDist_c)),...
            varPref_c(~isnan(varPref_c)), 'power1');

        
%least sq approach that is robust to outliers 
[powerFit_c_bisq, gof_c_bisq] = fit(meanDist_c(~isnan(meanDist_c)),...
            varPref_c(~isnan(varPref_c)), 'power1', 'Robust', 'Bisquare');

%minimize least abs resid value, extreme values have lower impact on fit       
[powerFit_c_lar, gof_c_lar] = fit(meanDist_c(~isnan(meanDist_c)),...
            varPref_c(~isnan(varPref_c)), 'power1', 'Robust', 'LAR');
    
%% plot old fit (recorded in R analysis scripts)

powerFit_old = powerFit;
powerFit_old.a = 9.574;
powerFit_old.b = -0.8232;

figure
plot(powerFit_old, meanDist(~isnan(meanDist)),...
                varPref(~isnan(varPref)))
            
set(gca, 'FontSize', 16);
xlabel('Distance Traveled (px)');
ylabel('Variance in Occupancy');
title('Sampling Error vs. Distance - Melanogaster (Old Fit)');

%% 0-1

figure
subplot(1,3,1);
plot(powerFit, meanDist(~isnan(meanDist)),...
                varPref(~isnan(varPref)))
set(gca, 'FontSize', 12);
xlabel('Distance Traveled (px)');
ylabel('Variance in Occupancy');
title('Least Sq');
           
subplot(1,3,2);
plot(powerFit_bisq, meanDist(~isnan(meanDist)),...
                varPref(~isnan(varPref)))
set(gca, 'FontSize', 12);
xlabel('Distance Traveled (px)');
ylabel('Variance in Occupancy');
title('Bisquare');
            
subplot(1,3,3);
plot(powerFit_lar, meanDist(~isnan(meanDist)),...
                varPref(~isnan(varPref)))
            
set(gca, 'FontSize', 12);
xlabel('Distance Traveled (px)');
ylabel('Variance in Occupancy');
title('Least Abs Resid');

%% deg C

figure
subplot(1,3,1);
plot(powerFit_c, meanDist_c(~isnan(meanDist_c)),...
                varPref_c(~isnan(varPref_c)))
set(gca, 'FontSize', 12);
xlabel('Distance Traveled (px)');
ylabel('Variance in Occupancy');
title('Least Sq degC');
           
subplot(1,3,2);
plot(powerFit_c_bisq, meanDist_c(~isnan(meanDist_c)),...
                varPref_c(~isnan(varPref_c)))
set(gca, 'FontSize', 12);
xlabel('Distance Traveled (px)');
ylabel('Variance in Occupancy');
title('Bisquare degC');
            
subplot(1,3,3);
plot(powerFit_c_lar, meanDist_c(~isnan(meanDist_c)),...
                varPref_c(~isnan(varPref_c)))
            
set(gca, 'FontSize', 12);
xlabel('Distance Traveled (px)');
ylabel('Variance in Occupancy');
title('Least Abs Resid')
            