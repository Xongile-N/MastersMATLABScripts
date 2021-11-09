function [SI,logVar,meanWave] = ScintIndex1(waveFormOrig,responsitivity,SIThresh)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
waveForm=waveFormOrig;
waveForm=waveForm(find(waveForm>SIThresh));
% %waveForm=smooth(waveForm,20);
% test=0.3;
% TIA=5e3;%1e4 %V/A
% amperage=waveForm./TIA;
% power=amperage./responsitivity;
% detectorArea=0.8e-6;
%irrad=power./detectorArea;
irrad=waveForm;
deviation=std(irrad);
variance=var(irrad);
ave=mean(irrad);
logVar=log(variance);
square=irrad.^2;
meanWave=expectedValue(irrad);

squareMean=expectedValue(square);
meanSquare=meanWave^2;
vari=squareMean-meanSquare;
SI0=squareMean/meanSquare-1;
SI=vari/meanSquare;

end

