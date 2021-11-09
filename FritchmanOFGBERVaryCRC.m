disp("started")
clear all;
RSParam=[0.05,50 ];
overheadThresh=50;
K=500;

addpath '..\..\data'
delta=RSParam(1);
Q=RSParam(2);

frameCount=K;%
payloadSize=1024;
frameLength=payloadSize;
bitCount=frameCount*payloadSize;
CRCLength=32;
degreeBits=16;
KBits=16;
seedBits=16;
LTHeaderLength=degreeBits+KBits+seedBits; %16 bits for K, 16 bits for degree and 16 bits for seed
poly32=[32,26,23,22,16,12,11,10,8,7,5,4,2,1,0];
poly24=[24,22,20,19,18,16,14,13,11,10,8,7,6,3,1,0];
poly16=[16,15,2,0];
poly8=[8,7,6,4,2,1,0];
poly4=[4,1,0];
poly3=[3,1,0];
poly1=[1,0];
mat2cell(poly32,1)
polys=[mat2cell(poly32,1) mat2cell(poly24,1) mat2cell(poly16,1) mat2cell(poly8,1) mat2cell(poly4,1)]


poly4=[4,1,0];
poly5=[5,3,0];
poly6=[6,5,3,2,1,0];
poly7=[7,3,0];
poly8=[8,7,6,4,2,1,0];

polys=[mat2cell(poly4,1) mat2cell(poly5,1) mat2cell(poly6,1) mat2cell(poly7,1) mat2cell(poly8,1)]

LFSRSeed=10000;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=53256;%[1 0 1 1 1 0 0 0 ]
polyCounts=length(polys);
aveBers=zeros(polyCounts,1);
%figure(1)
%hold on
legendStrings=[];
decodeablesRange=overheadThresh;
decodeablesRange=2.5;
decodeProb=zeros(polyCounts,frameCount*decodeablesRange);
decodeProbRec=zeros(polyCounts,frameCount*decodeablesRange);
trimmedProb=zeros(polyCounts,frameCount*decodeablesRange-K);
trimmedProbRec=zeros(polyCounts,frameCount*decodeablesRange-K);
droppedPacketsMean=zeros(polyCounts,1);
droppedPacketsMeanRate=zeros(polyCounts,1);
recCountMean=droppedPacketsMean;
setChoice=2;
iterationCount=20;

for polyInd=1:polyCounts
    poly=cell2mat(polys(polyInd));

    crcGen1 = comm.CRCGenerator(...
    'Polynomial', poly, ...
    'InitialConditions', 1, ...
    'DirectMethod', true, ...
    'FinalXOR', 1);
crcDetect1=comm.CRCDetector(...
    'Polynomial', poly, ...
    'InitialConditions', 1, ...
    'DirectMethod', true, ...
    'FinalXOR', 1);
frameSize=payloadSize+poly(1);

droppedPackets=zeros(iterationCount,1);
droppedPacketsRate=zeros(iterationCount,1);
recCounts=droppedPackets;
BERs=zeros(iterationCount,1);
Overheads=BERs;
decodedChecks=BERs;
decodeables=zeros(iterationCount,frameCount*decodeablesRange);
decodeablesRec=zeros(iterationCount,frameCount*decodeablesRange);

for count=1:iterationCount
   [ polyInd count]



packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,[]);
frames=zeros(frameCount,frameSize);
packets=reshape(packetStream,payloadSize,[]).';
fileNames=["dataWeak" "dataMod" "dataStrong"];
filenameData =fileNames(setChoice);
load(filenameData);
symbols=[0,1];

errSeqLen=size(frames,1)*size(frames,2)*overheadThresh;

[errSeqF,~]=hmmgenerate(errSeqLen,estTR,estE,'Symbols',symbols);
BER=mean(errSeqF);
decoded=false;    
packetsPerIteration=1;

overThresh=false;
rng('shuffle')
recCount=0;
startIndex=1;
endIndex=startIndex+packetsPerIteration*frameSize-1;


