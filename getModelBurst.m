clear all;
addpath '..\..\data'

clc
weatherFiles=["20200729_Weather_1000_24h.mat";"20200731_Weather_1000_24h.mat";"20200801_Weather_1200_24h.mat"];
choice=1;
filenameWeather = weatherFiles(choice);   %as appropriate
loadWeather = load(filenameWeather);
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
%dataIndex=64;

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
% 
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

tol=1e-8;
maxIter=40;
emis_hat = [zeros(1,size(emis,2)); emis];
trans_hat = [0 p; zeros(size(trans,1),1) trans];
    
    
dataW=loadWeather.weatherData;
startTime=datetime(dataW(2,1),'InputFormat',infmt)

filenameData = "SIs"+datestr(startTime,30);   %as appropriate
load(filenameData);
berThresh=0.1;
for dataIndex=1:length(SIs)
    dataIndex
    if(dataIndex==56)
        dataIndex
    else 
       % continue
    end
    ind=ceil((dataIndex)*timeToRead*3600);
    plotTime=datetime(dataW(ind,1),'InputFormat',infmt);

    resBin=cell2mat(resBins(dataIndex));
    resBinH=cell2mat(resBinsH(dataIndex));
    autoCorrThresh=goldAutoCorr-2;

    SI=SIs(dataIndex,1);
    SIh=SIHs(dataIndex,1);
    if(isnan(SI))
        continue;
    end
    firstHeaderIndex=headerIndex(gold,resBin, autoCorrThresh,goldAutoCorr);
    [BERSnf,avgBERnf,errSeqnf]=BER_packets_HRSync(firstHeaderIndex(1),resBin.',packetStream);
    if(avgBERnf==0)
        continue
    end
    firstHeaderIndexH=headerIndex(gold,resBinH,  autoCorrThresh-2,goldAutoCorr);
    [BERSnfH,avgBERnfH,errSeqnfH]=BER_packets_HRSync(firstHeaderIndexH(1),resBinH.',packetStream);

   % [gapDistribution, EFR, gapsCumul,unscaledGaps] = runLengthDisitrbution(errSeqnf);
   % [gapDistributionH, EFRH, gapsCumulH,unscaledGapsH] = runLengthDisitrbution(errSeqnfH);
    burst=burstDistribution(errSeqnf,berThresh);
        burstH=burstDistribution(errSeqnfH,berThresh);

    [estTR,estE] = hmmtrain(errSeqnf.',trans_hat,emis_hat,'Symbols',symbols,'Verbose',true,'Tolerance',tol,'maxIterations',maxIter);
    [estTRH,estEH] = hmmtrain(errSeqnfH.',trans_hat,emis_hat,'Symbols',symbols,'Verbose',true,'Tolerance',tol,'maxIterations',maxIter);
    estTR(1,:)=[];
    estTR(:,1)=[];
    estE(1,:)=[];
    estTRH(1,:)=[];
    estTRH(:,1)=[];
    estEH(1,:)=[];

    [errSeqnfF,~]=hmmgenerate(length(errSeqnf),estTR,estE,'Symbols',symbols);
    [errSeqnfHF,~]=hmmgenerate(length(errSeqnfH),estTRH,estEH,'Symbols',symbols);
        burstF=burstDistribution(errSeqnfF,berThresh);
        burstFH=burstDistribution(errSeqnfHF,berThresh);
   % [~, EFRF, ~,~] = runLengthDisitrbution(errSeqnfF.');
   % [~, EFRHF, ~,~] = runLengthDisitrbution(errSeqnfHF.');
    % estTR(1,:)=[];
    % estTR(:,1)=[];
    % estE(1,:)=[];
    % estTRH(1,:)=[];
    % estTRH(:,1)=[];
    % estEH(1,:)=[];

        h = figure;
            set(h, 'Visible', 'off');

    subplot(2,1,1)
    semilogx(burst)
    hold on
    semilogx(burstF)
    hold off
    title("EFR ")
    xlabel("length of interval m")
    ylabel('Pr(0^{m}|1)')
    legend('Observed EFR',length(p)+" State Fritchman model");
    subplot(2,1,2)
    mc=dtmc(estTR,'StateNames',stateNames);
    graphplot(mc,'ColorEdges',true,'LabelEdges',true);
    title("Fritchman model")
    sgtitle(datestr(plotTime)+" Index: "+dataIndex+" BER:"+ avgBERnf+" S.I: "+SI)
    

        h1 = figure;
            set(h1, 'Visible', 'off');

    subplot(2,1,1)
    semilogx(burstH)
    hold on
    semilogx(burstFH)
    hold off
    title("EFR(H)")
    xlabel("length of interval m")
    ylabel('Pr(0^{m}|1)')
    legend('Observed EFR',length(p)+" State Fritchman model");
    subplot(2,1,2)
    mcH=dtmc(estTRH,'StateNames',stateNames);
    graphplot(mcH,'ColorEdges',true,'LabelEdges',true);
    title("Fritchman model");
    sgtitle(datestr(plotTime)+" Index: "+dataIndex+" BER:"+ avgBERnfH+" S.I: "+SIh)

    saveas(h,datestr(plotTime,30),'fig')
    saveas(h,datestr(plotTime,30),'png')
    saveas(h1,"H"+datestr(plotTime,30),'fig')
    saveas(h1,"H"+datestr(plotTime,30),'png')
end
