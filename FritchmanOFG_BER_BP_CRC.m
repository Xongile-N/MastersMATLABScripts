simFileName='simSettings';
createSimVars(simFileName);
load(simFileName);
addpath '..\..\data'
overheadThresh=100;
iterationCount=10
frameCount=K;
approxSize=NRS;
packetSize=KRS*gpRS.m-poly(1);

packetsPerFrame=1;
payloadSize=packetsPerFrame*(packetSize)+poly(1);
sentPacketSize=payloadSize*NRS/KRS;

bitCount=frameCount*packetSize;

frameSize=payloadSize/KRS*NRS;






decodeProb=zeros(fritchCount,frameCount*decodeablesRange);
decodeProbRec=zeros(fritchCount,frameCount*decodeablesRange);
trimmedProb=zeros(fritchCount,frameCount*decodeablesRange-K);
trimmedProbRec=zeros(fritchCount,frameCount*decodeablesRange-K);
droppedPacketsMean=zeros(fritchCount,1);
droppedPacketsMeanRate=zeros(fritchCount,1);
recCountMean=droppedPacketsMean;
meanOverheads=droppedPacketsMean;
recCounts=zeros(fritchCount,K*overheadThresh);
recCountsDec=recCounts;

BERs=zeros(fritchCount,iterationCount^2);
errorThresh=100;
Overheads=BERs;
iterCounts=zeros(fritchCount,1);
for fritchInd=1:fritchCount
setChoice=fritchToUse(fritchInd);

droppedPackets=zeros(iterationCount*2,1);
droppedPacketsRate=zeros(iterationCount*2,1);

decodeables=zeros(iterationCount*2,frameCount*decodeablesRange);
decodeablesRec=zeros(iterationCount*2,frameCount*decodeablesRange);
iterate=true;
count=0;
underMinIter=true;
errorCount=0;

while(iterate)
    count=count+1;

%for count=1:iterationCount
if(underMinIter)
    underMinIter=count<iterationCount;
end
if(~underMinIter)
    iterate=false;
    %iterate=errorCount<errorThresh;
end


packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,[]);
packets=reshape(packetStream,packetSize,[]).';
filenameData =fileNames(setChoice);
load(filenameData);
symbols=[0,1];

errSeqLen=sentPacketSize*overheadThresh*frameCount;

[errSeqF,~]=hmmgenerate(errSeqLen,estTR,estE,'Symbols',symbols);
BER=mean(errSeqF);
decoded=false;    

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
receivedPackets=decodedPackets;
seeds=[];
intactCount=0;
currDegree=0;
currSeed=0;
decodedStream=reshape(decodedPackets,[],1);
    while (~decoded&&~overThresh)
        raw=zeros(packetSize,1);
        currDegrees=zeros(packetsPerFrame,1);
            currSeeds=zeros(packetsPerFrame,1);
            recCount=recCount+packetsPerFrame;

        for packCount=1:packetsPerFrame
            [packetLT,currDegree,currSeed]=LTCoder(packets,dist,seedBits);
            currDegrees(packCount)=currDegree;
            currSeeds(packCount)=currSeed;
            degBitsIndex=payloadSize+1;
            KBitsIndex=degBitsIndex+degreeBits;
            seedBitsIndex=KBitsIndex+KBits;
            raw(1+(packCount-1)*packetSize:packetSize*packCount)= packetLT;
            RX=crcGen1(raw);
        end

            errors=errSeqF(startIndex:endIndex).';
            startIndex=startIndex+frameSize;
            endIndex=endIndex+frameSize;
            encoded=rsEncoder(RX);

            rxBits=encoded;

            framesRX=reshape( bitxor( rxBits,errors),frameSize,[]);

        intact=false;
        newPackets=zeros(packetsPerFrame,packetSize);
        newPacketDetails=zeros(packetsPerFrame,2);
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
            intactCount=frameCount;
            receivedPackets=packets;

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
else
    for dIndex=recCount:size(decodeables,2)
        decodeables(count,dIndex)=100*decodedableCount/K;
    end

end

droppedPacketsRate(count)=droppedPackets(count)/recCount;
recCounts(count)=recCount;
recIndex;
overhead=recCount/K;
totalErrors=sum(bitxor(packetStream,decodedStream));
FinalBER=totalErrors/bitCount;

BERs(fritchInd,count)=FinalBER;
Overheads(fritchInd,count)=overhead;

errorCount=errorCount+totalErrors;
   [ fritchInd count errorCount decoded totalErrors recCount]

%while(
end

aveBER=mean(BERs(fritchInd,1:count))
aveBers(fritchInd)=aveBER;
droppedPacketsMean(fritchInd)=mean(droppedPackets(1:count));
droppedPacketsMeanRate(fritchInd)=mean(droppedPacketsRate(1:count));
recCountMean(fritchInd)=mean(recCounts(1:count));
aveOverhead=mean(Overheads(fritchInd,1:count));
meanOverheads(fritchInd)=aveOverhead;
decodeProb(fritchInd,:)=mean(decodeables(1:count,:));
decodeProbRec(fritchInd,:)=mean(decodeablesRec(1:count,:));
trimmedProb(fritchInd,:)=decodeProb(fritchInd,K+1:end);

trimmedProbRec(fritchInd,:)=decodeProbRec(fritchInd,K+1:end);



legendStrings=[legendStrings "sigma = "+rytovs(setChoice)];
end
%legend(legendStrings);

hold off
fritch=1:fritchCount;
semilogy(fritch,aveBers)
ylabel("BER");
xlabel("Fritchman Model");
title("OFG Decoding BER")
xLim=1:length(decodeProb);

xLim=xLim/K;
trimmedX=xLim(K+1:end);
% rateCutoffs=[5,5,5]
% for fritchInd=1:fritchCount
% figure();
% 
% plot(trimmedX(1:(rateCutoffs(fritchInd)-1)*K),trimmedProb(fritchInd,1:(rateCutoffs(fritchInd)-1)*K))
% ylabel("Decoding Probability");
% xlabel("Overhead (1/rate)");
% title("OFG Decoding Prob of Fritch "+fritchInd)
% end
% 
% figure();
% 
% plot(trimmedX(1:K*2),trimmedProbRec(:,1:K*2))
% ylabel("Decoding Probability");
% xlabel("Overhead (1/rate)");
% title("OFG Decoding Prob of Fritch ")
% legend('$sigma _ I ^ 2={0.18}$','$sigma _ I ^ 2={0.35}$','$sigma _ I ^ 2={0.52}$')
% figure();

plot(trimmedX(1:(decodeablesRange-1)*K),trimmedProb(:,1:(decodeablesRange-1)*K))
ylabel("Decoding Probability");
xlabel("Overhead (1/rate)");
title("OFG Decoding Prob of Fritch ")
legend(legendStrings)