%loopTurbulence=turbulence;
recCount=0;
recIndex=1;
decodedPackets=zeros(size(packets));
decodedPacketCheck=zeros(frameCount,1);
decoded=false;    
overThresh=false;
rng('shuffle')
G=zeros(frameCount);
dist=RobustSolitonQ(frameCount,delta,Q);    
degrees=[];
intactCount=0;
currDegree=0;
currSeed=0;
decodedStream=reshape(decodedPackets,[],1);
while (~decoded&&~overThresh)
    raw=[];
    for packCount=1:packetsPerIteration
        recCount=recCount+1;
        [packetLT,currDegree,currSeed]=LTCoder(packets,dist,seedBits);
                    degrees=[degrees currDegree];
        degBitsIndex=payloadSize+1;
        KBitsIndex=degBitsIndex+degreeBits;
        seedBitsIndex=KBitsIndex+KBits;
        payload=[packetLT];
        raw=[raw crcGen1(payload.')];
    end

    errors=errSeqF(startIndex:endIndex).';
  %  BERL=mean(errors)
   startIndex=startIndex+packetsPerIteration*frameSize;
      endIndex=endIndex+packetsPerIteration*frameSize;
    rxBits=raw;
    framesRX=reshape( bitxor( rxBits,errors),frameSize,[]);
    
    intact=false;
    newPackets=zeros(packetsPerIteration,payloadSize);
    newPacketDetails=zeros(packetsPerIteration,2);
    loopRecCount=0;
    final=framesRX;
    for packCount=1:packetsPerIteration
        [payloadRX,CRCDetectFrame]=crcDetect1(final);
        if(CRCDetectFrame)
            droppedPackets(count)=droppedPackets(count)+1;
        end
        if(~CRCDetectFrame)
            intactCount=intactCount+1;
            loopRecCount=loopRecCount+1;
            newPackets(loopRecCount,:)=payloadRX(1:payloadSize).';
            newPacketDetails(loopRecCount,:)=[currDegree,currSeed];
            intact=true;
            recIndex=recIndex+1;
        end
    end
    if(intact)
        [decodedPackets,decoded,G]=LTDecoderOFG(newPackets(1:loopRecCount,:),newPacketDetails(1:loopRecCount,:),loopRecCount,K,G,decodedPackets);
    end
        overThresh=recCount>=frameCount*overheadThresh;
end
if(decoded)
    for dIndex=recCount:size(decodeables,2)
    decodeables(count,dIndex)=100;
    end
    for dIndex=recIndex:size(decodeables,2)
    decodeablesRec(count,dIndex)=100;
    end
decodedStream=reshape(decodedPackets.',[],1);
end
droppedPacketsRate(count)=droppedPackets(count)/recCount*100;
recCounts(count)=recCount;
recIndex;
overhead=recCount/frameCount;
totalErrors=sum(bitxor(packetStream,decodedStream));
FinalBER=totalErrors/bitCount;
BERs(count)=FinalBER;
Overheads(count)=overhead;
decodedChecks(count)=decoded;
%recCount
%intactCount
nBins=frameCount+1;
compCost=mean(degrees)-1;
%h=histogram(degrees,nBins,'Normalization','probability','DisplayStyle','stairs');
%hold on
%plot(dist)
%hold off

end
aveBER=mean(BERs)
aveBers(polyInd)=aveBER;
droppedPacketsMean(polyInd)=mean(droppedPackets);
droppedPacketsMeanRate(polyInd)=mean(droppedPacketsRate);
recCountMean(polyInd)=mean(recCounts);
aveOverhead=mean(Overheads);
decodeProb(polyInd,:)=mean(decodeables);
decodeProbRec(polyInd,:)=mean(decodeablesRec);
trimmedProb(polyInd,:)=decodeProb(polyInd,K+1:end);

trimmedProbRec(polyInd,:)=decodeProbRec(polyInd,K+1:end);
xLim=1:length(decodeProb);
xLim=xLim/K;
trimmedX=xLim(K+1:end);

    

legendStrings=[legendStrings "CRC"+poly(1)];
end
figure();

plot(trimmedX,trimmedProb)
%legend(legendStrings);
ylabel("Decoding Probability");
xlabel("Overhead (1/rate)");
title("OFG Decoding Prob of CRC ")
legend(legendStrings)
hold off
figure()
crc=1:polyCounts;
semilogy(crc,aveBers)
ylabel("BER");
xlabel("CRC");
title("OFG Decoding BER")
%legend(legendStrings)
