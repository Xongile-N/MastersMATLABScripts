clear all;
clc
frequency=2000;
addpath '..\..\data'

masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;

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
packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,gold,payloadSize);
useFrames=false;
useBaseThresh=true;
usePerfSquare=false;
thresh=0.1;
packetCounts=zeros(loopCount,2);
for count=1:loopCount

    count

    data = fread(fid, readAmount*sampleRate, '*float32');

    [resBin,thresh,bitPos,iters,bitSamples]=clockRecoveryFrame(data,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,thresh);
     resBin=resBin.';
     autoCorrThresh=goldAutoCorr-2;
     firstHeaderIndex=headerIndex(gold,resBin, autoCorrThresh,goldAutoCorr);
     if(firstHeaderIndex(2)<autoCorrThresh)
            SIs(count,:)=NaN;
            SIHs(count,:)=NaN;
            BERS(count)=NaN;
            BERSh(count)=NaN;
         continue;
     end
     [BERSnf,avgBERnf,errSeqnf]=BER_packets_HRSync(firstHeaderIndex(1),resBin.',packetStream);

     SIthresh=thresh*0.1;
     [SI,logVar,meanWave]=ScintIndex1(data,respons, SIthresh);

     firstHeader=[bitPos(firstHeaderIndex(1)-1)+1 bitPos(firstHeaderIndex(1)+goldLength-1)];
    threshH= mean(data(firstHeader(1):firstHeader(2)));
    [resBinH,threshH,bitPosH,itersH,bitSamples]=clockRecoveryFrame(data,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,threshH);
    resBinH=resBinH.';
    firstHeaderIndexH=headerIndex(gold,resBinH,  goldAutoCorr-2,goldAutoCorr);
    [BERSnfH,avgBERnfH,errSeqnfH]=BER_packets_HRSync(firstHeaderIndexH(1),resBinH.',packetStream);
       
     SIthreshH=threshH*0.1;
     [SIh,logVarh,meanWaveh]=ScintIndex1(data,respons, threshH);

     BERS(count)=avgBERnf;
BERSh(count)=avgBERnfH;
     count;

    SIs(count,1)=SI;
    SIs(count,2)=logVar;
    SIs(count,3)=meanWave;
        SIs(count,4)=count;

    SIHs(count,1)=SIh;
    SIHs(count,2)=logVarh;
    SIHs(count,3)=meanWaveh;
            SIHs(count,4)=count;
                        resBins(count)=mat2cell(resBin,1);
                        resBinsH(count)=mat2cell(resBinH,1);
                        errSeqs(count)=mat2cell(errSeqnf.',1);
                        errSeqsH(count)=mat2cell(errSeqnfH.',1);

end
    save("ESIs"+datestr(startTime,30),"errSeqs","errSeqsH","SIs","SIHs","BERS","BERSh","totalHours","timeToRead","resBins","resBinsH",'-v7.3');
