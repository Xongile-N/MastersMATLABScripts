clear all;
clc
addpath '..\..\data'

weatherFiles=["20200729_Weather_1000_24h.mat";"20200731_Weather_1000_24h.mat";"20200801_Weather_1200_24h.mat"];
choice=2;
testChoice= 1;
rytov=0.41;
filenameData ="dataMod";   %as appropriate
thresh=0.05;

filenameWeather = weatherFiles(choice);   %as appropriate
loadWeather = load(filenameWeather);
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
transmitFreq=2e3;
samplingFreq=8e3;
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
load(filenameData);
trim=false;


            [turbulence,SI_LN]=gammaTurb(rytov,length(waveFormRX),limit);
            waveFormRX=waveFormRX.*turbulence;


  %   BER=BERS(dataIndex);

   %  estTR=cell2mat(models(dataIndex,1));
    % estE=cell2mat(models(dataIndex,2));
    %     estTRH=cell2mat(modelsH(dataIndex,1));
    % estEH=cell2mat(modelsH(dataIndex,2));
     
  ET=expectedValue(turbulence);
  [SI_T,~,~]=ScintIndex1(turbulence,1, 0);
 waveFormRXA=waveFormRX;
 [resBin,thresh,bitPos,iters,bitSamples]=clockRecoveryFrameSI(waveFormRXA,transmitFreq,samplingFreq,usePerfSquare,useFrames,frameLength,useBaseThresh,thresh);
 [BERS,avgBER,errSeqSim]=BER_packets_HRSync(1,resBin,packetStream);
nBins=100;
%h=histogram(waveFormRXA,nBins,'Normalization','pdf','DisplayStyle','stairs');
    [gapDistribution, EFR, gapsCumul,unscaledGaps] = runLengthDisitrbution(errSeqSim);
%    errSeqnf=cell2mat(errSeqs(dataIndex));
%    errSeqnfH=cell2mat(errSeqsH(dataIndex));   
    
    
    %[errSeqnfF,~]=hmmgenerate(length(errSeqnf),estTR,estE,'Symbols',symbols);
    [errSeqHF,~]=hmmgenerate(length(errSeqH),estTRH,estEH,'Symbols',symbols);
   % [~, EFRFF, ~,~] = runLengthDisitrbution(errSeqnfF.');
    [~, EFRHFF, ~,~] = runLengthDisitrbution(errSeqHF.');
    
  %  [~, EFRF, ~,~] = runLengthDisitrbution(errSeqnf.');
    [~, EFRFH, ~,~] = runLengthDisitrbution(errSeqH);
    avgBERO=mean(errSeqH)
    avgBEROF=mean(errSeqHF)

    f=figure;
    semilogx(EFR)
    hold on
    %semilogx(EFRF,'-*')
    semilogx(EFRFH,'k')
    %semilogx(EFRFF,'-*')
    semilogx(EFRHFF,'r')
    hold off


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
    %title("EFR distribution")

    ylabel('Pr(0^{m}|1)')
xlabel("length of interval (m)")
 legend("Gamma Gamma Rytov:"+rytov+" BER:"+avgBER,"Observed Sequence BER:"+avgBERO,"Three State Fritchman BER:"+avgBEROF);
 f=figure;
    plot(xHAdj,yH)
    hold on
    dist=gammaSample(rytov,xHAdj);
    plot(xHAdj,dist,'Color','r');
    hold off
    ylabel('PDF');
legend("Observed sequence","Gamma Gamma Rytov:"+rytov);
xlabel('Intensity (Normalised to mean)');
plotStart=1;
windowLength=200;
fritchAve=movmean(errSeqHF,windowLength);
obsAve=movmean(errSeqH,windowLength);
simAve=movmean(errSeqSim(1:length(errSeqH)),windowLength);
f1=figure;
plotLength=10000;
timeBase=1:1:10000;
timeBase=timeBase./(2*transmitFreq);
plotEnd=plotStart+plotLength-1;
plot(timeBase,fritchAve(plotStart:plotEnd),'g');
hold on
plot(timeBase,obsAve(plotStart:plotEnd),'b');
plot(timeBase,simAve(plotStart:plotEnd),"k");
xlabel("Time(s)")

hold off;
%legend("Fritchman","Observed","Log Normal Simulation")
ylabel("BER")
f2=figure;
plot(timeBase,errSeqH((plotStart:plotEnd)),'b')

hold on
plot(timeBase,errSeqSim(plotStart:plotEnd)+1,'k')
plot(timeBase,errSeqHF(plotStart:plotEnd)+2,'g')
%     subplot(3,1,1)
%     plot(timeBase,errSeqH((plotStart:plotEnd)),'b')
% 
%      subplot(3,1,2)
% plot(timeBase,errSeqSim(plotStart:plotEnd),'k')
% 
%      subplot(3,1,3)
% 
% plot(timeBase,errSeqHF((plotStart:plotEnd)),'g')
hold off
xlabel("Time(s)")
    %title("Irradiance Index: ")
    
