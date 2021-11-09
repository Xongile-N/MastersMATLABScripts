clear all;
clc
addpath '..\..\data'

choice=2;
setChoice=4;
rytovs=[0.18 0.45 0.41 0.46];
%rytovs=[0.18 0.35  0.5298];

rytov=rytovs(setChoice);
fileNames=["dataWeak" "data0" "data1" "data2"];
filenameData =fileNames(setChoice);  %as appropriate
thresh=0.05;
symbols=[0,1];
transmitFreq=2e3;
freqs=[48e3 80e3 80e3 80e3];
samplingFreq=freqs(setChoice);
transmitTime=900;
frameCount=100;%
payloadSize=1000;
gold=[1,1,0,1,0,1,0,0,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1,1,0,0,1,0,1,0,0];
goldAutoCorr=31;
goldLength=length(gold);
frameLength=payloadSize;
bitCount=frameCount*payloadSize+goldLength;

LFSRSeed=10000;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=53256;%[1 0 1 1 1 0 0 0 ];
packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,gold);
totalBits=transmitFreq*transmitTime*2;
bitStream=packetStream;
while(length(bitStream)<totalBits)
    bitStream=[bitStream; packetStream];
end
bitStream(totalBits+1:end)=[];
[waveFormTX,sampleCounts]=OOK(bitStream,transmitFreq,samplingFreq);
%axis([0 length(waveFormTX)+10 -0.5 1.5]);
%[resBin,~,~]=clockRecovery(waveFormTX,transmitFreq,samplingFreq,true,true,0.05);

 scalingFactor=1;
 waveFormRX=(waveFormTX.');
 oneStream=waveFormRX(waveFormRX>0);
E=expectedValue(oneStream);
useFrames=false;
useBaseThresh=true;
usePerfSquare=true;
thresh=0.5;
limit=2.5;

load(filenameData);
trim=false;


            [turbulence,SI_LN]=LNTurb(rytov,length(waveFormRX),limit);
            waveFormRX=waveFormRX.*turbulence;
  ET=expectedValue(turbulence);
  [SI_T,~,~]=ScintIndex1(turbulence,1, 0);
 waveFormRXA=waveFormRX;
 [resBin,thresh,bitPos,iters,bitSamples]=clockRecoveryFrameSI(waveFormRXA,transmitFreq,samplingFreq,usePerfSquare,useFrames,frameLength,useBaseThresh,thresh);
 [BERS,avgBER,errSeqSim]=BER_packets_HRSync(1,resBin,packetStream);
nBins=100;
%h=histogram(waveFormRXA,nBins,'Normalization','pdf','DisplayStyle','stairs');
    [gapDistribution, efrLN, gapsCumul,unscaledGaps] = runLengthDisitrbution(errSeqSim);
    
    [errSeqF,~]=hmmgenerate(length(errSeqSim),estTR,estE,'Symbols',symbols);
    [gapsFritchB, efrFritchB, gapsCumulFrtichB,unscaledCumulFritchB] = runLengthDisitrbution(errSeqF.');
   
    [gapsObsB, efrObsB, gapsCumulB,unscaledCumulB] = runLengthDisitrbution(errSeq);
    
avgBER
    avgBERObserved=mean(errSeq)
    avgBERFritchman=mean(errSeqF)
    f0=figure;

    
   semilogx(efrLN)
    hold on
    semilogx(efrObsB)
    semilogx(efrFritchB)
    hold off
    ylabel('Pr(0^{m}|1)')
xlabel("length of interval (m)")
 l=legend("Log Normal Rytov:"+rytov,"Observed Sequence","Three State Fritchman");
%  l.FontSize=20;
%  f=figure;
%     plot(xAdj,y)
%     hold on
%     dist=LNSample(rytov,xAdj);
%     plot(xAdj,dist);
%     hold off
%     ylabel('PDF');
% legend("Observed sequence","Log Normal Rytov:"+rytov);
% xlabel('Intensity (Normalised to mean)');
% xlabel("Time(s)")