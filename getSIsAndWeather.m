clear all;
frequency=2000;
addpath '..\..\data'

masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;
laserDir=360*15/16;
linkLength=150;
waveLength=520e-9;
filename = '20200801_Transmit_1200_200Khz_2Khz_100K.bin';   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
filenameWeather = '20200801_Weather_1200_24h.mat';   %as appropriate
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
SIs=zeros(loopCount,2);
SIdo=SIs;
SIdos=SIs;
SIHs=zeros(loopCount,2);
resBins=cell(loopCount,1);
resBinsH=cell(loopCount,1);

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
packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,gold,payloadSize);


useFrames=false;
useBaseThresh=true;
usePerfSquare=false;
thresh=0.1;
packetCounts=zeros(loopCount,2);
dataW=loadWeather.weatherData;
totalWeather=dataW(2:end,:);

%corrTimeDec=(sqrt(waveLength*linkLength));
%corrTimeEg=corrTimeDec/5;
%corrTime=corrTimeDec./perpWS;


tempAdj=zeros(1,loopCount);
perpWSAdj=tempAdj;
timeBaseAdj=NaT(1,loopCount);
for count=1:loopCount
    data = fread(fid, readAmount*sampleRate, '*float32');
    weather=totalWeather(timeToRead*3600*(count-1)+1:timeToRead*3600*(count-1)+readAmount,:);
    timeStr=weather(1:end,1);
    WSStr=weather(1:end,2);
    WDStr=weather(1:end,3);
    WDNum=str2double(WDStr);
    WSNum=str2double(WSStr);
    for iCount=2:length(WDNum)
    if(isnan(WDNum(iCount)))
    WDNum(iCount)=WDNum(iCount-1);
    end
    if(isnan(WSNum(iCount)))
    WSNum(iCount)=WSNum(iCount-1);
    end
    end
    WDNumAdj=abs(WDNum-laserDir);
    perp=abs(sind(WDNumAdj));
    pos=find(WSNum==0);
    posAdj=pos-1;
    WSNum(pos)=WSNum(posAdj);
    perpWS=WSNum.*perp;
    infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
    timeNum=datetime(timeStr,'InputFormat',infmt);
    time=str2double(timeStr).';
    temp=str2double(weather(1:end,4)).';
    count
%      SIthresh=thresh*0.1;
% 
% 
%           SIthresh=0.025;
% 
%      [SI,~,~]=ScintIndex1(data,respons, SIthresh);
%      count;
%     SIs(count,1)=SI;
%      SIs(count,2)=count;
%      timeBaseAdj(count)=timeNum(1);
%      tempAdj(count)=mean(temp);
%         perpWSAdj(count)=mean(perpWS);
%     SIds(count,1)=SId;
%     SIds(count,2)=count;    
%     SIdos(count,1)=SI;
%     SIdos(count,2)=SIdo;                 
end
timeBaseAdj=timeBaseAdj+hours(2);
plot(timeBaseAdj,SIs(:,1));
tickGap=4;
for count=1:totalHours/4
xtickArray(count)=timeBaseAdj((count-1)*tickGap/timeToRead+1);
end
    save("weather"+datestr(startTime,30),"xtickArray","tempAdj","perpWSAdj","timeBaseAdj","SIs","totalHours","timeToRead",'-v7.3');
