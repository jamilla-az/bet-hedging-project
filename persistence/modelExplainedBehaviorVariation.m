% model behavioral variance explained as a function of behavioral persistence
% and true correlation between latent variable of interest with behavior
% Matt Churgin, de Bivort lab 2019
% modified by jamilla a, 2-22-2019 for SomA trpA1 quantification data
%clear all
%close all

numflies=18; % number of flies
iters=100; % number of iterations. 100 is a good choice
nsteps=40; % model step size. 40 gives nice X-Y resolution but takes a while

behaviorcorr=[0:1/nsteps:1];
trueLatentCorr=[0:1/nsteps:1];

% behavior is assumed to come from a normal distribution
meanBehavior=0.26; % population mean behavioral measurement - calc from SomA occupancy data
standarddevBehavior=0.12; % population behavioral standard deviation - calc from SomA occupancy data

varianceExplained=zeros(iters,length(behaviorcorr),length(trueLatentCorr));

for i=1:iters
    flyData{i}=zeros(numflies,3,length(behaviorcorr),length(trueLatentCorr));
    for k=1:length(behaviorcorr)
        for kk=1:length(trueLatentCorr)
            
            firstrandomnumber=standarddevBehavior*randn(numflies,1);
            secondrandomnumber=standarddevBehavior*randn(numflies,1);
            thirdrandomnumber=standarddevBehavior*randn(numflies,1);
            
            % generate each fly's behavior measurement
            measuredbehavior=meanBehavior+firstrandomnumber*standarddevBehavior;
            
            % generate expected fly behavior at time of latent predictor measurement (dependent on
            % behavioral persistence correlation value, behaviorcorr(k))
            expectedBehavior=meanBehavior+behaviorcorr(k)*firstrandomnumber+sqrt(1-behaviorcorr(k)^2)*secondrandomnumber;
            
            % generate ideal behavior predicted from imaging (dependent on
            % true correlation between latent predictor and behavior, trueLatentCorr(kk))
            behaviorPredictionIdeal=meanBehavior+(expectedBehavior-meanBehavior)*trueLatentCorr(kk)+thirdrandomnumber*(sqrt(1-trueLatentCorr(kk)^2));
            
            flyData{i}(:,:,k,kk)=[measuredbehavior expectedBehavior behaviorPredictionIdeal];
            
            % predict measuredbehavior from behaviorPredictionIdeal
            linmodel=fitlm(flyData{i}(:,3,k,kk),flyData{i}(:,1,k,kk));
            
            % save R^2
            varianceExplained(i,k,kk)=linmodel.Rsquared.Adjusted;
        end
    end
    disp(['iteration ' num2str(i)])
end
finalVarianceExplained=squeeze(mean(varianceExplained,1));
disp('done :)')

figure
imagesc(finalVarianceExplained)
hold on
[C,h] = contour(finalVarianceExplained,[0.05,0.1 0.2 0.3 0.4 0.5]);
clabel(C,h,'FontSize',15)
h.LineWidth = 3;
h.LineColor='k';
h.LineStyle=':';
ylabel('behavioral persistence')
xlabel('normalized expression-behavior correlation')
hcb=colorbar;
title(hcb,'R^2')
set(gca,'XTick',[1:round(size(finalVarianceExplained,2)/10):size(finalVarianceExplained,2)])
set(gca,'YTick',[1:round(size(finalVarianceExplained,1)/10):size(finalVarianceExplained,1)])
set(gca,'XTickLabel',[trueLatentCorr(1:round(length(trueLatentCorr)/10):end)])
set(gca,'YTickLabel',[behaviorcorr(1:round(length(behaviorcorr)/10):end)])
set(gca,'FontSize',15)


