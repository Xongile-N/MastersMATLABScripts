function [resBin,recClock,baseClock] = clockRecovery(waveForm,baseFreq,Fs,perf, useThresh, thresh)
T=1/Fs;
L=length(waveForm);
timeBase = (0:L-1)*T;  
baseSampleFreq=2*baseFreq;
%baseSampleFreq=baseFreq;

transition=false;
high=false;
basePeriod=1/baseSampleFreq;
halfPeriod=basePeriod/2;
timeElapsed=0;
samplingClock=zeros(1,length(timeBase));


state=1;
threshold=mean(waveForm);
if(nargin==6)
    if(useThresh)
    threshold=thresh;
    end
end
timeStep=abs(timeBase(4)-timeBase(3));
for count=1:length(samplingClock)
    transition=bitxor(waveForm(count)<threshold,high);
if(transition)
    high=~high;
    timeElapsed=0;
    state=1;
    
elseif(timeElapsed>=halfPeriod)
    timeElapsed=timeElapsed-halfPeriod;
    state=mod(state+1,2);
end
    samplingClock(count)=state;
    timeElapsed=timeElapsed+timeStep;
end
baseClock=0.5*square(2*pi*baseSampleFreq*timeBase)+0.5;
%plot(timeBase,samplingClock-trueSquare);

     aveV=0;
     iterations=0;
  sampling=false;
  index=1;
if(perf)  
    %samplingClock=0.5*square(2*pi*baseSampleFreq*timeBase)+0.5;
                state=1;
    basePeriod=1/baseSampleFreq;
    halfPeriod=basePeriod/2;
    timeStep=timeStep;
    timeElapsed=0;
    for count=1:length(samplingClock)
        if(timeElapsed>=halfPeriod)
            timeElapsed=timeElapsed-halfPeriod;
            state=mod(state+1,2);
        end
            samplingClock(count)=state;
            timeElapsed=timeElapsed+timeStep;

    end
end
sampleCount=halfPeriod/timeStep;
symbols=ceil(baseSampleFreq*timeBase(end));
resBin=zeros(symbols,1);
resBinIndices=zeros(symbols,3);
recClock=samplingClock;

for count=1:length(waveForm)
    if(samplingClock(count)==1)
        sampling=true;
        iterations=iterations+1;
        aveV=waveForm(count)+aveV;
    elseif (sampling)
        aveV=aveV/iterations;
        iterations;
        resBin(index)=aveV>threshold;
        aveV=0;
        iterations=0;
        sampling=false;
        index=index+1;
    end
end

resBin=resBin(1:index-1);
mean(resBin);
end

