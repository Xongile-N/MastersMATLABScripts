function [resBin,threshold,bitPos,iters,bitSamples] = clockRecoveryFrameSI(waveForm,baseFreq,Fs,perf, useFrames, frameSize, useBaseThresh, thresh)
T=1/Fs;
L=length(waveForm);
timeBase = (0:L-1)*T;  
baseSampleFreq=2*baseFreq;
%baseSampleFreq=baseFreq;
%disp('demodulation');
transition=false;
high=false;
basePeriod=1/baseSampleFreq;
halfPeriod=basePeriod/2;
timeElapsed=0;
samplingClock=zeros(1,length(timeBase));
iters=[];

state=1;
threshold=mean(waveForm);
if(useBaseThresh)
    threshold=thresh;
end
timeStep=abs(timeBase(4)-timeBase(3));
clockThresh=threshold;
symbols=0;
     minGrad=(clockThresh/(timeStep*2));minGrad=15000;
for count=1:length(samplingClock)
    transition=bitxor(waveForm(count)>clockThresh,high);
    if(transition&&count>1&&count<length(samplingClock))
     grad=abs(waveForm(count-1)-waveForm(count+1))/timeStep;
     transition=transition&grad>minGrad;
    end
    if(transition)
        high=~high;

        timeElapsed=0;
        state=1;

    elseif(timeElapsed>=halfPeriod)
        timeElapsed=timeElapsed-halfPeriod;
        state=mod(state+1,2);
                symbols=symbols+1;

    end
    samplingClock(count)=state;
    timeElapsed=timeElapsed+timeStep;
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
bitSamples=cell(symbols,1);
bitPos=resBin;
sampler=samplingClock;
if(useBaseThresh)
    threshold=thresh;
    for count=1:length(waveForm)
        if(samplingClock(count)==1)
            sampling=true;
            iterations=iterations+1;
            aveV=waveForm(count)+aveV;
        elseif (sampling)
            aveV=aveV/iterations;
            iterations;
            resBin(index)=aveV>threshold;
            bitSamples(index)=mat2cell(waveForm(count-iterations:count).',1);
            bitPos(index)=count;
            iters(end+1)=iterations;
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
                            iters(end+1)=iterations;

                resBin(index)=aveV>threshold;
            bitSamples(index)=mat2cell(waveForm(count-iterations:count).',1);
            bitPos(index)=count;

                aveV=0;
                iterations=0;
                sampling=false;
                index=index+1;
            end
        end
    end
else
   threshold=mean(waveForm);
    for count=1:length(waveForm)
        if(samplingClock(count)==1)
            sampling=true;
            iterations=iterations+1;
            aveV=waveForm(count)+aveV;
        elseif (sampling)
            aveV=aveV/iterations;
            iterations;
            bitSamples(index)=mat2cell(waveForm(count-iterations:count).',1);
            bitPos(index)=count;

                        iters(end+1)=iterations;

            resBin(index)=aveV>threshold;
            aveV=0;
            iterations=0;
            sampling=false;
            index=index+1;
        end
    end

end

resBin=resBin(1:length(iters));
disp('demodulation complete');
end

