function out = plot4hrTracks(tempPref, subsampleRate, varargin)
% author: jamilla az, debivort lab

% plots all tracks (or plots 10 randomly chosen tracks from the tempPref
% array) including the center line; track is colored in red or blue
% depending on whether points were in the hot or cold side

%temp pref: this is the output of createTempPref

%subsample rate: are you taking only every X frame? if not, then you can
%just specify 1

%varargin: specify the cell string of which side is hot (L/R) from the temp
%pref cell array - otherwise it will just assume this is the 16th column of the
%tempPref cell array. There should be one value per track you are trying to
%plot e.g. 40 tracks, 40 'L' or 'R' values in cell string format. 

%filter out completely empty tunnels or flies that are dead on arrival
tempPref = tempPref(cell2mat(tempPref(:,2)) > 10,:);
%create hot side vector from argument 3 and filter it too
if ~isempty(varargin) == 1
    hotSide = varargin{1};
    hotSide = hotSide(cell2mat(tempPref(:,2)) > 10);  
end

%plot all remaining flies 

dim = ceil(size(tempPref,1)/5)*5; %dimensions of plot grid to plot all flies
idx = 1:size(tempPref,1); %grab all the flies from the tempPref object
%idx = randsample(1:size(tempPref,1),10); %plot random tracks from tempPref
colors = [255/255 128/255 0; 0 128/255 255/255]; %colors for cold/hot

%this is the number of frames from your experiment - you can find this
%value in  the 3rd column of the output of createTempPref. I have this
%number because I have a 4hr experiment. 
n = 143000; 

%create a time vector (in fractions of an hour). You can change the
%denominator from 600 to something else if you don't want fractions of an
%hour
time = repelem(subsampleRate, ceil(n/subsampleRate))';
time = cumsum(time);
time = time(1:end)./600;

for i = 1:length(idx)
    
    subplot(dim/5,5,i); %make separate plot in the plot grid
    
    %truncate all position tracks so they match the length of the time
    %vector
    tracks = tempPref{idx(i),3};
    if length(tracks) > length(time)
        tracks = tracks(1:length(time));
    end
    
    if length(time) > length(tracks)
        time = time(1:length(tracks));
    end
    
   %make a linear vector from first element of time to last element of time
   %of 10000 evenly spaced points
    xi = linspace(time(1), time(end), 10000);
   %linearly interpolate the track positions over time - makes for a smoother plot
    yi = interp1(time,tracks,xi);
    
    %if hotSide is specified explicitly in the arguments
    if ~isempty(varargin) == 1
        if strcmp(hotSide{idx(i)}, 'R') %evaluate which side is hot
            ci = yi < tempPref{idx(i),8}; %center line
            %plot tracks and color them
            h = patch([xi NaN], [yi NaN], [ci NaN]);
            set(h, 'edgecolor', 'interp','LineWidth', 1);
            set(gca, 'YTick', [])
            ylim([min(tracks) max(tracks)]);
            xlim([0 max(time)]);
            title(num2str(round(tempPref{idx(i),1},2)), 'FontSize', 9);
            %set(gca,'XTick',[]);
            colormap(colors);
        else
            ci = yi > tempPref{idx(i),8}; %center line
            %plot tracks and color them
            h = patch([xi NaN], [yi NaN], [ci NaN]);
            set(h, 'edgecolor', 'interp', 'LineWidth', 1);
            set(gca, 'YTick', [])
            ylim([min(tracks) max(tracks)]);
            xlim([0 max(time)]);
            title(num2str(round(tempPref{idx(i),1},2)), 'FontSize', 9);
            %set(gca,'XTick',[]);
            colormap(colors);
        end
    else
        %if hotSide is not specified explicitly
       if strcmp(tempPref{idx(i),16}, 'R') %evaluate which side is hot
            ci = yi < tempPref{idx(i),8}; %center line
            %plot tracks and color them
            h = patch([xi NaN], [yi NaN], [ci NaN]);
            set(h, 'edgecolor', 'interp','LineWidth', 1);
            set(gca, 'YTick', [])
            ylim([min(tracks) max(tracks)]);
            xlim([0 max(time)]);
            title(num2str(round(tempPref{idx(i),1},2)), 'FontSize', 9);
            %set(gca,'XTick',[]);
            colormap(colors);
       else
            ci = yi > tempPref{idx(i),8}; %center line
            %plot tracks and color them
            h = patch([xi NaN], [yi NaN], [ci NaN]);
            set(h, 'edgecolor', 'interp', 'LineWidth', 1);
            set(gca, 'YTick', [])
            ylim([min(tracks) max(tracks)]);
            xlim([0 max(time)]);
            title(num2str(round(tempPref{idx(i),1},2)), 'FontSize', 9);
            %set(gca,'XTick',[]);
            colormap(colors);
       end
    
    end
end

out = gcf; %show the figure with all the tracks, colored by hot/cold sides
