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
SILns=zeros(loopCount,2);
SILnHs=zeros(loopCount,2);

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
checkInd=1;
for count=1:loopCount

    count
        ind=ceil((count)*timeToRead*3600);

        plotTime=datetime(dataW(ind,1),'InputFormat',infmt);

    data = fread(fid, readAmount*sampleRate, '*float32');
    if(count~=checkInd)
      %  continue
    end
    [resBin,thresh,bitPos,iters,bitSamples]=clockRecoveryFrameSI(data,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,thresh);
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



     firstHeader=[bitPos(firstHeaderIndex(1)-1)+1 bitPos(firstHeaderIndex(1)+goldLength-1)];
    threshH= mean(data(firstHeader(1):firstHeader(2)));
    SIthresh=thresh*0.5;

       nBins=500;
    Ln=@(r,x) LNSample(r,x);
    tailored=data(data>SIthresh);
    Et=expectedValue(tailored);
    [SI,~,~]=ScintIndex1(tailored,respons, 0);
     SIthreshH=threshH*0.5;
     tailoredH=data(data>SIthreshH);
     EtH=expectedValue(tailoredH);
     [SIh,~,~]=ScintIndex1(tailoredH,respons, 0);
     f = figure;
    set(f, 'Visible', 'off');
    
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
try
    mdlLn=fitnlm(xAdj,y,Ln,SI);   
        rytov=mdlLn.Coefficients.Estimate;

    SILn=(exp(rytov)-1);

    plot(xAdj,y)
    hold on
    line(xAdj.',predict(mdlLn,xAdj.'),'Color','r');
    hold off
    ylabel('PDF');
legend("Observed sequence","Log Normal Weak Turbulence SI="+SILn);
xlabel('Intensity (Normalised to mean)');
    title(datestr(plotTime)+" Index: "+count)

    saveas(f,"F"+datestr(plotTime,30),'fig')
    saveas(f,"F"+datestr(plotTime,30),'png')
catch
    disp(count+"Failed")
end
try
    mdlLnH=fitnlm(xHAdj,y,Ln,SIh);
        rytovH=mdlLnH.Coefficients.Estimate;
    SILnH=(exp(rytovH)-1);
    plot(xHAdj,yH)
    hold on
    line(xHAdj.',predict(mdlLnH,xHAdj.'),'Color','r');
    hold off
    title(datestr(plotTime)+" Index: "+count+"H")
    ylabel('PDF');
legend("Observed sequence","Log Normal Weak Turbulence SI="+SILnH);
xlabel('Intensity (Normalised to mean)');
    saveas(f,"FH"+datestr(plotTime,30),'fig')
    saveas(f,"FH"+datestr(plotTime,30),'png')
catch
        disp(count+"FailedH")

end
    %line(xAdj.',predict(mdlGG,xAdj.'),'Color','r');
    %hold off
    %ylabel('PDF');
    %h1=histogram(turbVec,nBins,'Normalization','pdf','DisplayStyle','stairs');


    
    CN_2=mdlLn.Coefficients.Estimate/1.23/(k^(7/6)*L^(11/6));
    
% 



    SIs(count,1)=SI;
    SIs(count,2)=count;

    SIHs(count,1)=SIh;
    SIHs(count,2)=count;
    
        SILns(count,1)=SILn;
    SILns(count,2)=count;
            SILnHs(count,1)=SILnH;
    SILnHs(count,2)=count;
%                         resBins(count)=mat2cell(resBin,1);
%                         resBinsH(count)=mat2cell(resBinH,1);
%                         errSeqs(count)=mat2cell(errSeqnf.',1);
%                         errSeqsH(count)=mat2cell(errSeqnfH.',1);
    if(count==checkInd)
       % break
    end

end
    save("FESI_Ts"+datestr(startTime,30),"SIs","SIHs","SILns","SILnHs","BERS","BERSh","totalHours","timeToRead",'-v7.3');
