clear all;
clc
frequency=2000;
addpath '..\..\data'
waveLength=520e-9;
k=2*pi/waveLength;
L=300;
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
SIHs=zeros(loopCount,2);
SI_Ts=zeros(loopCount,2);
SIH_Ts=zeros(loopCount,2);
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
onePos=find(packetStream)-1;
checkInd=71;
for count=1:loopCount

    count
    
    data = fread(fid, readAmount*sampleRate, '*float32');
    if(count~=checkInd)
        continue
    end
          SIthresh=0.05;

     [SI,~,~]=ScintIndex1(data,respons, SIthresh);
       nBins=500;
    GG=@(r,x) gammaSample(r,x);
    Ln=@(r,x) LNSample(r,x);
    tailored=data(data>SIthresh);
    Et=expectedValue(tailored);
              [SI_T,~,~]=ScintIndex1(tailored,respons, 0);
    h=histogram(tailored,nBins,'Normalization','pdf','DisplayStyle','stairs');

    h=histogram(tailored./Et,nBins,'Normalization','pdf','DisplayStyle','stairs');
    x=h.BinEdges;
    y=h.Values;
    w=h.BinWidth;
    xAdj=x(1:end-1)+w;
    plot(xAdj,y)
    mdlLn=fitnlm(xAdj,y,Ln,SI_T);

    %mdlGG=fitnlm(xAdj,y,GG,SI_T);
    hold on

    line(xAdj.',predict(mdlLn,xAdj.'),'Color','r');
    %line(xAdj.',predict(mdlGG,xAdj.'),'Color','g');
    hold off
    ylabel('PDF');
    %h1=histogram(turbVec,nBins,'Normalization','pdf','DisplayStyle','stairs');
    rytov=mdlLn.Coefficients.Estimate
    %rytovGG=mdlGG.Coefficients.Estimate
    SILn=(exp(rytov)-1)

    legend("Observed sequence SI="+SI_T,"Log Normal Turbulence Rytov="+rytov);
    xlabel('Intensity (Normalised to mean)');
    CN_2=mdlLn.Coefficients.Estimate/1.23/(k^(7/6)*L^(11/6))
%     [resBinH,threshH,bitPosH,itersH,bitSamplesH]=clockRecoveryFrameSI(data,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,threshH);
%     resBinH=resBinH.';
%     firstHeaderIndexH=headerIndex(gold,resBinH,  goldAutoCorr-2,goldAutoCorr);
%      
%          tailoredH=getOnes(bitSamplesH,onePos,length(packetStream),firstHeaderIndexH(1));
% % 
% 
% 
%      SIthreshH=threshH*0.1;
%      [SIh,~,~]=ScintIndex1(data,respons, threshH);
%      [SIh_T,~,~]=ScintIndex1(tailoredH,respons, SIthreshH);
%      [BERSnf,avgBERnf,errSeqnf]=BER_packets_HRSync(firstHeaderIndex(1),resBin.',packetStream);
%     [BERSnfH,avgBERnfH,errSeqnfH]=BER_packets_HRSync(firstHeaderIndexH(1),resBinH.',packetStream);
% 
%      BERS(count)=avgBERnf;
% BERSh(count)=avgBERnfH;
%      count;
% 
%     SIs(count,1)=SI;
%     SIs(count,2)=count;
% 
%     SIHs(count,1)=SIh;
%     SIHs(count,2)=count;
%     SI_Ts(count,1)=SI_T;
%     SI_Ts(count,2)=count;
% 
%     SIH_Ts(count,1)=SIh_T;
%     SIH_Ts(count,2)=count;
%                         resBins(count)=mat2cell(resBin,1);
%                         resBinsH(count)=mat2cell(resBinH,1);
%                         errSeqs(count)=mat2cell(errSeqnf.',1);
%                         errSeqsH(count)=mat2cell(errSeqnfH.',1);
    if(count==checkInd)
        break
    end

end
    save("TESI_Ts"+datestr(startTime,30),"errSeqs","errSeqsH","SIs","SIH_Ts","SI_Ts","SIHs","BERS","BERSh","totalHours","timeToRead","resBins","resBinsH",'-v7.3');
