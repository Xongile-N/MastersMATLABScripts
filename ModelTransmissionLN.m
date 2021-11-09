clear all;
clc
addpath '..\..\data'

weatherFiles=["20200729_Weather_1000_24h.mat";"20200731_Weather_1000_24h.mat";"20200801_Weather_1200_24h.mat"];
choice=2;
testChoice=69;
rytov=0.18;

filenameWeather = weatherFiles(choice);   %as appropriate
loadWeather = load(filenameWeather);
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
transmitFreq=2e3;
samplingFreq=8e4;
transmitTime=300;
frameCount=100;%
payloadSize=1000;
gold=[1,1,0,1,0,1,0,0,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1,1,0,0,1,0,1,0,0];
goldAutoCorr=31;
goldLength=length(gold);
frameLength=payloadSize;
bitCount=frameCount*payloadSize+goldLength;

fritchBase=2;
switch(fritchBase)
    case 1
        trans = [0.65,0,0.25,0.1;
        0, 0.4,0.35,0.25;
        0.2,0.3,0.5,0;           
        0.1,0.15,0,0.75];
        emis=[1,0;1,0;0 1;0 1;];
        symbols=[0,1];
        p=[0.3 0.5 0.1 0.1];
        stateNames=["Good State" "Good State" "Error State" "Deep fade State"];
    case 2      
        trans = [0.7,0,0.3;
        0, 0.5,0.5;
        0.1,0.2,0.7];
        emis=[1,0;1,0;0 1;]
        symbols=[0,1];
        p=[0.5 0.4 0.1];
        stateNames=["Good State" "Good State" "Error State"];
    case 3      
        trans = [0.65,0,0.25,0.1;
        0, 0.4,0.35,0.25;
        0.2,0.3,0.5,0;           
        0.15,0.25,0,0.6];
        emis=[1,0;1,0;0.7 0.3;0.1 0.8;];
        symbols=[0,1];
        p=[0.3 0.5 0.1 0.1];
        stateNames=["Good State" "Good State" "Error State" "Deep fade State"];
    otherwise
        trans = [0.8,0,0.2;
        0, 0.7,0.3;
        0.1,0.2,0.7];
        emis=[1,0;1,0;0 1;]
        symbols=[0,1];
        p=[0.5 0.4 0.1];
        stateNames=["Good State" "Good State" "Error State"];
end

LFSRSeed=10000;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=53256;%[1 0 1 1 1 0 0 0 ];
packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,gold,payloadSize);
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
dataW=loadWeather.weatherData;

startTime=datetime(dataW(2,1),'InputFormat',infmt)
filenameData = "EMSIs"+datestr(startTime,30);   %as appropriate
load(filenameData);
trim=false;

for dataIndex=1:length(SIs)
    dataIndex
    if(dataIndex~=testChoice)
        continue
    end


 if(trim)
       [turbulence,SI_LN]=LNTurb(rytov,length(oneStream),limit);

        waveFormRX(waveFormRX>0)=turbulence;
 else
            [turbulence,SI_LN]=LNTurb(rytov,length(waveFormRX),limit);
            waveFormRX=waveFormRX.*turbulence;

     
 end
     BER=BERS(dataIndex);

     estTR=cell2mat(models(dataIndex,1));
     estE=cell2mat(models(dataIndex,2));
         estTRH=cell2mat(modelsH(dataIndex,1));
     estEH=cell2mat(modelsH(dataIndex,2));
     
  ET=expectedValue(turbulence);
  [SI_T,~,~]=ScintIndex1(turbulence,1, -1);
 waveFormRXA=waveFormRX;
 [resBin,thresh,bitPos,iters,bitSamples]=clockRecoveryFrameSI(waveFormRXA,transmitFreq,samplingFreq,usePerfSquare,useFrames,frameLength,useBaseThresh,thresh);
 [BERS,avgBER,errSeq]=BER_packets_HRSync(1,resBin,packetStream);
nBins=100;
%h=histogram(waveFormRXA,nBins,'Normalization','pdf','DisplayStyle','stairs');
    [gapDistribution, EFR, gapsCumul,unscaledGaps] = runLengthDisitrbution(errSeq);
    errSeqnf=cell2mat(errSeqs(dataIndex));
    errSeqnfH=cell2mat(errSeqsH(dataIndex));   
    
    
    [errSeqnfF,~]=hmmgenerate(length(errSeqnf),estTR,estE,'Symbols',symbols);
    [errSeqnfHF,~]=hmmgenerate(length(errSeqnfH),estTRH,estEH,'Symbols',symbols);
    [~, EFRFF, ~,~] = runLengthDisitrbution(errSeqnfF.');
    [~, EFRHFF, ~,~] = runLengthDisitrbution(errSeqnfHF.');
    
    [~, EFRF, ~,~] = runLengthDisitrbution(errSeqnf.');
    [~, EFRFH, ~,~] = runLengthDisitrbution(errSeqnfH.');
    f=figure;
    semilogx(EFR,'-*')
    hold on
    %semilogx(EFRF,'-*')
    semilogx(EFRFH,'-*')
    %semilogx(EFRFF,'-*')
    semilogx(EFRHFF,'-*')
    hold off
    if(dataIndex==testChoice)
        break;
    end
end


% semilogy(SI,BERS, '+');
% legendStrings=cell(1+length(AWGNSnrs),1);
% legendStrings{1}=['Turbulence only'];
% hold on
%     for index=1:length(AWGNSnrs)
% 
%         semilogy(thresholdsA(index,:),BERSA(index,:), '-*');
%         legendStrings{1+index}=['Turbulence and AWGN. SNR: ', num2str(AWGNSnrs(index)), ' dB'];    
%     end
% grid
% ylabel('BER');
% xlabel('Modulation threshold');
% legend(legendStrings);
