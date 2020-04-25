function out=hedgeAnalytic(herit,weather,cMu,cVar,birth,delta,~,offset,shadeDiff,wStd,weatherMode,weatherPre)
% hedgeAnalytic implements the analytical model of a effectively infinite
% population reproducing over a breeding season, under alternate modes of 
% behavioral heritability, and alternate simulated weather conditions.
%=========================================================================
% updated by jamilla a: 2019-03-07 to correct for divide by zero issue
% updated by jamilla a: 2019-12-14 to correct the adult thermal experience
% equations 

% Usage:
% out=hedgeAnalytic(herit,weather,cMu,cVar,birth,delta,null,offset,shadeDiff,wStd,weatherMode,weatherPre)
% Inputs:
%       ? herit = {0,1}. 0=bet-hedging, 1=adaptive tracking.
%       ? weather = struct of weather data, e.g. wp in hedgeWeatherPack.mat
%       ? cMu = mean light choice probability
%       ? cVar = variance in light choice probability
%       ? birth = model birth rate (beta)
%       ? delta = model death rate (delta)
%       ? null (ignored)
%       ? offset = constant offset in seasonal temps, for climate effects
%       ? shadeDiff = temp diff between sun and shade (7 in all instances)
%       ? wStd = scaling factor of seasonal min and max temps, for climate effects
%       ? weatherMode = text indicating which weather variables to simulate
%       ? weatherPre = struct containing seasonal data for pre-specified seasons
%           contains two objects:
%           ? .tempHist = season of daily temperatures
%           ? .cloudCover = season of daily cloud cover fractions
%           pass 0 here if N/A
% Ouput: a stuct containing the following objects
%       ? .pops = 100xD matrix of population sizes. Rows correspond to
%       phototactic preference probabilities binned into 1% intervals.
%       ? .cloudCover = the vector of daily cloud cover fractions. Save
%       this into a new struct if you want construct a weatherPre structure
%       to re-simulate these conditions.
%       ? .tempHist = the vector of daily temperatures. Save this into a 
%       new struct if you want construct a weatherPre structure to re-
%       simulate these conditions.
%       ? .prefHist = the population mean preference across days

tempHist=weather.normal(weather.flySeasonInterval); % set the temp history to the right length of the season

% prepare the season weather conditions according to the weatherMode
% parameter:
if isequal(weatherMode,'000') % simulate a constant temperature with no clouds
    tempHist=zeros(size(tempHist))+weather.flySeasonTempMean;
    cloudCover=zeros(size(tempHist));
elseif isequal(weatherMode,'001') % simulate an average temperature profile with no clouds
    tempHist=weather.normal(weather.flySeasonInterval);
    cloudCover=zeros(size(tempHist)); %updated from tempHist./tempHist*0; on 3/7/2019
elseif isequal(weatherMode,'climate') % simulate an average temperature profile with specified offsets and re-scaled min and max temp
    tempHist=weather.normal(weather.flySeasonInterval);
    tempMean=mean(tempHist);
    tempHist=(tempHist-tempMean)*wStd+tempMean;
    cloudCover=zeros(size(tempHist));
elseif isequal(weatherMode,'000L') % simulate a 3x long constant temperature season with no clouds
    tempHist=zeros(size(tempHist))+weather.flySeasonTempMean;
    tempHist=[tempHist;tempHist;tempHist];
    cloudCover=zeros(size(tempHist));
elseif isequal(weatherMode,'2007') % use historical cloud and daily temperature data from 2007
    index2007=213:426;
    tempHist=weather.aveT(index2007);
    cloudCover=weather.cloud(index2007);
elseif isequal(weatherMode,'2008') % use historical cloud and daily temperature data from 2008
    index2008=579:792;
    tempHist=weather.aveT(index2008);
    cloudCover=weather.cloud(index2008);
elseif isequal(weatherMode,'2009') % use historical cloud and daily temperature data from 2009
    index2009=944:1157;
    tempHist=weather.aveT(index2009);
    cloudCover=weather.cloud(index2009);
elseif isequal(weatherMode,'2010') % use historical cloud and daily temperature data from 2010
    index2010=1309:1522;
    tempHist=weather.aveT(index2010);
    cloudCover=weather.cloud(index2010);
elseif isequal(weatherMode,'2000s') % use concatenated cloud and daily temperature data from the 2007-2010 seasons
    tempHist=weather.aveT([213:426 579:792 944:1157 1309:1522]);
    cloudCover=weather.cloud([213:426 579:792 944:1157 1309:1522]);
elseif isequal(weatherMode,'111') % simulate a season with random daily temperature deviations and random cloud Cover fractions
    ARparams=30;
    [ar_coeffs,nV,reflect_coeffs] = aryule(weather.dev,ARparams); %determine auto-regression parameters for daily temp deviation data from 2006-2010.
    tempHist=weather.normal(weather.flySeasonInterval);
    daysToSim=length(weather.flySeasonInterval);
    devHist=filter(1,ar_coeffs,randn(daysToSim+100,1)*nV); % apply auto-regression weights as a filter to gaussian white noise to make a new season of temp deviations
    devHist=devHist(101:end);                              % throw out burn-in portion of the data
    tempHist=tempHist+devHist*weather.devStd/std(devHist); % apply deviations to average seasonal temperatures
    cloudCover=hedgeMakeCloud2(weather.cloud(weather.flySeasonInterval),0:10); % generate random cloud cover vector
