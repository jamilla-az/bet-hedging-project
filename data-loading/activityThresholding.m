function out = activityThresholding(tempPref, hotSide, dist, time, subsampleRate, thresh)

%thresholds data based on activity
%remove fly if more than thresh% of trial is spent inactive 


pref2 = removeInactiveBouts(tempPref(:,3), tempPref(:,4:7),...
                            tempPref(:,8:9), hotSide, dist, time, subsampleRate);
                        
tempPref(:,1) = pref2(:,1);
tempPref(:,3) = pref2(:,2);
tempPref(:,end+1) = pref2(:,3);

tempPref = tempPref(cell2mat(tempPref(:,2)) > 1000,:);
%remove tunnels with completely inactive flies or empty tunnels

out = tempPref(cell2mat(tempPref(:,end)) >= thresh,:);
%out = tempPref;