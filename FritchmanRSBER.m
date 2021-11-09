disp("started")
clear all;
setChoice=2;
RSParam=[0.05,10];
overheadThresh=8
K=100

addpath '..\..\data'
delta=RSParam(1);
Q=RSParam(2);

payloadSize=1000;
frameCount=K;%
frameLength=payloadSize;
bitCount=frameCount*payloadSize;

CRCLength=32;
degreeBits=16;
KBits=16;
seedBits=16;
LTHeaderLength=degreeBits+KBits+seedBits; %16 bits for K, 16 bits for degree and 16 bits for seed
poly = [32,26,23,22,16,12,11,10,8,7,5,4,2,1,0];
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
frameSize=payloadSize+32;

LFSRSeed=10000;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=53256;%[1 0 1 1 1 0 0 0 ];
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
        if(~CRCDetectFrame)
            BERL=mean(errors)
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
decodedStream=reshape(decodedPackets.',[],1);
end
overhead=recCount/frameCount;
totalErrors=sum(bitxor(packetStream,decodedStream));
FinalBER=totalErrors/bitCount;
%recCount
%intactCount
nBins=frameCount+1;
compCost=mean(degrees)-1;
%h=histogram(degrees,nBins,'Normalization','probability','DisplayStyle','stairs');
%hold on
%plot(dist)
%hold off
costs=[overhead
    compCost];


