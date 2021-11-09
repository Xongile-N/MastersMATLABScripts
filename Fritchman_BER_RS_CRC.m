disp("started")
clear all;
RSParam=[0.05,10 ];
overheadThresh=50;
K=100;

addpath '..\..\data'
delta=RSParam(1);
Q=RSParam(2);

poly32=[32,26,23,22,16,12,11,10,8,7,5,4,2,1,0];
poly24=[24,22,20,19,18,16,14,13,11,10,8,7,6,3,1,0];
poly16=[16,15,2,0];
poly8=[8,7,6,4,2,1,0];
poly4=[4,1,0];
poly3=[3,1,0];
poly1=[1,0];
poly = poly4;
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

NRS = 255;
KRS = 191;
[gpRS] = rsgenpoly(NRS,KRS,[],0);
useBits=true;
rsEncoder=comm.RSEncoder('CodewordLength',NRS,'MessageLength',KRS,"BitInput", useBits,"GeneratorPolynomial",gpRS);
rsDecoder=comm.RSDecoder('CodewordLength',NRS,'MessageLength',KRS,"BitInput", useBits,"GeneratorPolynomial",gpRS);

packetCount=K;
approxSize=NRS;
packetSize=KRS*gpRS.m-poly(1);

packetsPerFrame=floor(approxSize/(NRS*gpRS.m));
packetsPerFrame=1;
payloadSize=packetsPerFrame*(packetSize)+poly(1);
sentPacketSize=payloadSize*NRS/KRS;

bitCount=packetCount*packetSize;
CRCLength=32;
degreeBits=16;
KBits=16;
seedBits=16;
LTHeaderLength=degreeBits+KBits+seedBits; %16 bits for K, 16 bits for degree and 16 bits for seed

frameSize=payloadSize/KRS*NRS;




LFSRSeed=10000;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=53256;%[1 0 1 1 1 0 0 0 ]
fritchCount=3;
aveBers=zeros(fritchCount,1);
%figure(1)
%hold on
legendStrings=[];
decodeablesRange=overheadThresh;

decodeProb=zeros(fritchCount,packetCount*decodeablesRange);
decodeProbRec=zeros(fritchCount,packetCount*decodeablesRange);
trimmedProb=zeros(fritchCount,packetCount*decodeablesRange-K);
trimmedProbRec=zeros(fritchCount,packetCount*decodeablesRange-K);
droppedPacketsMean=zeros(fritchCount,1);
droppedPacketsMeanRate=zeros(fritchCount,1);
recCountMean=droppedPacketsMean;
meanOverheads=droppedPacketsMean;
iterationCount=10;

BERs=zeros(fritchCount,iterationCount^2);
errorThresh=100;
Overheads=BERs;
iterCounts=zeros(fritchCount,1);
for fritchInd=1:fritchCount
setChoice=fritchInd;

droppedPackets=zeros(iterationCount^2,1);
droppedPacketsRate=zeros(iterationCount^2,1);
recCounts=droppedPackets;

decodeables=zeros(iterationCount^2,packetCount*decodeablesRange);
decodeablesRec=zeros(iterationCount^2,packetCount*decodeablesRange);
iterate=true;
count=0;
underMinIter=true;
errorCount=0;

while(iterate)
    count=count+1;

%for count=1:iterationCount
if(underMinIter)
    iterate=true;
    underMinIter=count<iterationCount;
end
if(~underMinIter)
    iterate=errorCount>errorThresh;
end
   [ fritchInd count errorCount]


packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,[]);
packets=reshape(packetStream,packetSize,[]).';
fileNames=["dataWeak" "dataMod" "dataStrong"];
filenameData =fileNames(setChoice);
load(filenameData);
symbols=[0,1];

errSeqLen=sentPacketSize*overheadThresh*packetCount;

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
decodedPacketCheck=zeros(packetCount,1);
decoded=false;    
overThresh=false;
rng('shuffle')
G=zeros(packetCount);
dist=RobustSolitonQ(packetCount,delta,Q);    
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

           % raw=[raw crcGen1(payload.')];

        errors=errSeqF(startIndex:endIndex).';
      %  BERL=mean(errors)
       startIndex=startIndex+frameSize;
          endIndex=endIndex+frameSize;
        %rxBits=raw;
                  encoded=rsEncoder(RX);

            rxBits=encoded;

        framesRX=reshape( bitxor( rxBits,errors),frameSize,[]);

        intact=false;
        newPackets=zeros(packetsPerFrame,packetSize);
        newPacketDetails=zeros(packetsPerFrame,2);
        loopRecCount=0;
            [final,errCount]=rsDecoder(framesRX);

        %final=framesRX;
        for packCount=1:packetsPerFrame
            dropPacket=false;
            failedDecoding=errCount(packCount)<0;

            if(~failedDecoding)
                [payloadRX,dropPacket]=crcDetect1(final);
            end

            packetRX=final(1+(packCount-1)*packetSize:packetSize*packCount);
            if(dropPacket)
                droppedPackets(count)=droppedPackets(count)+1;
            end
            if(~dropPacket)
                intactCount=intactCount+1;
                loopRecCount=loopRecCount+1;
                newPackets(loopRecCount,:)=packetRX;
                newPacketDetails(loopRecCount,:)=[currDegrees(packCount),currSeeds(packCount)];
                intact=true;
                recIndex=recIndex+1;
            end
        end
        if(intact)
            [decodedPackets,decoded,G]=LTDecoderOFG(newPackets(1:loopRecCount,:),newPacketDetails(1:loopRecCount,:),loopRecCount,K,G,decodedPackets);
        end
            overThresh=recCount>=packetCount*overheadThresh;
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
%     droppedPackets=zeros(iterationCount^2,1);
% droppedPacketsRate=zeros(iterationCount^2,1);
% recCounts=droppedPackets;
% 
% decodeables=zeros(iterationCount^2,packetCount*decodeablesRange);
% decodeablesRec=zeros(iterationCount^2,packetCount*decodeablesRange);


droppedPacketsRate(count)=droppedPackets(count)/recCount;
recCounts(count)=recCount;
recIndex;
overhead=recCount/K;
totalErrors=sum(bitxor(packetStream,decodedStream));
FinalBER=totalErrors/bitCount;

BERs(fritchInd,count)=FinalBER;
Overheads(fritchInd,count)=overhead;

errorCount=errorCount+totalErrors;
%while(
end

aveBER=mean(BERs(fritchInd,1:count))
aveBers(fritchInd)=aveBER;
droppedPacketsMean(fritchInd)=mean(droppedPackets(1:count));
droppedPacketsMeanRate(fritchInd)=mean(droppedPacketsRate(1:count));
recCountMean(fritchInd)=mean(recCounts(1:count));
aveOverhead=mean(Overheads(fritchInd,1:count));
meanOverheads(setChoice)=aveOverhead;
decodeProb(setChoice,:)=mean(decodeables(1:count,:));
decodeProbRec(setChoice,:)=mean(decodeablesRec(1:count,:));
trimmedProb(setChoice,:)=decodeProb(setChoice,K+1:end);

trimmedProbRec(setChoice,:)=decodeProbRec(setChoice,K+1:end);



%legendStrings=[legendStrings "Overhead of sent"+setChoice];
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

plot(trimmedX(1:(3-1)*K),trimmedProb(:,1:(3-1)*K))
ylabel("Decoding Probability");
xlabel("Overhead (1/rate)");
title("OFG Decoding Prob of Fritch ")
legend('$sigma _ I ^ 2={0.18}$','$sigma _ I ^ 2={0.35}$','$sigma _ I ^ 2={0.52}$')
