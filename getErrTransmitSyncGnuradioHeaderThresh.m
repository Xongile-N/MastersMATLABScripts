masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;
addpath '..\..\data'

filename = '20200730_Transmit_1000_200Khz_2Khz_100K.bin';   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end
hoursToRead=0;
minutesToRead=15;
timeToRead=hoursToRead+minutesToRead/60;
readAmount=3600*timeToRead;

dataTypeOffset=4;
hoursOffset=5;
minutesOffSet=45;
timeOffset=hoursOffset+minutesOffSet/60;
readPos=3600*timeOffset+1;

fseek(fid,readPos*sampleRate*dataTypeOffset,"bof");
data = fread(fid, readAmount*sampleRate, '*float32');
fclose(fid);
filenameWeather = '20200728_Weather_1843_15h.mat';   %as appropriate

loadWeather = load(filenameWeather);
dataW=loadWeather.weatherData;
weather=dataW(readPos:readPos+readAmount,:);
valuesSim=data;

frequency=2000;
start=0*sampleRate+1;
plotLower=100000000;
plotUpper=plotLower+10000000;
%pos=find(valuesSim>upper);
%valuesSim(pos)=upper;

clc
train=false;
frameCount=100-train;%
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
[resBin,thresh,bitPos,iters]=clockRecoveryFrame(valuesSim,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,thresh);
resBin=resBin.';
%headers=headerIndices(gold,resBin,  goldAutoCorr-2,goldAutoCorr);
firstHeaderIndex=headerIndex(gold,resBin,  goldAutoCorr-2,goldAutoCorr);
%headersCleaned=cleanHeaders(headers,goldLength);
%headersCleaned=headersCleaned(:,1);

[BERSnf,avgBERnf,errSeqnf]=BER_packets_HRSync(firstHeaderIndex(1),resBin.',packetStream);
    firstHeader=[bitPos(firstHeaderIndex(1)-1)+1 bitPos(firstHeaderIndex(1)+goldLength-1)];

useFrames=false;
useBaseThresh=true;
threshH= mean(data(firstHeader(1):firstHeader(2)));
[resBinH,threshH,bitPosH,itersH]=clockRecoveryFrame(data,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,threshH);
resBinH=resBinH.';
firstHeaderIndexH=headerIndex(gold,resBinH,  goldAutoCorr-2,goldAutoCorr);

[BERSnfH,avgBERnfH,errSeqnfH]=BER_packets_HRSync(firstHeaderIndexH(1),resBinH.',packetStream);% firstHeader=[bitPos(headersCleaned(1)-1)+1 bitPos(headersCleaned(1)+goldLength-1)]