elseif isequal(weatherMode,'100summers') % simulate 100 consecutive seasons with random daily temperature deviations and random cloud Cover fractions
    ARparams=30;
    [ar_coeffs,nV,reflect_coeffs] = aryule(weather.dev,ARparams);  %determine auto-regression parameters for daily temp deviation data from 2006-2010.
    daysToSim=length(weather.flySeasonInterval);
    tHreal=[];
    cCreal=[];
    for i=1:100
        tempHist=weather.normal(weather.flySeasonInterval);    % start new season of deviations
        disp(i);
        devHist=filter(1,ar_coeffs,randn(daysToSim+100,1)*nV); % apply auto-regression weights as a filter to gaussian white noise to make a new season of temp deviations
        devHist=devHist(101:end);                              % throw out burn-in portion of the data
        tempHist=tempHist+devHist*weather.devStd/std(devHist); % apply deviations to average seasonal temperatures
        cloudCover=hedgeMakeCloud2(weather.cloud(weather.flySeasonInterval),0:10); % generate random cloud cover vector
        tHreal=[tHreal;tempHist];                           % concatenate these vectors to growing 100 season vector
        cCreal=[cCreal;cloudCover];
    end
    tempHist=tHreal;
    cloudCover=cCreal;
elseif isequal(weatherMode,'pre')   % load a pre-calculated season of temp deviations and cloud cover 
    tempHist=weatherPre.tempHist;
    cloudCover=weatherPre.cloudCover;
else                                 % default weatherMode = 001
    tempHist=weather.normal(weather.flySeasonInterval);
    cloudCover=zeros(size(tempHist));
end

% add climate offset
tempHist=tempHist+offset;

% calculate A and B parameters of beta-function give mu and var of observed
% distribution of light-choice probabilities
A=cMu*((cMu*(1-cMu))/cVar - 1);
B=(1-cMu)*((cMu*(1-cMu))/cVar - 1);

% Create vector of light (temp) choice preferences to be simulated at each time step
daysToSim=length(tempHist);
X=(0:0.01:1)*100/101+0.01/2;
numGroups=length(X);

% initialize matrix for population as a function of light preference and time
prefPops=zeros(numGroups,daysToSim)+NaN;

% seed t=1 population based on beta distribution, and normalize into percentages
prefPops(:,1)=betapdf(X,A,B);
prefPops(:,1)=100*prefPops(:,1)/sum(prefPops(:,1));

% intitialize matrix of posterior probabilities of parental prefernce,
% given progeny preference
transitions=zeros(numGroups,numGroups);
if herit==1     % if adaptive tracking, parental preference known
    transitions=eye(numGroups);
else            % otherwise, is a scaled and re-centered beta distribution (this may only work for h==0).
    for i=1:numGroups
        xTemp=(X-(X(i)*herit+(A*(1-herit))/(A+B)))*(1/(1-herit)) + A/(A+B);
        xTemp2=betapdf(xTemp,A,B);
        xTemp2=xTemp2/sum(xTemp2);
        transitions(i,:)=xTemp2;
    end
end
transitions(isnan(transitions))=0;

tau2Temp_mat = NaN(numGroups, daysToSim); %store thermal experience vectors

