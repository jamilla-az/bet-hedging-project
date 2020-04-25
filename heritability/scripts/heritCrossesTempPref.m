function out = heritCrossesTempPref(herit_crosses, parents_fltd)

%makes struct with the tempPref of mom/dad, and avg tempPref of cross
%includes both the occupancy data (col1 of parents_fltd) and degC (col21 of
%parents_fltd)

%filter out all crosses that were not tested (230 remain)
idx = cellfun(@(x) x =='', herit_crosses(:,5));
hc = herit_crosses(~idx,:);

%filter out crosses with no tempPref data for a parent (225 remain)
%females
idx = ismember(string(hc(:,1)),string(parents_fltd(:,15)));
hc = hc(idx,:);

% males
idx = ismember(string(hc(:,2)),string(parents_fltd(:,15)));
hc = hc(idx,:);

out.allLabels = string(hc);
out.crosses = string(hc(:,4));
out.locations = string(hc(:,3));

%find the female tempPref and store
fem = string(hc(:,1));
[~,~,idx2] = intersect(fem, string(parents_fltd(:,15)),'stable');
out.femTempPref_occ = cell2mat(parents_fltd(idx2,1));
out.femTempPref_degC = cell2mat(parents_fltd(idx2,21));

%find the male tempPref and store 
male = string(hc(:,2));
[~,~,idx2] = intersect(male, string(parents_fltd(:,15)),'stable');
out.maleTempPref_occ = cell2mat(parents_fltd(idx2,1));
out.maleTempPref_degC = cell2mat(parents_fltd(idx2,21));

%average tempPrefs of male/female to get mid-parent tempPref
out.midParent_occ = mean([out.femTempPref_occ out.maleTempPref_occ],2);
out.midParent_degC = mean([out.femTempPref_degC out.maleTempPref_degC],2);

end 