function SI = ScintillationIndex(waveForm, responsitivity,SIThresh,expected)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
waveForm=waveForm(find(waveForm>SIThresh));

TIA=5e3;%1e4 %V/A
amperage=waveForm./TIA;
power=amperage./responsitivity;
detectorArea=0.8e-6;
irrad=power./detectorArea;
square=irrad.^2;
squareMean=mean(square);
meanWave=mean(irrad);
meanPM=meanWave*1000;
meanSquare=meanWave.^2;

SI=squareMean/meanSquare-1;
end

