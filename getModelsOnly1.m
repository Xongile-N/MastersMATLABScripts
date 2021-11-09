clear all;
addpath '..\..\data'

clc
weatherFiles=["20200729_Weather_1000_24h.mat";"20200731_Weather_1000_24h.mat";"20200801_Weather_1200_24h.mat"];
choice=2;
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

filenameData = "ESI_Ts"+datestr(startTime,30);   %as appropriate
load(filenameData);
models=cell(length(SIs),3);
modelsH=cell(length(SIs),3);


for dataIndex=1:length(SIs)
    dataIndex
    ind=ceil((dataIndex)*timeToRead*3600);
    plotTime=datetime(dataW(ind,1),'InputFormat',infmt);

    resBin=cell2mat(resBins(dataIndex));
        resBinH=cell2mat(resBinsH(dataIndex));

    errSeqnf=cell2mat(errSeqs(dataIndex));
    errSeqnfH=cell2mat(errSeqsH(dataIndex));
    autoCorrThresh=goldAutoCorr-2;

    SI=SI_Ts(dataIndex,1);
    SIh=SIH_Ts(dataIndex,1);
    if(isnan(SI))
        continue;
    end
    if(BERS(dataIndex)==0||isnan(BERS(dataIndex)))
        continue
    end
    disp("training")
    [estTR,estE,logLik] = hmmtrain(errSeqnf,trans_hat,emis_hat,'Symbols',symbols,'Verbose',false,'Tolerance',tol,'maxIterations',maxIter);
        disp("training header")

    [estTRH,estEH,logLikH] = hmmtrain(errSeqnfH,trans_hat,emis_hat,'Symbols',symbols,'Verbose',false,'Tolerance',tol,'maxIterations',maxIter);
    iterCount=[length(logLik) length(logLikH)] 
%     estTR(1,:)=[];
%     estTR(:,1)=[];
%     estE(1,:)=[];
%     estTRH(1,:)=[];
%     estTRH(:,1)=[];
%     estEH(1,:)=[];
    models(dataIndex,1)=mat2cell(estTR,size(estTR,1));
    models(dataIndex,2)=mat2cell(estE,size(estE,1));
        models(dataIndex,3)=mat2cell(logLik,size(logLik,1));

    modelsH(dataIndex,1)=mat2cell(estTRH,size(estTRH,1));
    modelsH(dataIndex,2)=mat2cell(estEH,size(estEH,1));
        modelsH(dataIndex,3)=mat2cell(logLikH,size(logLikH,1));

end
    save("EMSIs"+datestr(startTime,30),"models","modelsH","errSeqs","errSeqsH","SIs","SIHs","SIH_Ts","SI_Ts","BERS","BERSh","totalHours","timeToRead","resBins","resBinsH",'-v7.3');

