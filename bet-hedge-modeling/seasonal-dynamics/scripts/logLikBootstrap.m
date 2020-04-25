function out = logLikBootstrap(bhmeanPref,atmeanPref, ...
                        tpref, dayNums, flySeasonInterval, sigma, n_iter)

% sample each week's data points with replacement to generate bootstrap
% resample of observed data

%evaluate logLik ratio of this pop x 1000 to generate boostrap dist of logLik ratios

totalLogLik.ratio = NaN(n_iter,1);
totalLogLik.bh = NaN(n_iter,1);
totalLogLik.at = NaN(n_iter,1);

%compare observed logLik ratio to this null model
for n = 1:n_iter
    uniqDays = unique(dayNums);
    logLik = NaN(length(unique(dayNums)), 3);

    for i = 1:length(uniqDays)
        %subset 1 wks worth of data
        d = tpref(dayNums == uniqDays(i)); %observed tempPref values

        idx = find(flySeasonInterval == uniqDays(i));
        
        if idx+6 <= length(bhmeanPref)
            bh = bhmeanPref(idx:idx+6); %find that week in the flySeason
            at = atmeanPref(idx:idx+6);
        else
            bh = bhmeanPref(idx:end); %find the last few days in the flySeason
            at = atmeanPref(idx:end);
        end
        
        %create boostrap resample
        bh_mean = mean(bh); %mean temp pref of that week
        at_mean = mean(at);
        
        simPop = randsample(d, length(d), true); %sample with replacement

        logLik_bh = NaN(1,length(d));
        logLik_at = NaN(1,length(d));

        for j = 1:length(d)
            logLik_bh(1,j) = log(normpdf(simPop(j), bh_mean,sigma));
            logLik_at(1,j) = log(normpdf(simPop(j), at_mean,sigma));    
        %calculate log likelihood of observing this value given adaptive
        %tracking or bet hedging
        end

        logLik(i,1) = nansum(logLik_bh); %sum down the j observations

        logLik(i,2) = nansum(logLik_at);

        logLik(i,3) = logLik(i,1) - logLik(i,2); %bh likelihood - at likelihood
    
    end
    
    totalLogLik.ratio(n) = sum(logLik(:,3)); %total bh/at log likelihood 
    totalLogLik.bh(n) = sum(logLik(:,1)); %total bh log likelihood 
    totalLogLik.at(n) = sum(logLik(:,2)); %total at log likelihood 
end
out = totalLogLik;