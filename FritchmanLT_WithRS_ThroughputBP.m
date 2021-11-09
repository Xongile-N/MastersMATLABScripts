simFileName='simSettings';
createSimVars(simFileName);
load(simFileName);
addpath '..\..\data'

frameCount=K;
approxSize=NRS;
frameSize=NRS*gpRS.m;


payloadSize=(gpRS.m*KRS)-poly(1);

bitCount=frameCount*payloadSize;


decodeProb=zeros(fritchCount,frameCount*decodeablesRange);
decodeProbRec=zeros(fritchCount,frameCount*decodeablesRange);
trimmedProb=zeros(fritchCount,frameCount*decodeablesRange-K);
trimmedProbRec=zeros(fritchCount,frameCount*decodeablesRange-K);
droppedPacketsMean=zeros(fritchCount,1);
droppedPacketsMeanRate=zeros(fritchCount,1);
throughputsLTCodedBP=zeros(fritchCount,1)
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
endIndex=startIndex+frameSize-1;


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
seeds=[];

intactCount=0;
currDegree=0;
currSeed=0;
decodedChecks=[];
receivedPackets=decodedPackets;
sendCount=frameCount*overheadThresh;
send=true;
decodedableCount=0;
while(send)
    recIndex=recIndex+1;
    send=recIndex<=sendCount;
    recCount=recCount+1;
    [packetLT,currDegree,currSeed]=LTCoder(packets,dist,seedBits);

    raw= crcGen1(packetLT.');

    errors=errSeqF(startIndex:endIndex).';
    startIndex=startIndex+frameSize;
    endIndex=endIndex+frameSize;
    encoded=rsEncoder(raw);

    rxBits=encoded;

    framesRX=reshape( bitxor( rxBits,errors),frameSize,[]);

    intact=false;

    loopRecCount=0;
    [final,errCount]=rsDecoder(framesRX);
    dropPacket=true;
    failedRSDecoding=errCount<0;

    if(~failedRSDecoding)
        [payloadRX,CRCDetectFrame]=crcDetect1(final);
        if(useCRC)
            dropPacket=CRCDetectFrame;
        else
            dropPacket=biterr(payloadRX,payload.')>0;

        end
    end
    if(~dropPacket)
        intactCount=intactCount+1;
        intact=true;
        degrees=[degrees currDegree];
        seeds=[seeds currSeed];
                                receivedPackets(intactCount,:)=payloadRX(1:payloadSize).';
            receivedPacketDetails(intactCount,:)=[currDegree,currSeed];
         [decodedPackets,decodedPacketCheck,decoded]=LTDecoderBP(receivedPackets,receivedPacketDetails,intactCount,K,decodedPackets,decodedPacketCheck,degrees,seeds);
        if(currDegree==1)
          decodedableCount=1+decodedableCount;
        end
    end
    if(decoded)
        send=false;
        intactCount=frameCount;
        receivedPackets=packets;

    end
end
recIndex;
overhead=recCount/frameCount;
if(~decoded) 
    intactCount=sum(decodedPacketCheck);
    indices=find(decodedPacketCheck==0);
    decodedPackets(indices,:)=[];
    packets(indices,:)=[];
end
decodedStream=reshape(decodedPackets,[],1);
receivedPacketStream=reshape(packets,[],1);
if(intactCount==0)
    failedDecoding=[failedDecoding count];
else
    totalErrors=sum(bitxor(receivedPacketStream,decodedStream));

    FinalBER=totalErrors/(intactCount*payloadSize);
    if(FinalBER>1)
        FinalBER
    end
    BERs(count)=FinalBER;
end
        if(useFullLTThroughput)
            throughputsLoop(count)=100*intactCount/(frameCount*overheadThresh);
        else
            throughputsLoop(count)=100*intactCount/frameCount;
        end
end
BERs(failedDecoding)=[];
aveBER=mean(BERs)
aveBersLTCodedBP(fritchInd)=aveBER;
throughputsLTCodedBP(fritchInd)=mean(throughputsLoop);
end

save("LTCodedBP.mat","throughputsLTCodedBP","aveBersLTCodedBP")
