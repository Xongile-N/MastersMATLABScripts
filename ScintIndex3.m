function [SI,SI_O,meanWave] = ScintIndex1(waveFormOrig,responsitivity,SIThresh,pos)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
waveForm=waveFormOrig;
waveForm=waveForm(find(waveForm>SIThresh));
%waveForm=smooth(waveForm,20);
test=0.3;
TIA=5e3;%1e4 %V/A
amperage=waveForm./TIA;
power=amperage./responsitivity;
detectorArea=0.8e-6;
irrad=power./detectorArea;
deviation=std(irrad);
variance=var(irrad);
ave=mean(irrad);
logVar=log(variance);
square=irrad.^2;
meanWave=expectedValue(irrad);

squareMean=expectedValue(square);
meanSquare=meanWave^2;
vari=squareMean-meanSquare;
testIrrad=(test/TIA/responsitivity/detectorArea);
SI1=squareMean/(testIrrad^2)-1;
SI0=squareMean/meanSquare-1;
SI_O=vari/meanSquare;

end

