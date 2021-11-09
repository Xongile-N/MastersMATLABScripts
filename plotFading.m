clear all;
clc
frequency=2000;
addpath '..\..\data'

masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;

filename = '20200729_Transmit_1000_200Khz_2Khz_100K.bin';   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
filenameWeather = '20200729_Weather_1000_24h.mat';   %as appropriate
loadWeather = load(filenameWeather);
dataW=loadWeather.weatherData;
startTime=datetime(dataW(2,1),'InputFormat',infmt)

totalHours=24;
hoursToRead=0;
minutesToRead=5;
timeToRead=hoursToRead+minutesToRead/60;
readAmount=3600*timeToRead;
  respons=0.3;
loopCount=totalHours/timeToRead
SIs=zeros(loopCount,4);
SIHs=zeros(loopCount,4);
resBins=cell(loopCount,1);
resBinsH=cell(loopCount,1);
errSeqs=cell(loopCount,1);
errSeqsH=cell(loopCount,1);
BERS=zeros(loopCount,1);
BERSh=zeros(loopCount,1);

means=zeros(loopCount,2);
frameCount=100;%
payloadSize=1000;
gold=[1,1,0,1,0,1,0,0,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1,1,0,0,1,0,1,0,0];
goldAutoCorr=31;
goldLength=length(gold);
frameLength=payloadSize;
bitCount=frameCount*payloadSize+goldLength;
LFSRSeed=10000;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=53256;%[1 0 1 1 1 0 0 0 ];
%packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,gold,payloadSize);
useFrames=false;
useBaseThresh=true;
usePerfSquare=false;
thresh=0.1;
packetCounts=zeros(loopCount,2);
choice=38;
for count=1:loopCount

        count
    data = fread(fid, readAmount*sampleRate, '*float32');
    if(count==choice)
        f=figure;
     SIthresh=thresh*0.1;
     [SI,logVar,meanWave]=ScintIndex2(data,respons, SIthresh,5);
     nBins=100;
    dataT=data(find(data>SIthresh));
    dataT=smooth(dataT,20);
E=expectedValue(dataT);
    dist=histogram(data./E,nBins,'Normalization','pdf');

     [I,distG]=gammaDist(SI,nBins);
     hold on
    plot(I,distG);
    hold off
    dist;
    end
end
