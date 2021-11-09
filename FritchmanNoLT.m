simFileName='simSettings';
createSimVars(simFileName);
load(simFileName);
addpath '..\..\data'

frameCount=K;%
payloadSize=KRS*gpRS.m-poly(1);
frameSize=payloadSize+poly(1);

frameLength=payloadSize;
bitCount=frameCount*payloadSize;



decodeProb=zeros(fritchCount,frameCount*decodeablesRange);
decodeProbRec=zeros(fritchCount,frameCount*decodeablesRange);
trimmedProb=zeros(fritchCount,frameCount*decodeablesRange-K);
trimmedProbRec=zeros(fritchCount,frameCount*decodeablesRange-K);
droppedPacketsMean=zeros(fritchCount,1);
droppedPacketsMeanRate=zeros(fritchCount,1);
throughputsUncoded=zeros(fritchCount,1)
recCountMean=droppedPacketsMean;
for fritchInd=1:fritchCount
setChoice=fritchToUse(fritchInd);
throughputsLoop=zeros(iterationCount,1);
droppedPackets=zeros(iterationCount,1);
droppedPacketsRate=zeros(iterationCount,1);
recCounts=droppedPackets;
BERs=zeros(iterationCount,1);
Overheads=BERs;
decodedChecks=BERs;
decodeablesRange=overheadThresh;
decodeables=zeros(iterationCount,frameCount*decodeablesRange);
decodeablesRec=zeros(iterationCount,frameCount*decodeablesRange);
failedDecoding=[];

for count=1:iterationCount
   [ fritchInd count]



packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,[]);
frames=zeros(frameCount,frameSize);
packets=reshape(packetStream,payloadSize,[]).';
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
decodedChecks=[];
receivedPackets=decodedPackets;

for recIndex=1: frameCount
    recCount=recCount+1;
    payload=packets(recIndex,:);
    raw= crcGen1(payload.');

    errors=errSeqF(startIndex:endIndex).';
    startIndex=startIndex+frameSize;
    endIndex=endIndex+frameSize;
    rxBits=raw;
    framesRX=reshape( bitxor( rxBits,errors),frameSize,[]);
    
    intact=false;
    newPackets=zeros(packetsPerIteration,payloadSize);
    newPacketDetails=zeros(packetsPerIteration,2);
    loopRecCount=0;
    final=framesRX;
    [payloadRX,CRCDetectFrame]=crcDetect1(final);
    if(useCRC)
     dropPacket=CRCDetectFrame;
    else
        dropPacket=biterr(payloadRX,payload.')>0;
    end
    if(~dropPacket)
        intactCount=intactCount+1;
        intact=true;
        decodedPackets(intactCount,:)=payloadRX(1:payloadSize).';
        receivedPackets(intactCount,:)=payload.';
    end

    if(intact)
        decoded=recIndex==frameCount;
    end
end
throughputsLoop(count)=100*intactCount/frameCount;
recIndex;
overhead=recCount/frameCount;
decodedStream=reshape(decodedPackets,[],1);
receivedPacketStream=reshape(receivedPackets,[],1);
if(intactCount==0)
    failedDecoding=[failedDecoding count];
else
    totalErrors=sum(bitxor(receivedPacketStream(),decodedStream));

    FinalBER=totalErrors/(intactCount*frameLength);
    BERs(count)=FinalBER;
end

end
BERs(failedDecoding)=[];
aveBER=mean(BERs)
aveBersUncoded(fritchInd)=aveBER;
throughputsUncoded(fritchInd)=mean(throughputsLoop);
end
save("uncoded.mat","throughputsUncoded","aveBersUncoded")

