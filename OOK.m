function waveForm = OOK(bitStream,frequency, samplingFreq)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
bitRate=2*frequency;
transmitTime=length(bitStream)/bitRate;
timeSampleCount=samplingFreq*transmitTime;
timeBase=(0:timeSampleCount-1)*(1/samplingFreq);
basePeriod=1/frequency;
halfPeriod=basePeriod/2;
waveForm = zeros(size(timeBase));
timeStep=abs(timeBase(3)-timeBase(4));
index=1;
timeElapsed=0;
for count=1:length(timeBase)

if(timeElapsed>=halfPeriod)

    timeElapsed=timeElapsed-halfPeriod;
    index=index+1;
end
        waveForm(count)=bitStream(index);

timeElapsed=timeElapsed+timeStep;

end

