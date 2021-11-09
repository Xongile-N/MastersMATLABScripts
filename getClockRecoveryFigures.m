clear all;
frequency=2000;
addpath '..\..\data'
masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;

day1='20200729_Transmit_1000_200Khz_2Khz_100K.bin';
day2='20200731_Transmit_1000_200Khz_2Khz_100K.bin';
day3='20200801_Transmit_1200_200Khz_2Khz_100K.bin';
testChoice=69;
thresh=0.083;

filename =day2 ;   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end
totalHours=24;
hoursToRead=0;
minutesToRead=5;
timeToRead=hoursToRead+minutesToRead/60;
readAmount=3600*timeToRead;
loopCount=totalHours/timeToRead
useFrames=false;
useBaseThresh=true;
usePerfSquare=false;

for count=1:loopCount
    count
    data = fread(fid, readAmount*sampleRate, '*float32');
    if(count~=testChoice)
        continue
    end
    [resBin,firstClock,secondClock,thirdClock,iterCountSecond, iterCountThird]=clockRecoveryFrameFigures(data,frequency,sampleRate,usePerfSquare,useBaseThresh,thresh);
    
    dataRangeStart=1;
    dataRangeEnd=400;
    timeBase=(1:dataRangeEnd-dataRangeStart+1)/sampleRate
    plot(timeBase,firstClock(dataRangeStart:dataRangeEnd));
    hold on;
    plot(timeBase,secondClock(dataRangeStart:dataRangeEnd)*2);
    plot(timeBase,thirdClock(dataRangeStart:dataRangeEnd)*3);
    plot(timeBase,data(dataRangeStart:dataRangeEnd)*40);
    hold off
    
    legend("First Iteration","Second Iteration","Third Iteration","Data signal")
    xlabel("Time (s)")
    if(count==testChoice)
        break;
    end
end