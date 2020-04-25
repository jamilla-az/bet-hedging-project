function out = removeInactiveBouts(centroids, bounds, centers, hotSide,...
                                    dist, time, subsampleRate)

%removes bouts where the fly does not move for >= time (min) and recalculates
%temperature preference and centroids

bounds = cell2mat(bounds);
centers = cell2mat(centers);

ROIsplit = splitROI(bounds, centers);

pref = NaN(length(centroids),1);
activityMonitor = NaN(length(centroids),1);

for i = 1:length(centroids)
    
   idx = 1:subsampleRate:length(centroids{i}); %subsample
   centroids{i} = centroids{i}(idx);
   
   
   d = abs(diff(centroids{i})); %take difference in distance between time points
   pause = d < dist; %find pauses where fly moves less than 'dist' px between time points
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
            centroids{i}(startInactiveBout(k)+1:endInactiveBout(k)+1) = NaN;
       end
   end
   
   activityMonitor(i) = sum(~isnan(centroids{i}))/length(centroids{i});
   
   idxL = centroids{i} > ROIsplit(i,1) & centroids{i} < ROIsplit(i,3);
   idxR = centroids{i} < ROIsplit(i,2) & centroids{i} > ROIsplit(i,4);
   
   if strcmp(string(hotSide(i)), 'L') == 1
        pref(i) = sum(idxL)/(sum(idxR)+sum(idxL));
   end
   if strcmp(string(hotSide(i)), 'R') == 1
        pref(i) = sum(idxR)/(sum(idxR)+sum(idxL));
   end
   
   %subsample centroid for easier plotting later

   
end
out = [num2cell(pref), centroids, num2cell(activityMonitor)];
