clear all;
frequency=2000;
addpath '..\..\data'

masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;

filename = '20200731_Transmit_1000_200Khz_2Khz_100K.bin';   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
filenameWeather = '20200731_Weather_1000_24h.mat';   %as appropriate
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
weather=dataW(2:end,:);
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
corrTimeDec=(sqrt(waveLength*linkLength));
corrTimeEg=corrTimeDec/5;
corrTime=corrTimeDec./perpWS;
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
timeNum=datetime(timeStr,'InputFormat',infmt);
time=str2double(timeStr).';
temp=str2double(weather(1:end,4)).';
for count=1:loopCount
        data = fread(fid, readAmount*sampleRate, '*float32');
    count
     SIthresh=thresh*0.1;

   % loopWeather=dataW(readAmount*(count-1)+2:readAmount*(count)+1,:);
         %[SI,logVar,meanWave]=ScintIndex1(data,respons, SIthresh);
          SIthresh=0.025;

     [SI,~,~]=ScintIndex1(data,respons, SIthresh);
%          dataDown=downsample(data,20);
%                   dataDec=decimate(double(data),20);
% 
%                   [SId,logVard,meanWaved]=ScintIndex1(dataDec,respons, SIthresh);
% 
%          [SIdo,logVardd,meanWavedo]=ScintIndex1(dataDown,respons, SIthresh);

     %SI=ScintIndex(loopWeather,520e-9);
     count;
    SIs(count,1)=SI;
     SIs(count,2)=count;
%     SIds(count,1)=SId;
%     SIds(count,2)=count;    
%     SIdos(count,1)=SI;
%     SIdos(count,2)=SIdo;                 
end
    save("SIsOs"+datestr(startTime,30),"SIs","totalHours","timeToRead",'-v7.3');
