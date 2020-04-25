function out = splitROI(roiBounds, roiCenters)

% splits ROI into two halves with a center strip down the middle as a
% 'choice point' (~ 2% of total tunnel length)

left = roiBounds(:,1);
right = roiBounds(:,1)+roiBounds(:,3);

centerR = roiCenters(:,1)+(0.02*roiBounds(:,3))./2;
centerL = roiCenters(:,1)-(0.02*roiBounds(:,3))./2;

%centerR = roiCenters(:,1)+1;
%centerL = roiCenters(:,1)-4;

out = [left, right, centerL, centerR];