% start simulation
for t=2:daysToSim
    
    tau2Temp=zeros(size(X));
    maxTemp = tempHist(t)+ shadeDiff*(10-cloudCover(t))/10;
    minTemp = tempHist(t);
    a = 0.4;
    ambTemp = minTemp + (shadeDiff/2)*(10-cloudCover(t))/10;
    for i=1:numGroups
        if minTemp >= X(i)*12+18 %if min daily temp > pref temp
            tau2Temp(i) = (1-a)*minTemp + a*ambTemp;
        elseif maxTemp <= X(i)*12+18 %if max daily temp < pref temp
            tau2Temp(i) = (1-a)*maxTemp + a*ambTemp;
        elseif minTemp < X(i)*12+18 && X(i)*12+18 < maxTemp
            tau2Temp(i) = (1-a)*(X(i)*12+18)+ a*ambTemp;
        end
    end
    
    %tau2Temp=tempHist(t)+X*shadeDiff.*(10-cloudCover(t))/10;    %calculate the temp experienced by each type of fly given temp and cloud cover
    %tau2Temp(tau2Temp>30)=30; %cap the thermal experience
    tau2Temp_mat(:,t) = tau2Temp;
    
    %DELTA=1./(0.4074*tau2Temp.^2-28.356*tau2Temp+506.2);       %calculate
    %temp-dependent old age death rate for each type of fly - Kain et al
    %quad fit
    
    %DELTA=1./(280.7-8.8*tau2Temp); %Kain et al linear fit
    %DELTA=1./(193.034-5.792*tau2Temp); %Combined obs linear fit
    %DELTA=1./(174.107-5.732*tau2Temp); %MA linear fit
    %DELTA=1./(201.95-5.688*tau2Temp); %FL linear fit
    %DELTA=1./(205.967-6.103*tau2Temp); %VA linear fit
    
    %DELTA=1./(727.6-208.4*log(tau2Temp)); %Kain et al log fit
    DELTA=1./(459.9-128.0*log(tau2Temp)); %Combined obs log fit	
    %DELTA=1./(438.3-126.7*log(tau2Temp)); %MA log fit	
    %DELTA=1./(463.5-125.5*log(tau2Temp)); %FL log fit	
    %DELTA=1./(486.7-134.8*log(tau2Temp)); %VA log fit	
    DELTA(DELTA<0)=0;
    lifeSpanVect=1./(DELTA+delta)';                             %convert into vector of expected lifespans.
    
    devTimeVect=zeros(numGroups,1);                             % to determine fraction of fertile flies, need their respective development times, which depends on recent temp history
    for i=1:numGroups
        dTI1=round(max([1 t-lifeSpanVect(i)*0.5]));             % approx lower bound on development (start of experiment or half lifetime ago)
        dTI2=min([t dTI1+21]);                                  % approx upper bound on development (now or 21 days after lower bound)
        devTau=mean(tempHist(dTI1:dTI2));                       % mean temperature in that time range
        
        %devTime=0.2306*devTau^2-11.828*devTau+158.34;           % inferred development time in that interval - Kain et al			
        devTime=0.1445*devTau^2-7.5636*devTau+108.1585;         % inferred development time in that interval - combined obs
        %devTime=0.1466*devTau^2-7.6021*devTau+107.7446;         % inferred development time in that interval - MA
        %devTime=0.1455*devTau^2-7.5743*devTau+107.9984;          % inferred development time in that interval - FL
        %devTime=0.1376*devTau^2-7.3419*devTau+106.9276;          % inferred development time in that interval - VA
        	
        dTI2_2=round(min([t dTI1+devTime]));                    % iterate this developmental time estimate for a new upper bound
        devTau_2=mean(tempHist(dTI1:dTI2_2))+X(i)*shadeDiff*(10-mean(cloudCover(dTI1:dTI2_2)))/10; %iterated mean temperature estimate
        
        %devTimeVect(i)=0.2306*devTau_2^2-11.828*devTau_2+158.34;% iterated
        %development time - Kain et al
        
        devTimeVect(i)=0.1445*devTau_2^2-7.5636*devTau_2+108.1585; %iterated dev Time - combined obs
        %devTimeVect(i)=0.1466*devTau_2^2-7.6021*devTau_2+107.7446; %iterated dev Time - MA
        %devTimeVect(i)=0.1455*devTau_2^2-7.5743*devTau_2+107.9984; %iterated dev Time - FL
        %devTimeVect(i)=0.1376*devTau_2^2-7.3419*devTau_2+106.9276; %iterated dev Time - VA
    end
    
    fertilityVect=(lifeSpanVect-devTimeVect)./lifeSpanVect;     %fraction of flies that are fertile = (lifespan-development time)/lifespan
    fertilityVect(fertilityVect<0)=0; %jamilla a. 12/8/19
    
    for i=1:numGroups %for each photo preference
        parentDistrib=transitions(:,i);
        popIncoming=sum(prefPops(:,t-1).*fertilityVect.*parentDistrib.*birth); %contribution to current preference population from each possible type of contributing parent
        prefPops(i,t)=prefPops(i,t-1)*(1-delta-DELTA(i)) + popIncoming; % calculate new pop with this preference, removing those dying of old age (DELTA) or at random (delta) and adding incoming
    end
%     if sum(prefPops(:,t),1) < 1
%        prefPops(:,t) = prefPops(:,t) .* 1/(sum(prefPops(:,t),1));
%     end
    
    if isequal(weatherMode,'100summers') % if sequential summers being simulated
        if mod(t,214)==1                 % and this is a season beginning
            disp(t);
            newMu=sum(X'.*prefPops(:,t-1))/sum(prefPops(:,t-1));    %calculate mu of season-ending population
            newA=newMu*((newMu*(1-newMu))/cVar - 1);                %given new mu, but constant var, recalculate beta parameters
            newB=(1-newMu)*((newMu*(1-newMu))/cVar - 1);
            prefPops(:,t)=betapdf(X,newA,newB);                     %new seed population is beta-distributed with constant var, but variable mu
            prefPops(:,t)= prefPops(:,t)*sum(prefPops(:,t-1))/100;   
        end
    end
    
end

  % calculate population  mean at each time point.
meanPrefs=zeros(daysToSim,1); 
for i=1:daysToSim
    meanPrefs(i)=sum(X'.*prefPops(:,i))/sum(prefPops(:,i));
end

% save output objects
out.pops=prefPops;
out.cloudCover=cloudCover;
out.tempHist=tempHist;
out.prefHist=meanPrefs;
out.tau = tau2Temp_mat;
out.X = X*12+18;






