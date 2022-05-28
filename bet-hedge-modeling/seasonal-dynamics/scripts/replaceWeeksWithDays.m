function out = replaceWeeksWithDays(CollectionWeeks,tempPref)

%takes in vector of week #s from the seasonal collections (one week label
%per fly tested) and replaces it with the 2018 day # marking the start of the
%week 
%CollectionWeeks = array with unique collection weeks and their 2018 day nums
%tempPref = collected data with week numbers to be replaced 

idx = ismember(cell2mat(CollectionWeeks(:,2)),...
    unique(cell2mat(tempPref(:,16)))); %find the weeks collected
uniqDayNums = cell2mat(CollectionWeeks(idx,3)); %transform to dayNums
weeks = unique(cell2mat(tempPref(:,16))); %unique week nums

dayNums = cell2mat(tempPref(:,16)); %week nums for transformation

for i = 1:length(weeks)
  idx = cell2mat(tempPref(:,16)) == weeks(i);
  dayNums(idx) = repmat(uniqDayNums(i), sum(idx), 1); 
end

out = dayNums;
end


