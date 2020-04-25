function out=hedgeBDCalibrate(mu,va,normals,weather,bCurrent,dCurrent,type)
% hedgeBDCalibrate performs a hill-climbing algorithm to determine the
% values of b and d in the model that satisfy the two assumptions (constant
% population size at the beginning and end of the season, and constant
% mean phototactic preference at the start and end of the season). This can
% be used to automatically calibrate the model for arbitrary weather and
% seasonal conditions. All calibration is done under an adaptive-tracking
% strategy, and only accommodates daily mean temperature data (i.e. not
% daily deviations or cloud cover, thus the calibration is deterministic).
%=========================================================================
% Usage:
% out=hedgeBDCalibrate(mu,va,normals,weather,bCurrent,dCurrent)
% Inputs:
%       * mu = mean light choice probability
%       * va = variance in light choice probability
%       * normals = vector of daily temperature values for a breeding season
%       * weather = struct of weather data, e.g. wp in hedgeWeatherPack.mat
%       * bCurrent = best a priori guess for the b parameter
%       * dCurrent = best a priori guess for the d parameter
%       * type = 'end' means final pop size is 100, 'mean' is mean pop size is
%       100 (jamilla a. 12/8/2019)
% Output, a structure with these objects:
%       * .modelRun = the output of hedgeSim4 for the calibrated model
%       * .bCurrent = the calibrated value of b
%       * .dCurrent = the calibrated value of d
%       * .convTime = the number of iterations until calibration convergence
%       * .normalSeason = normals

% reassign two values within the weather pack, based on the passed normals
weather.flySeasonInterval=1:length(normals);
weather.normal=normals;

% calibration goals for the end of the summer
popTarget=100;
prefTarget=mu;

% hill-climbing parameter
errorScaling=10;

%allowable error on calibration assumptions
errorTarget=0.001;

% parameter update speeds
dStepBaseline=0.001;
bStepBaseline=0.003;
dStep=0.002;
bStep=0.006;
stepDieOff=0.5;  %after an overshoot, how much to downscale step size
stepMin=0.1;

%initialize errors
popError=Inf;
prefError=Inf;

%initialize hill climbing parameters
tick=1;
dMovePrev=0;
bMovePrev=0;

%make list of b and d rates tried
b_list=NaN(350,1);
d_list=NaN(350,1);

% %while the error in either assumption is too large...
while max([abs(popError) abs(prefError)])>errorTarget
    b_list(tick) = bCurrent;
    d_list(tick) = dCurrent;
    
    %if the algorithm has failed to converge in 250 iterations, bail out
    if tick>250 
        disp([tick bCurrent dCurrent tempPop tempPref]);
        analyticRun=NaN; %analyticRun; %store values prior to bail out
        bCurrent=NaN; %bCurrent;
        dCurrent=NaN; %dCurrent;
        break;
    end
    
    % run the analytic model with current parameters
    analyticRun=hedgeAnalytic(1,weather,mu,va,bCurrent,dCurrent,0,0,7,0,'001',0);
    
    % determine error on constancy assumptions
    if isequal(type,'mean')
        tempPop = mean(sum(analyticRun.pops,1)); %constant mean pop
    elseif isequal(type,'end')
        tempPop=sum(analyticRun.pops(:,end)); % same end pop as start pop
    end
    tempPref=analyticRun.prefHist(end); %(end);
    popError=(tempPop-popTarget)/popTarget;
    prefError=(tempPref-prefTarget)/prefTarget;
    
    %disp([tick bCurrent dCurrent tempPop tempPref]); % un-comment to display current iteration and calibration state
    
    %bail out when error is at target level - added by jamilla a (12/7/19)
    if max([abs(popError) abs(prefError)]) <= errorTarget
       disp([tick bCurrent dCurrent tempPop tempPref]);
       break;
    end
    
    % if the bigger error is associated with the population assumption
    if abs(popError)>abs(prefError)
        % reset the stepsize for the delta adjustments
        dStep=dStepBaseline;
        
        %if the population error is positive
        if popError>0
            %if this move reverses the error direction, reduce future step size, provided error is low.
            if bMovePrev==1 && popError<0.1;  bStep=bStep*stepDieOff; end
            %adjust b estimate downward, in relation to the error size
            bCurrent=bCurrent-(stepMin+tanh(abs(popError)*errorScaling))*bStep;
            %indicate direction of this correction
            bMovePrev=-1;
        else
            %if this move reverses the error direction, reduce future step size, provided error is low.
            if bMovePrev==-1 && popError<0.1;  bStep=bStep*stepDieOff; end
            %adjust b estimate upward, in relation to the error size
            bCurrent=bCurrent+(stepMin+tanh(abs(popError)*errorScaling))*bStep;
            %indicate direction of this correction
            bMovePrev=1;
        end
        
        % if the bigger error is associated with the photo preference assumption
    else
        % reset the stepsize for the beta adjustments
        bStep=bStepBaseline;
        
        %if the preference error is positive
        if prefError>0
            %if this move reverses the error direction, reduce future step size, provided error is low.
            if dMovePrev==1 && prefError<0.1; dStep=dStep*stepDieOff; end
            %adjust d estimate downward, in relation to the error size
            dCurrent=dCurrent-(stepMin+tanh(abs(prefError)*errorScaling))*dStep;
            %indicate direction of this correction
            dMovePrev=-1;
        else
            %if this move reverses the error direction, reduce future step size, provided error is low.
            if dMovePrev==-1 && prefError<0.1;  dStep=dStep*stepDieOff; end
            %adjust d estimate upward, in relation to the error size
            dCurrent=dCurrent+(stepMin+tanh(abs(prefError)*errorScaling))*dStep;
            %indicate direction of this correction
            dMovePrev=1;
        end
        
    end
    
    %number of iterations++
    tick=tick+1;
end

% output all the data
out.modelRun=analyticRun;
out.b=bCurrent;
out.d=dCurrent;
out.b_list=b_list(~isnan(b_list));
out.d_list=d_list(~isnan(d_list));
out.convTime=tick;
out.normalSeason=normals;
