function out = tempPrefToDegrees(tempPref, hotSide, box, tunnelTemps)

%transforms the 0 - 1 scaling of temp pref score to degrees based on
%weighted average of time spent on cold and hot side
%uses tunnel temperature data .mat file for the transformation

prefDegrees = cell(size(tempPref,1),1);
tunnelArray = NaN(size(tempPref,1),2);

tunnelsL = tunnelTemps(ismember(cellstr(tunnelTemps(:,5)),{'L'}),:); %tunnels with hot side L
tunnelsR = tunnelTemps(ismember(cellstr(tunnelTemps(:,5)),{'R'}),:); %tunnels with hot side R


for i = 1:size(tempPref,1)
    if strcmp(hotSide{i}, 'L')
        if box{i} == 1
           tun = tunnelsL(cell2mat(tunnelsL(:,7)) == 1,:);
           idx = find(cell2mat(tun(:,1)) == tempPref{i,10});
           prefDegrees{i} = tun{idx,2}*tempPref{i,1} + tun{idx,3}*(1-tempPref{i,1});
           tunnelArray(i,:) = [cell2mat(tun(idx,2)) cell2mat(tun(idx,3))];
        end
        if box{i} == 2
           tun = tunnelsL(cell2mat(tunnelsL(:,7)) == 2,:);
           idx = find(cell2mat(tun(:,1)) == tempPref{i,10});
           prefDegrees{i} = tun{idx,2}*tempPref{i,1} + tun{idx,3}*(1-tempPref{i,1});
           tunnelArray(i,:) = [cell2mat(tun(idx,2)) cell2mat(tun(idx,3))];
        end
        if box{i} == 3
           tun = tunnelsL(cell2mat(tunnelsL(:,7)) == 3,:);
           idx = find(cell2mat(tun(:,1)) == tempPref{i,10});
           prefDegrees{i} = tun{idx,2}*tempPref{i,1} + tun{idx,3}*(1-tempPref{i,1});
           tunnelArray(i,:) = [cell2mat(tun(idx,2)) cell2mat(tun(idx,3))];
        end
    end
    if strcmp(hotSide{i},'R')
       if box{i} == 1
           tun = tunnelsR(cell2mat(tunnelsR(:,7)) == 1,:);
           idx = find(cell2mat(tun(:,1)) == tempPref{i,10});
           prefDegrees{i} = tun{idx,2}*tempPref{i,1} + tun{idx,3}*(1-tempPref{i,1});
           tunnelArray(i,:) = [cell2mat(tun(idx,2)) cell2mat(tun(idx,3))];
        end
        if box{i} == 2
           tun = tunnelsR(cell2mat(tunnelsR(:,7)) == 2,:);
           idx = find(cell2mat(tun(:,1)) == tempPref{i,10});
           prefDegrees{i} = tun{idx,2}*tempPref{i,1} + tun{idx,3}*(1-tempPref{i,1});
           tunnelArray(i,:) = [cell2mat(tun(idx,2)) cell2mat(tun(idx,3))];
        end
        if box{i} == 3
           tun = tunnelsR(cell2mat(tunnelsR(:,7)) == 3,:);
           idx = find(cell2mat(tun(:,1)) == tempPref{i,10});
           prefDegrees{i} = tun{idx,2}*tempPref{i,1} + tun{idx,3}*(1-tempPref{i,1});
           tunnelArray(i,:) = [cell2mat(tun(idx,2)) cell2mat(tun(idx,3))];
        end 
    end  
end
out = [tempPref,prefDegrees, num2cell(tunnelArray)];