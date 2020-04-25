function out = calculateLogLikelihood(bhmeanPref,atmeanPref, ...
                        tpref, dayNums, flySeasonInterval, sigma)

%calculate log likelihood and loglik ratio of observing empirical data from
%a particular week given BH or AT model. Log lik for a particular week's
%observations is the mean of all log liks of each day of that week
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
    
    bh_mean = mean(bh); %mean temp pref of that week
    at_mean = mean(at);
    
    logLik_bh = NaN(1,length(d));
    logLik_at = NaN(1,length(d));

    for j = 1:length(d)
        logLik_bh(1,j) = log(normpdf(d(j), bh_mean,sigma));
        logLik_at(1,j) = log(normpdf(d(j), at_mean,sigma));    
    %calculate log likelihood of observing this value given adaptive
    %tracking or bet hedging
    end

    
    logLik(i,1) = nansum(logLik_bh); %sum down the j observations
    
    logLik(i,2) = nansum(logLik_at);
    
    logLik(i,3) = logLik(i,1) - logLik(i,2); %bh likelihood - at likelihood
end

out = logLik;