function [out1, out2] = occupancyByDistTrav(tempPref)

%input is tempOFF (n x 10 cell array)
%hotSide = L
v = (100:100:60000);
tPref = NaN(size(v,2), size(tempPref,1));
distTrav = NaN(size(v,2), size(tempPref,1));

for i = 1:size(tempPref,1)
    cent = tempPref{i,3};
    
%     idx = mod((1:size(cent,1)), 5) == 0; %subsample the centroid data
%     cent = cent(idx);
    
    d = abs(diff(cent));
    
%     %remove inactive bouts
%     pause = d < 2; %find pauses where fly moves less than 2px between points
%     startPause = find(diff(pause) == 1);
%     endPause = find(diff(pause) == -1);
%    
%     if length(startPause) > length(endPause)
%        endPause(end+1) = length(pause);
%     end
%    
%     if length(endPause) > length(startPause)
%        startPause = [1;startPause];
%     end
%    
%     pauseTime = (endPause - startPause)*30;
%    
%     startInactiveBout= startPause(pauseTime >= 10*30); %5min
%     endInactiveBout = endPause(pauseTime >= 10*30);
%    
%     if isempty(startInactiveBout) == 0
%        for k = 1:length(startInactiveBout)
%             cent(startInactiveBout(k)+2:endInactiveBout(k)+2) = NaN;
%        end
%     end
    %
    
    d = [0;cumsum(d)];
    
    bounds = [cell2mat(tempPref(i,4)),cell2mat(tempPref(i,5)),...
              cell2mat(tempPref(i,6)),cell2mat(tempPref(i,7))];
    centers = [cell2mat(tempPref(i,8)),cell2mat(tempPref(i,9))];
    
    ROIsplit = splitROI(bounds, centers);
    
    pref = NaN(size(v,2),1);
    dist = NaN(size(v,2),1);
    
    for n = 1:size(v,2)
        if v(n) <= d(end)
            
            brkpt = find(d <= v(n), 1, 'last'); %find frame
            dist(n) = d(brkpt);
            
            idxL = cent(1:brkpt) > ROIsplit(1) & cent(1:brkpt) < ROIsplit(3);
            idxR = cent(1:brkpt) < ROIsplit(2) & cent(1:brkpt) > ROIsplit(4);
    
            pref(n) = sum(idxL)/(sum(idxR)+sum(idxL));
   
        end
    end
 tPref(:,i) = pref;
 distTrav(:,i) = dist;
    
end
out1 = tPref;
out2 = distTrav;
end


