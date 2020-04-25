function out = nullDistribution(hotBouts, coldBouts, middleBouts, n_it,...
                                subsampleRate, pauseDist, pauseThresh)

%using hotBouts, coldBouts, and middleBouts, the fxn creates simulated fly
%tracks by randomly sampling bouts until simulated 4hr assay is created

%simulated flies undergo same track filtering for inactive bouts as real flies using
%subsampleRate, pauseDist, and pauseThresh

%out.unfltd stores all simulated flies generated, whether or not they pass the
%activity threshold

%out.fltd stores only the simulated flies that pass the activity threshold
%- these are flies from which the stats are calculated


%if nargin < 4, n_replicates = 1e4; end
%if nargin < 3, n_it = 1e2; end

    nFlies = size(hotBouts,1); %number of flies to simulate
    
    hotBouts = vertcat(hotBouts{:}); %pool all hot bouts together
    coldBouts = vertcat(coldBouts{:}); %pool all cold bouts together
    middleBouts = vertcat(middleBouts{:}); %pool all middle bouts together
    
    allBouts = [hotBouts;coldBouts;middleBouts]; %pool all bouts 
    allBoutsLabels = [repelem('H',length(hotBouts),1);...
                      repelem('C',length(coldBouts),1);...
                      repelem('M',length(middleBouts),1)]; %labels for all bouts
    
    simulated_occupancy = NaN(n_it, nFlies);
    simulated_activity = NaN(n_it, nFlies);
    simulated_track = cell(n_it, nFlies);
    simulated_lab = cell(n_it, nFlies);
    
    for i = 1:n_it
            
            parfor k = 1:nFlies
                
                frame_tot = 0;
                sim_run = [];
                sim_lab = [];
                
                while frame_tot < 14400 %4hr assay sampled at 1Hz
                    idx = randsample(length(allBouts),1,1);
                    sim_run = [sim_run;allBouts{idx,1}]; %extract centroid track
                    sim_lab = [sim_lab;repelem(allBoutsLabels(idx,1),...
                                       length(allBouts{idx,1}),1)];
                               %label each centroid point with H/C/M
                    frame_tot = length(sim_run); %did we reach end of 4hr expt?
                end
                
                if frame_tot > 14400
                    %sim_run(end) = sim_run(end) - (frame_tot - 14400);
                    sim_run(14401:end) = []; %remove positions beyond 4 hrs
                end
                
                %subsample simulated tracks and labels
                idx = 1:subsampleRate:length(sim_run);
                sim_run = sim_run(idx);
                sim_lab = sim_lab(idx);
                
                %filter for inactive bouts and make occupancy score
                filt_track = filterInactiveBouts_nullDist(sim_run, sim_lab, ...
                             subsampleRate, pauseDist, pauseThresh);
                
               
                simulated_occupancy(i,k) = filt_track{1};
                %calculate simulated occupancy
                simulated_track{i,k} = filt_track{2};
                %store simulated centroid track
                simulated_lab{i,k} = filt_track{3};
                %store simulated labels track
                simulated_activity(i,k) = filt_track{4};
                %store simulated activity
                
            end
            
    end
    
out.unfltd.simulated_occupancy = simulated_occupancy;
out.unfltd.simulated_track = simulated_track; 
out.unfltd.simulated_lab = simulated_lab;
out.unfltd.simulated_activity = simulated_activity;

%filter simulated tracks for activity
out.fltd.simulated_occupancy = cell(n_it,1);
out.fltd.simulated_track = cell(n_it,1);
out.fltd.simulated_lab = cell(n_it,1);
out.fltd.simulated_activity = cell(n_it,1);

out.fltd.simulated_var_pop = NaN(n_it,1);
out.fltd.simulated_sd_pop = NaN(n_it,1);
out.fltd.simulated_MAD_pop = NaN(n_it,1);

for i = 1:n_it    
    idx = simulated_activity(i,:) > 0.25;
    out.fltd.simulated_occupancy{i} = simulated_occupancy(i,idx);
    
    out.fltd.simulated_var_pop(i) = var(simulated_occupancy(i,idx));
    out.fltd.simulated_sd_pop(i) = std(simulated_occupancy(i,idx));
    out.fltd.simulated_MAD_pop(i) = mad(simulated_occupancy(i,idx),1);
    
    out.fltd.simulated_track{i} = simulated_track(i,idx);
    out.fltd.simulated_lab{i} = simulated_lab(i,idx);
    out.fltd.simulated_activity{i} = simulated_activity(i,idx);
end

% calculate residual variance
%out.simulated_var_pop = var(out.simulated_occupancy,[],2);
out.fltd.simulated_var = mean(out.fltd.simulated_var_pop);
%out.fltd.observed_var = var(observed_occupancy);
out.fltd.simulated_var_se = std(out.fltd.simulated_var_pop);
%out.fltd.residual_var = out.observed_var - out.simulated_var;


% calculate residual SD
%out.simulated_sd_pop = std(simulated_occupancy,[],2);
out.fltd.simulated_sd = mean(out.fltd.simulated_sd_pop);
%out.observed_sd = std(observed_occupancy);
out.fltd.simulated_sd_se = std(out.fltd.simulated_sd_pop);
%out.residual_sd = out.observed_sd - out.simulated_sd;


% calculate residual MAD
%out.simulated_MAD_pop = mad(simulated_occupancy,1,2);
out.fltd.simulated_MAD = mean(out.fltd.simulated_MAD_pop);
%out.observed_MAD = mad(observed_occupancy,1);
out.fltd.simulated_MAD_se = std(out.fltd.simulated_MAD_pop);
%out.residual_MAD = out.observed_MAD - out.simulated_MAD;

% resample from real and simulated occupancy scores
% parfor k = 1:n_replicates
%     bootstrap_sample_1 = randsample(out.fltd.simulated_occupancy(:), nFlies,1);
%     bootstrap_sample_2 = randsample(observed_occupancy, nFlies,1)';
%     resampled_var_1(k) = var(bootstrap_sample_1(~isnan(bootstrap_sample_2)));
%     resampled_var_2(k) = var(bootstrap_sample_2(~isnan(bootstrap_sample_2)));
%     resampled_mad_1(k) = mad(bootstrap_sample_1(~isnan(bootstrap_sample_2)),1);
%     resampled_mad_2(k) = mad(bootstrap_sample_2(~isnan(bootstrap_sample_2)),1);
%     bootstrapped_residual_var(k) = resampled_var_2(k) - resampled_var_1(k);
%     bootstrapped_residual_mad(k) = resampled_mad_2(k) - resampled_mad_1(k);
% end


end
