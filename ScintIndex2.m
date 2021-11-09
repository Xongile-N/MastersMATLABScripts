function [SI,logVar,meanWave,SIs] = ScintIndex2(waveFormOrig,responsitivity,SIThresh,periodCount)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    SIs=zeros(5,1);
    periodLength=length(waveFormOrig)/periodCount;
    for count=1:periodCount
        waveForm=waveFormOrig(1+(count-1)*periodLength:count*periodLength);
        waveForm=waveForm(find(waveForm>SIThresh));
        waveForm=smooth(waveForm,20);

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
        squareMean=expectedValue(square);
        meanWave=expectedValue(irrad);
        meanSquare=meanWave^2;
        vari=squareMean-meanSquare;
        SIs(count)=vari/meanSquare;

    end
    SI=mean(SIs);
end

