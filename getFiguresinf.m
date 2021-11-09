clear all;
frequency=2000;
addpath '..\..\data'
linkLength=300;
waveLength=520e-9;
masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;

filename = '20200915_Transmit_1249_200K.bin';   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
filenameWeather = '20200731_Weather_1000_24h.mat';   %as appropriate
loadWeather = load(filenameWeather);
dataW=loadWeather.weatherData;
startTime=datetime(dataW(2,1),'InputFormat',infmt)

totalHours=1/12;
totalHours=24
hoursToRead=0;
minutesToRead=5;
timeToRead=hoursToRead+minutesToRead/60;
readAmount=3600*timeToRead;
dataTypeOffset=4;
hours(timeToRead)
clc
train=false;
datestr(startTime,30)
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
thresh=0;
packetCounts=zeros(loopCount,2);
errSeq=[];
BERS=[];
BERSh=[];
        trans = [0.7,0,0.3;
        0, 0.5,0.5;
        0.1,0.2,0.7];
        emis=[1,0;1,0;0 1;]
        symbols=[0,1];
        p=[0.5 0.4 0.1];
        stateNames=["Good State" "Good State" "Error State"];

%     trans = [0.8,0,0.2;
%        0, 0.7,0.3;
%       0.1,0.2,0.7]
%   emis=[1,0;1,0;0 1;]
% symbols=[0,1];
% p=[0.3 0.3 0.4]
%     
%stateNames=["Good_0" "Good_1" "Error State"];
tol=1e-16;
maxIter=50;
    emis_hat = [zeros(1,size(emis,2)); emis];
    trans_hat = [0 p; zeros(size(trans,1),1) trans];
testChoice=1;

% 
%     pres=str2double(weather(:,9)).';
%     pres(find(isnan(pres)))=[];
%     meanPres=mean(pres);
% 
%     hum=str2double(weather(:,8)).';
%     hum(find(isnan(hum)))=[];
%     meanHum=mean(hum);
%     

% 
% 
%     meanWeatherDot="_"+num2str(meanTemp)+"_"+num2str(meanPres)+"_"+num2str(meanHum)+"_"+num2str(meanWD)+"_"+num2str(meanWS);
%    meanWeather=strrep(meanWeatherDot,'.','p');
    data = fread(fid, inf, '*float32');
