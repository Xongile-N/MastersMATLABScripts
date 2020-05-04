function binRes=waveToBinaryPeriod(waveform,threshold, frequency, timeStep)
clc
length(waveform)
threshold
totalTime=length(waveform)*timeStep;
period=1/frequency;

symbolDuration=period/2;
timeStep
binRes=zeros(ceil(length(waveform)*timeStep/symbolDuration),1);
length(binRes)
% index=floor(symbolDuration/2)
% 
     timeSum=0;

index=1;
 for count=1:length(binRes)
     aveV=0;
     iterations=0;
     while timeSum<symbolDuration && index<length(waveform)
        timeSum=timeSum+timeStep;
     aveV=waveform(index)+aveV;
     
     index=index+1;
     iterations=iterations+1;
     end
     iterations;
     timeSum=timeSum-symbolDuration;
     aveV=aveV/iterations;
     [count,aveV*10000,index, 5000, 10000*waveform(index-iterations:index-1)];
     
     binRes(count)=aveV>threshold;
     %index=index+symbolDuration;
 end
 binRes=binRes;
 bitAve=mean(binRes)
end

