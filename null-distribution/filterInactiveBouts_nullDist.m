function out  = filterInactiveBouts_nullDist(sim_run, sim_lab, subsampleRate, dist, time)

d = abs(diff(sim_run)); %take difference in distance between time points
pause = d < dist; %find pauses where fly moves less than 5px between time points
startPause = find(diff(pause) == 1);
endPause = find(diff(pause) == -1);

if isempty(endPause) == 1
   endPause = length(pause);
end

if isempty(startPause) == 0 && isempty(endPause) == 0
    if startPause(1) > endPause(1)
        startPause = [1;startPause];
    end

    if length(startPause) > length(endPause)
        endPause = [endPause;length(pause)];
    end
end

pauseTime = (endPause - startPause)*subsampleRate;

startInactiveBout= startPause(pauseTime >= time); %time
endInactiveBout = endPause(pauseTime >= time);

if isempty(startInactiveBout) == 0
   for k = 1:length(startInactiveBout)
        sim_run(startInactiveBout(k)+1:endInactiveBout(k)+1) = NaN;
        sim_lab(startInactiveBout(k)+1:endInactiveBout(k)+1) = NaN;
   end
end

activityMonitor = sum(~isnan(sim_run))/length(sim_run);
pref = nansum(sim_lab == 'H')/(nansum(sim_lab == 'H')+nansum(sim_lab == 'C')); 
out = {pref {sim_run} {sim_lab} activityMonitor};

end

