function out = summarizeF1TempPref(F1data_fltd, midParent_tPref)

%takes in the F1 data, groups males by cross and averages the tPref
%filter out crosses that are not present in both datasets

%group males by cross and average the tPref
F1crosses = unique(string(F1data_fltd(:,15))); %find all unique crosses

data = cell(length(F1crosses),6);
for i = 1:length(F1crosses)
    t = F1data_fltd(string(F1data_fltd(:,15)) == F1crosses(i),:); %temp data frame
    data{i,1} = nanmean(cell2mat(t(:,1))); %average occupancy
    data{i,2} = nanmean(cell2mat(t(:,21))); %average degC pref
    data{i,3} = nanstd(cell2mat(t(:,1))); %st dev occupancy
    data{i,4} = nanstd(cell2mat(t(:,21))); %st dev degC pref
    data{i,5} = size(cell2mat(t(:,21)),1); %number of males
    data{i,6} = F1crosses(i); %the cross label
end

%filter out crosses with no midparent value and < 3 males tested and
%combine midparent vals with F1 data

idx = cell2mat(data(:,5)) < 3; %do not include crosses with < 3 males tested
data = data(~idx,:);

%include only crosses with midparent vals
[~,idx1,idx2] = intersect(midParent_tPref.crosses, string(data(:,6)),'stable');
%[F1crosses(idx2) midParent_tPref.crosses(idx1)];

%store the data
out.avgOccupancy = cell2mat(data(idx2,1));
out.avgDegC = cell2mat(data(idx2,2));
out.stdOccupancy = cell2mat(data(idx2,3));
out.stdDegC = cell2mat(data(idx2,4));
out.sample = cell2mat(data(idx2,5));
out.F1crosses = string(data(idx2,6));

out.midParent_occ = midParent_tPref.midParent_occ(idx1);
out.midParent_degC = midParent_tPref.midParent_degC(idx1);
out.midParent_crosses = midParent_tPref.crosses(idx1);

out.locations = midParent_tPref.locations(idx1);
end