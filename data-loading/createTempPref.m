function [out1, out2] = createTempPref(expmts, files, hotSide, brkpt)
%hotSide is a string vector of L or R depending on what side of the tray
%the hot side was

%brkpt is 2 numbers: which portion of the centroid data 
%you want to examine: [0 1] is all, [0 0.5] is first half, [0 0.25 ] is first quarter, etc
%[0.25 0.75] is start of hour 2 till end of hour 3 for example

matches = regexp(string({files.name}), '(Thermo|Track)\w+');
if iscell(matches) == 0
    matches = num2cell(matches);
end
idx = ~cellfun('isempty',matches);
files = files(idx); %remove non-tracking .mat files

for i = 1:size(files,1)
    name = replace(files(i).name, '-', '_');
    load([files(i).folder '/' files(i).name]);
    expmts.([name(28:end-4) '_' name(1:19)]) = expmt;
end

tempPref = [];
fields = fieldnames(expmts);
for i = 1:size(fields)
    start = floor(size(expmts.(fields{i}).Centroid.data(:,1,:),1)*brkpt(1))+1;
    stop = ceil(size(expmts.(fields{i}).Centroid.data(:,1,:),1)*brkpt(2));
    expmts.(fields{i}).tempPref = twoChoicePref(expmts.(fields{i}).Centroid.data(start:stop,:,:), ...
                                expmts.(fields{i}).Time.data(start:stop), ...
                                expmts.(fields{i}).ROI.centers, expmts.(fields{i}).ROI.bounds,...
                                expmts.(fields{i}).nTracks, hotSide{i});
%     expmts.(fields{i}).tempPref = [expmts.(fields{i}).tempPref,...
%                                   num2cell(table2array(expmts.(fields{i}).labels_table(:,4)))];%,...
%                                 %repelem(i,expmts.(fields{i}).nTracks,1)];

%     expmts.(fields{i}).tempPref = activityThresholding(expmts.(fields{i}).tempPref,...
%                                                        hotSide{i},9,310,10,0.25);
    tempPref = [tempPref; expmts.(fields{i}).tempPref];  
    
end

out1 = expmts;
out2 = tempPref;