%     if(count~=testChoice)
%         continue
%     end
% weather=dataW(timeToRead*3600*(count-1)+2:timeToRead*3600*(count-1)+readAmount,:);
%      temp=str2double(weather(:,4)).';
%      temp(find(isnan(temp)))=[];
%      meanTemp=mean(temp)
%      wd=str2double(weather(:,3)).';
%      wd(find(isnan(wd)))=[];
%      meanWD=mean(wd);
%     
%      ws=str2double(weather(:,2)).';
%      ws(find(isnan(ws)))=[];
%      meanWS=mean(ws);
%       loopTime=startTime+hours(timeToRead)*(count-1);
%           perp=abs(sind(wd));
%     perpWS=ws(1:length(wd)).*perp;
% 
%           corrTimeDec=(sqrt(waveLength*linkLength));
%     corrTimeEg=corrTimeDec/5;
%     corrTime=corrTimeDec./perpWS;
    
    [resBin,thresh,bitPos,iters]=clockRecoveryFrame(data,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,thresh);
    resBin=resBin.';
    autoCorrThresh=goldAutoCorr-2;
    firstHeaderIndex=headerIndex(gold,resBin, autoCorrThresh,goldAutoCorr);
    headersData=headerIndices(gold,resBin, autoCorrThresh,goldAutoCorr);
        headersCleaned=cleanHeaders(headersData,goldLength);


    [BERSnf,avgBERnf,errSeqnf]=BER_packets_HRSync(firstHeaderIndex(1),resBin.',packetStream);
    [BERS,avgBER,errSeq]=BER_packets_HRSyncNF(headersCleaned,resBin.',packetStream);

    firstHeader=[bitPos(firstHeaderIndex(1)-1)+1 bitPos(firstHeaderIndex(1)+goldLength-1)];

    threshH= mean(data(firstHeader(1):firstHeader(2)));
    [resBinH,threshH,bitPosH,itersH]=clockRecoveryFrame(data,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,threshH);
    resBinH=resBinH.';
    firstHeaderIndexH=headerIndex(gold,resBinH,  goldAutoCorr-2,goldAutoCorr);
    headersDataH=headerIndices(gold,resBinH, autoCorrThresh,goldAutoCorr);
    headersCleanedH=cleanHeaders(headersDataH,goldLength);
    [BERSnfH,avgBERnfH,errSeqnfH]=BER_packets_HRSync(firstHeaderIndexH(1),resBinH.',packetStream);
        [BERSH,avgBERH,errSeqH]=BER_packets_HRSyncNF(headersCleanedH,resBinH.',packetStream);


    [gapDistribution, EFR, gapsCumul,unscaledGaps] = runLengthDisitrbution(errSeqnf);
        [gapDistributionH, EFRH, gapsCumulH,unscaledGapsH] = runLengthDisitrbution(errSeqH);
    [estTR,estE] = hmmtrain(errSeqnf.',trans_hat,emis_hat,'Symbols',symbols,'Verbose',true,'Tolerance',tol,'maxIterations',maxIter);
    [estTRH,estEH] = hmmtrain(errSeqH.',trans_hat,emis_hat,'Symbols',symbols,'Verbose',true,'Tolerance',tol,'maxIterations',maxIter);


     [errSeqnfF,~]=hmmgenerate(length(errSeqnf),estTR,estE,'Symbols',symbols);
     [errSeqHF,~]=hmmgenerate(length(errSeqH),estTRH,estEH,'Symbols',symbols);
     [~, EFRF, ~,~] = runLengthDisitrbution(errSeqnfF.');
    [~, EFRHF, ~,~] = runLengthDisitrbution(errSeqHF.');
         SIthreshH=threshH*0.5;
     tailoredH=data(data>SIthreshH);
     EtH=expectedValue(tailoredH);
%          estTR(1,:)=[];
%          estTR(:,1)=[];
%  estE(1,:)=[];
%          estTRH(1,:)=[];
%          estTRH(:,1)=[];
%          estEH(1,:)=[];
    h = figure;
    set(h, 'Visible', 'off');
    subplot(2,1,1)
    semilogx(EFR,'-*')
    hold on
    semilogx(EFRF,'-+')
    hold off
    title("EFR distribution")
    xlabel("length of interval m")
    ylabel('Pr(0^{m}|1)')
    legend('Observed EFR' ,'4 state Fritchman model');
%     mc=dtmc(estTR,'StateNames',stateNames);
%         subplot(2,1,2)
% 
%     graphplot(mc,'ColorEdges',true,'LabelEdges',true);
 %   saveas(h,datestr(loopTime,30),'fig')
 %   saveas(h,datestr(loopTime,30),'png')

% 
%     set(h, 'Visible', 'off');
%             subplot(2,1,1)
% 
%     semilogx(EFRH,'-*')
%     hold on
%     semilogx(EFRHF,'-+')
%     hold off
%     title("EFR(H) distribution at "+datestr(loopTime))
%     xlabel("length of interval m")
%     ylabel('Pr(0^{m}|1)')
%         legend('Observed EFR' ,'3 state Fritchman model');
%     mcH=dtmc(estTRH,'StateNames',stateNames);
%             subplot(2,1,2)
% 
%     graphplot(mcH,'ColorEdges',true,'LabelEdges',true);
   % saveas(h,"H"+datestr(loopTime,30),'fig')
   % saveas(h,"H"+datestr(loopTime,30),'png')
    
           nBins=500;

    SIthresh=0.005;

    tailored=data(data>SIthresh);
        Et=expectedValue(tailored);
     SIthreshH=threshH*0.05;
     tailoredH=data(data>SIthreshH);
     EtH=expectedValue(tailoredH);
    hist=histogram(tailored./Et,nBins,'Normalization','pdf','DisplayStyle','stairs');
    x=hist.BinEdges;
    y=hist.Values;
    w=hist.BinWidth;
    xAdj=x(1:end-1)+w;
            histH=histogram(tailoredH./EtH,nBins,'Normalization','pdf','DisplayStyle','stairs');

    xH=histH.BinEdges;
    yH=histH.Values;
    wH=histH.BinWidth;
    xHAdj=xH(1:end-1)+wH;
   save("data.mat","x","y","w","xAdj","xH","yH","wH","xHAdj","tailored","tailoredH","errSeq","errSeqnf","errSeqH","errSeqnfH","errSeqnfH","errSeqH","estTR","estTRH","estE","estEH")
  %  save(datestr(loopTime,30),"resBin","thresh","errSeqnf","BERSnf","gapDistribution", "EFR", "gapsCumul","unscaledGaps","packetStream","weather","estTR","estE")
