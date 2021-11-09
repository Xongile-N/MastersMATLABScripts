clear all;
frequency=2000;

masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;

filename = '20200731_Transmit_1200_200Khz_2Khz_100K.bin';   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end

% filenameWeather = '20200728_Weather_1843_15h.mat';   %as appropriate
% loadWeather = load(filenameWeather);
% dataW=loadWeather.weatherData;

totalHours=22;
hoursToRead=0;
minutesToRead=15;
timeToRead=hoursToRead+minutesToRead/60;
readAmount=3600*timeToRead;
dataTypeOffset=4;

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
loopCount=totalHours/timeToRead
useFrames=false;
useBaseThresh=true;
usePerfSquare=false;
thresh=0.1;
packetCounts=zeros(loopCount,2);
errSeq=[];
BERS=[];
errSeqh=[];
BERSh=[];
for count=1:loopCount
    
    count
    data = fread(fid, readAmount*sampleRate, '*float32');
    %weather=dataW(timeToRead*(count-1)+1:timeToRead*(count-1)+readAmount,:);
   
    if(count==14)
    count
    end
    [resBin,thresh,bitPos,iters]=clockRecoveryFrame(data,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,thresh);
    resBin=resBin.';
    autoCorrThresh=goldAutoCorr-2;
    firstHeaderIndex=headerIndex(gold,resBin,  autoCorrThresh,goldAutoCorr);
    if(firstHeaderIndex(2)<autoCorrThresh)
        continue;
    end
    [BERSnf,avgBERnf,errSeqnf]=BER_packets_HRSync(firstHeaderIndex(1),resBin.',packetStream);

    firstHeader=[bitPos(firstHeaderIndex(1)-1)+1 bitPos(firstHeaderIndex(1)+goldLength-1)];

    threshH= mean(data(firstHeader(1):firstHeader(2)));
    [resBinH,threshH,bitPosH,itersH]=clockRecoveryFrame(data,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,threshH);
    resBinH=resBinH.';
    firstHeaderIndexH=headerIndex(gold,resBinH,  goldAutoCorr-2,goldAutoCorr);
    [BERSnfH,avgBERnfH,errSeqnfH]=BER_packets_HRSync(firstHeaderIndexH(1),resBinH.',packetStream);
 
    BERS=[BERS BERSnf];
    errSeq=[errSeq; errSeqnf];
    packetCounts(count,1)=length(BERSnf); 
    BERSh=[BERSh BERSnfH];
    errSeqh=[errSeqh; errSeqnfH];
    packetCounts(count,2)=length(BERSnfH);
    [max(iters) max(itersH)];
end
fclose(fid);
mean(BERS)
mean(BERSnfH)








