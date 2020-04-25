function [hotBouts, coldBouts, middleBouts] = createBoutArray(centroids,...
                                                           centers, hotSide)
%takes track of each fly and separates it into bouts (centroid positions)
%on hot and cold sides of two-choice assay
%end result are two 'bags' of cold side and hot side bouts from all flies
%in the file

%centers = cell2mat(centers);
hotBouts = cell(length(centroids),1);
coldBouts = cell(length(centroids),1);
middleBouts = cell(length(centroids),1);


for i = 1:length(centroids)
    idxL = centroids{i} < centers(i,1); %left
    idxR = centroids{i} > centers(i,2); %right
    idxC = centroids{i} < centers(i,2) & centroids{i} > centers(i,1); %middle
    LEntry = find(diff(idxL) == 1); %entry into the left side
    REntry = find(diff(idxR) == 1); %entry into the right side
    LExit = find(diff(idxL) == -1); %exit from the left side
    RExit = find(diff(idxR) == -1); %exit from the right side
    CEntry = find(diff(idxC) == 1); %entry to the middle
    CExit = find(diff(idxC) == -1); %exit from the middle
    
    if ~isempty(LEntry) && ~isempty(LExit)
        if LEntry(end) > LExit(end)
           LExit = [LExit;length(centroids{i})-1];
           %if fly enters L side but does not exit before the end of the assay, 
           %assign last frame as exit
        end

        if LEntry(1) > LExit(1)
           LEntry = [0;LEntry];
           %if fly starts on L side and exits L side as its first move, put
           %first LEntry as 0
        end
    end
    if ~isempty(REntry) && ~isempty(RExit)
        if REntry(end) > RExit(end)
           RExit = [RExit;length(centroids{i})-1];
           %if fly enters R side but does not exit before the end of the assay, 
           %assign last frame as exit
        end

        if REntry(1) > RExit(1)
           REntry = [0;REntry];
           %if fly starts on R side and exits R side as its first move, put
           %first R entry as 0
        end
    end
    if ~isempty(CEntry) && ~isempty(CExit)
        if CEntry(end) > CExit(end)
           CExit = [CExit;length(centroids{i})-1];
           %if fly enters center but does not exit before the end of the assay, 
           %assign last frame as center ext
        end

        if CEntry(1) > CExit(1)
           CEntry = [0;CEntry];
           %if fly starts in center and exits center as its first move, put
           %first CEntry as 0
        end
    end
    
    LBouts = cell(length(LEntry),1);
    RBouts = cell(length(REntry),1);
    CBouts = cell(length(CEntry),1);
    
    if ~isempty(LEntry) && ~isempty(LExit)
        for n = 1:length(LEntry)
           LBouts{n} = centroids{i}(LEntry(n)+1:LExit(n)+1);
           %grab left bout from centroid track
        end    
    end
    
    if ~isempty(REntry) && ~isempty(RExit)
        for n = 1:length(REntry)
           RBouts{n} = centroids{i}(REntry(n)+1:RExit(n)+1);
           %grab right bout from centroid track
        end 
    end
    
    if ~isempty(CEntry) && ~isempty(CExit)
        for n = 1:length(CEntry)
           CBouts{n} = centroids{i}(CEntry(n)+1:CExit(n)+1);
           %grab center bout from centroid track
        end 
    end
    
    if strcmp(hotSide{i}, 'L') == 1
       hotBouts{i} = LBouts;
       coldBouts{i} = RBouts;
       middleBouts{i} = CBouts;
    end
    if strcmp(hotSide{i}, 'R') == 1
       hotBouts{i} = RBouts;
       coldBouts{i} = LBouts;
       middleBouts{i} = CBouts;
    end   
end
                        
end

