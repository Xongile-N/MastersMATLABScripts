function [resBin,firstClock,secondClock,thirdClock,iterCountSecond, iterCountThird] = clockRecoveryFrameSI(waveForm,baseFreq,Fs,perf,  useBaseThresh, thresh)
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
firstClock=samplingClock;
secondClock=samplingClock;
thirdClock=samplingClock;
iterCountSecond=zeros(2,length(timeBase));
iterCountThird=zeros(2,length(timeBase));
iterCounter=1;
state=1;
threshold=mean(waveForm);
if(useBaseThresh)
    threshold=thresh;
end
timeStep=abs(timeBase(4)-timeBase(3));
clockThresh=threshold;
symbols=0;
     minGrad=(clockThresh/(timeStep*2));minGrad=15000;
     
state=1;
timeElapsed=0;
    for count=1:length(samplingClock)
        if(timeElapsed>=halfPeriod)
            timeElapsed=timeElapsed-halfPeriod;
            state=mod(state+1,2);
        end
            firstClock(count)=state;
            timeElapsed=timeElapsed+timeStep;

    end
 
    state=1;
    timeElapsed=0;
    iterations=1;
for count=1:length(samplingClock)
    transition=bitxor(waveForm(count)>clockThresh,high);
    if(transition)
        high=~high;
        timeElapsed=0;
        if(state==0)
            iterCountSecond(1,iterCounter)=iterations;
            iterCountSecond(2,iterCounter)=count;
            iterCounter=iterCounter+1;
            iterations=0;
        end
        state=1;
    elseif(timeElapsed>=halfPeriod)
        timeElapsed=timeElapsed-halfPeriod;
        state=mod(state+1,2);
                symbols=symbols+1;
                iterCountSecond(1,iterCounter)=iterations;
                iterCountSecond(2,iterCounter)=count;
iterCounter=iterCounter+1;

        iterations=0;
    end
    iterations=iterations+1;
    secondClock(count)=state;
    timeElapsed=timeElapsed+timeStep;
end
    iterations=1;
iterCounter=1;
clockThresh=0.01;

for count=1:length(samplingClock)
    transition=bitxor(waveForm(count)>clockThresh,high);
    if(transition&&count>1&&count<length(samplingClock))
     grad=abs(waveForm(count-1)-waveForm(count+1))/timeStep;
     transition=transition&grad>minGrad;
    end
    if(transition)
        high=~high;
        if(state==0)
            iterCountThird(1,iterCounter)=iterations;
            iterCountThird(2,iterCounter)=count;
            iterCounter=iterCounter+1;
            iterations=0;
        end
        timeElapsed=0;
        state=1;

    elseif(timeElapsed>=halfPeriod)
        timeElapsed=timeElapsed-halfPeriod;
        state=mod(state+1,2);
                symbols=symbols+1;
                iterCountThird(1,iterCounter)=iterations;
                iterCountThird(2,iterCounter)=count;
                iterCounter=iterCounter+1;

        iterations=0;

    end
        iterations=iterations+1;

    thirdClock(count)=state;
    timeElapsed=timeElapsed+timeStep;
end
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
                        bitPos(index)=count;
            iters(end+1)=iterations;
           if(iterations==75)
               count
           end
            aveV=0;
            iterations=0;
            sampling=false;
            index=index+1;
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
          %  if(iterations>(sampleCount+0.1*sampleCount))
           %     max(iters);
           % end

                        iters(end+1)=iterations;

            resBin(index)=aveV>threshold;
            bitPos(index)=count;
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

