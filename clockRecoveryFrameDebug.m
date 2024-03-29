function [resBin,threshold] = clockRecoveryFrameDebug(waveForm,baseFreq,Fs,perf, useFrames, frameSize, useBaseThresh,debugBit,leeway,sampleCheck)
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
iters=[];

state=1;
threshold=mean(waveForm);

timeStep=abs(timeBase(4)-timeBase(3));
bitLength=halfPeriod/timeStep;
checking=false;
for count=1:length(samplingClock)
    if(count==sampleCheck)
        count
        checking=true;
    end
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
    if(checking)
        waveForm(count)
        transition
        threshold;
    end
end
%plot(timeBase,samplingClock-trueSquare);

     aveV=0;
     iterations=0;
  sampling=false;
  index=1;
if(perf)  
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
sampleCount=round(halfPeriod/timeStep);
symbols=ceil(baseSampleFreq*timeBase(end));
resBin=zeros(symbols,1);
if(useBaseThresh)
    threshold=1;
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
elseif(useFrames)
    frames=reshape(waveForm,floor(sampleCount*2*frameSize),[]).';
            thresholds=zeros(size(frames,1),1);

    for fIndex=1:size(frames,1)
        frame=frames(fIndex,:);
        threshold=mean(frame);
        thresholds(fIndex)=threshold;
        for count=1:length(frame)
            if(samplingClock(count)==1)
                sampling=true;
                iterations=iterations+1;
                aveV=frame(count)+aveV;
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
    end
else
    checking=false;
   threshold=mean(waveForm);
    for count=1:length(waveForm)
        if(index==(debugBit))
        samplingClock(count);
            index;
            checking=true;
        end
        if(samplingClock(count)==1)
            if(checking)
                index;
            end
            sampling=true;
            iterations=iterations+1;
            aveV=waveForm(count)+aveV;
        elseif (sampling)
            aveV=aveV/iterations;
            iterations;
                        iters(end+1)=iterations;

            resBin(index)=aveV>threshold;
            aveV=0;
            iterations=0;
            sampling=false;
            index=index+1;
        end
    end

end
mean(iters)
max(iters)

end

