function out=hedgeMakeStationMap_new(stationBatch,sigma,boundaries,cMap,displayBool)
% hedgeMakeStationMap reads in model data calibrated to regional weather
% stations and makes a map of the contiguous 48 states using that data.
% Used to make Figure 6C.
%=========================================================================
% Usage:
% hedgeMakeStationMap(stationBatch,boundaries,cMap,displayBool)
% Inputs:
%       * stationBatch = matrix of calibrated station data (output of
%            hedgeGeographyAll.m and betHedgeAdvantageCalc.m).
%            Pre-processed to only keep the BH advantage, latitude, and
%            longitude columns
%       * sigma = covariance matrix - how wide/symmetrical is the gaussian
%           convolution e.g. sigma = [0.005 0; 0 0.005];
%       * boundaries = state boundary image, var boundaries in
%            hedgeStateBoundaries.mat
%       * cMap = colorMap for the background interpolation and data points,
%            posneg2 in hedgeColorMaps.mat
%       * displayBool = 1x4 array indicating which display options to use
%            in the final figure, as follows:
%                 [X - - -] = display the interpolated background map
%                 [- X - -] = display state boundaries
%                 [- - X -] = display black points at station locations on the pixel map
%                 [- - - X] = superimpose vector-based data points on the map
% Output:
%       * out = matrix of the background image BvH values

% set the latitude and longitude resolution, and the bounds of each
latRes=.1;
latRange=17:latRes:53;
longRes=.1;
longRange=-130:longRes:-64;

% extract data on stations from station data cell array
latLongs=stationBatch(:,2:3);
BvHs=log(stationBatch(:,4));

%initialize a variable to store the distance of each pixel to all stations
%distsToStats=zeros(size(BvHs));

%initialize variable to store the weight of each station to each lat-long
%combination specified by the latRange and longRange
%weightsToLoc=zeros(size(latRange,2), size(longRange,2), size(latLongs,1));

%initialize the map
llMap=zeros(length(latRange),length(longRange));
llMap2=llMap;

latTick=1; % loop parameter
tic()
% if showing the background interpolated map
if displayBool(1)==1
    %for all lat and long pixels
    for j=latRange
        longTick=1;
        for k=longRange
            
            %for each pixel, calculate the great circle distance to each station
%             for k=1:size(latLongs,1)
%                 a=sin((i-latLongs(k,1))/2)^2 + cos(i)*cos(latLongs(k,1))*sin((j-latLongs(k,2))/2)^2;
%                 c=2*atan2(sqrt(a),sqrt(1-a));
%                 distsToStats(k)=c;
%             end
            
            mu = [j,k]; %location
            %calculate weights to the surrounding weather stations
            weightsToLoc = mvnpdf(latLongs,mu,sigma);
            %calculate bh adv at each lat-long given the surrounding weather stations
            pxColor = sum(weightsToLoc.*BvHs)/sum(weightsToLoc);
            
            %scale and sum the distances by an exponential term, to weight
            %BvH values of close stations more highly
%             statWeights=1./(distsToStats).^3;       %change this exponent to change interpolation
%             pxColor=sum(BvHs.*statWeights)/sum(statWeights);
            
            %save this pixel value
            llMap(latTick,longTick)=pxColor;
            
            %increment the ticker
            longTick=longTick+1;
        end
        latTick=latTick+1;
    end
    llMap2=llMap; %save into working map
end
toc()
% if showing the state boundaries
if displayBool(2)==1
    if size(boundaries,1)>1 % you can pass a scalar instead of the boundary display bool if you don't want to show it
        llMap2(flipud(boundaries))=0;
    end
end

% if showing pixels at station locations
if displayBool(3)==1
    
    %for all stations
    for i=1:size(latLongs,1)
        % get the station lat long
        lati=latLongs(i,1);
        longi=latLongs(i,2);
        
        % find the closest pixel
        sRow=(latRange-lati).^2==min((latRange-lati).^2);
        sCol=(longRange-longi).^2==min((longRange-longi).^2);
        
        % set those pixels to black/extreme color
        llMap2(sRow,sCol)=-Inf;
    end
end

%set the scale of the colormap
colorScale=512*10;
colorOffset=512;

%start the figure
figure;
hold on;

% if displaying something on the pixel map background
if displayBool(1)>0 && displayBool(2)>0
    image((llMap2)*colorScale+colorOffset); %display the image with the right color
    colormap(cMap)
elseif displayBool(1)>0 && displayBool(2)==0
    image((llMap2)*colorScale+colorOffset); %display the image with the right color
    colormap(cMap)
elseif displayBool(1)==0 && displayBool(2)>0
    image((llMap2)*colorScale+1024); %white background
    colormap(cMap)
end

% if displaying vector-based versions of the station positions on top of
% the pixel map
if displayBool(4)==1
    %start a vector for the colors of the points
    BvHs=round(BvHs*colorScale+colorOffset);
    BvHs(BvHs>length(cMap))=length(cMap);
    BvHs(BvHs<1)=1;
    %get the pixel positions of these lat longs
    %latLongs=latLongs/(pi()/180);
    latLongs(:,1)=(latLongs(:,1)-18)*11+5;  % these values would need to be adjusted if the bounds of the map are changed
    latLongs(:,2)=(latLongs(:,2)-(-130))*10.8-59;
    %draw the points
    scatter(latLongs(:,2),latLongs(:,1),40,cMap(BvHs,:),'filled','LineWidth', 1, 'MarkerEdgeColor', 'k')
end

%frame the image
xlim([1 651]);
ylim([1 351]);

%save the BvH map data as output
out=flipud(llMap2);




