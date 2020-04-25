function out = twoChoicePref(centroid, time, centers, bounds, nTracks, hotSide)

%create preference score based on occupancy of the two sides, discounting
%all centroid positions that fall in the middle (the choice point)
ROIsplit = splitROI(bounds, centers);

pref = NaN(nTracks,1);
dist = NaN(nTracks,1);
cent = cell(nTracks,1);

% if strcmp(treatment, 'tempON') == 1
%     trt = repelem(1, nTracks,1);
% end
% if strcmp(treatment, 'tempOFF') == 1
%     trt = repelem(0, nTracks,1);
% end

for i = 1:nTracks
    idxL = centroid(:,1,i) > ROIsplit(i,1) & centroid(:,1,i) < ROIsplit(i,3);
    idxR = centroid(:,1,i) < ROIsplit(i,2) & centroid(:,1,i) > ROIsplit(i,4);
   
   if strcmp(hotSide, 'L') == 1
        pref(i) = sum(idxL)/(sum(idxR)+sum(idxL));
   end
   if strcmp(hotSide, 'R') == 1
        pref(i) = sum(idxR)/(sum(idxR)+sum(idxL));
   end
   
   d = NaN(size(centroid,1)-1,1);
   for n = 1:size(centroid,1)-1
        d(n) = abs(centroid(n+1,1,i) - centroid(n,1,i));
   end
   dist(i) = sum(d);
   
if length(centroid(:,1,i)) > 144000
   tc = cumsum(time);
   idx = diff(mod(tc, 0.1)) < 0; %downsample to 10Hz if needed
   cent{i} = centroid(idx, 1, i);
else
    cent{i} = centroid(:, 1, i);
end
   idx = 1:10:length(cent{i}); %subsample to 1Hz to lower file size
   cent{i} = cent{i}(idx);
end

out = [num2cell(pref), num2cell(dist), cent, num2cell(bounds), num2cell(centers)];