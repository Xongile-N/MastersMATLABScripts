function addedThroughput= FritchmanLT_WithRS_ThroughputMultiOverhead (index,throughputsOrig)

simFileName='simSettings';
createSimVars(simFileName);
load(simFileName);
addpath '..\..\data'
overheadThresh=overheadThreshes(index)

frameCount=K;
approxSize=NRS;
frameSize=NRS*gpRS.m;


payloadSize=(gpRS.m*KRS)-32;

bitCount=frameCount*payloadSize;

recCounts=zeros(fritchCount,iterationCount);
recCountsDec=recCounts;
decodeProb=zeros(fritchCount,frameCount*decodeablesRange);
decodeProbRec=zeros(fritchCount,frameCount*decodeablesRange);
trimmedProb=zeros(fritchCount,frameCount*decodeablesRange-K);
trimmedProbRec=zeros(fritchCount,frameCount*decodeablesRange-K);
droppedPacketsMean=zeros(fritchCount,1);
droppedPacketsMeanRate=zeros(fritchCount,1);
throughputsLTCoded=zeros(fritchCount,1)
recCountMean=droppedPacketsMean;
for fritchInd=1:fritchCount
setChoice=fritchToUse(fritchInd);
    throughputsLoop=zeros(iterationCount,1);
    droppedPackets=zeros(iterationCount,1);
    droppedPacketsRate=zeros(iterationCount,1);
    %recCounts=droppedPackets;
    BERs=zeros(iterationCount,1);
    Overheads=BERs;
    decodedChecks=BERs;
    failedDecoding=[];

    for count=1:iterationCount
        [ fritchInd count]



        packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,[]);
        frames=zeros(frameCount,frameSize);
        packets=reshape(packetStream,payloadSize,[]).';
        filenameData =fileNames(setChoice);
        load(filenameData);
        symbols=[0,1];

        errSeqLen=round(size(frames,1)*size(frames,2)*overheadThresh);

        [errSeqF,~]=hmmgenerate(errSeqLen,estTR,estE,'Symbols',symbols);
        BER=mean(errSeqF);
        packetsPerIteration=1;

        rng('shuffle')
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
        intactCount=0;
        currDegree=0;
        currSeed=0;
        decodedChecks=[];
        receivedPackets=decodedPackets;
        sendCount=round(frameCount*overheadThresh);
        send=true;
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
                recCountsDec(fritchInd,count)=recCountsDec(fritchInd,count)+1;

            if(~failedRSDecoding)
                [payloadRX,CRCDetectFrame]=crcDetect1(final);
                if(useCRC)
                    dropPacket=CRCDetectFrame;
                else
                    dropPacket=biterr(payloadRX,payload.')>0;

                end
            end

            if(~dropPacket)
                recCounts(fritchInd,count)=recCounts(fritchInd,count)+1;
                intact=true;
                [decodedPackets,decoded,G]=LTDecoderOFG(payloadRX(1:payloadSize).',[currDegree,currSeed],1,K,G,decodedPackets);
            end
            if(decoded)
                send=false;
                intactCount=frameCount;
                receivedPackets=packets;

            end
        end
        recIndex;
       % overhead=recCount/frameCount;
        decodedStream=reshape(decodedPackets,[],1);
        receivedPacketStream=reshape(receivedPackets,[],1);


        if(intactCount==0)
            failedDecoding=[failedDecoding count];
        else
            totalErrors=sum(bitxor(receivedPacketStream(),decodedStream));

            FinalBER=totalErrors/(intactCount*payloadSize);
            BERs(count)=FinalBER;
        end
        if(intactCount>frameCount)
            intactCount;
        end
        if(useFullLTThroughput)
            throughputsLoop(count)=100*intactCount/round(frameCount*overheadThresh);
        else
            throughputsLoop(count)=100*intactCount/frameCount;
        end

    end
    BERs(failedDecoding)=[];
    aveBER=mean(BERs)
    if(isnan(aveBER))
        aveBER
    end
    aveBersLTCoded(fritchInd)=aveBER;
    throughputsLTCoded(fritchInd)=mean(throughputsLoop);
end
addedThroughput=[throughputsOrig throughputsLTCoded];
end