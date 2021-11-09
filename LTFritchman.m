clear all;
clc
addpath '..\..\data'

gold=[1,1,0,1,0,1,0,0,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1,1,0,0,1,0,1,0,0];
goldAutoCorr=31;
goldLength=length(gold);
payloadSize=500;
frameCount=100;%
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
frameSize=payloadSize+CRCLength+LTHeaderLength;

LFSRSeed=10000;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=53256;%[1 0 1 1 1 0 0 0 ];
packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,[]);
frames=zeros(frameCount,frameSize);
packets=reshape(packetStream,payloadSize,[]).';
setChoice=2;
fileNames=["dataWeak" "dataMod" "dataStrong"];
filenameData =fileNames(setChoice);
load(filenameData);
symbols=[0,1];
 overheadThresh=500;

errSeqLen=size(frames,1)*size(frames,2)*overheadThresh

[errSeqF,~]=hmmgenerate(errSeqLen,estTR,estE,'Symbols',symbols);
BER=mean(errSeqF)
decoded=false;    
packetsPerIteration=1;

overThresh=false;
rng('shuffle')
recCount=0;
startIndex=1;
endIndex=startIndex+packetsPerIteration*frameSize-1;

receivedPackets=zeros(size(frames,1)*overheadThresh,size(frames,2));
receivedPacketDetails=zeros(size(receivedPackets,1),2)-1;%stores the current degree and the seed used. In that order

%loopTurbulence=turbulence;
recCount=0;
recIndex=1;
decodedPackets=zeros(size(packets));
decodedPacketCheck=zeros(frameCount,1);
decoded=false;    
overThresh=false;
rng('shuffle')
G=zeros(frameCount);
delta=0.05;
c=0.1;
dist=RobustSoliton(frameCount,delta,c);    
degrees=[];
intactCount=0;
while (~decoded&&~overThresh)
    resBin=[];
    for packCount=1:packetsPerIteration
        recCount=recCount+1;
        [packetLT,degree,RNGSeed]=LTCoder(packets,dist,seedBits);
                    degrees=[degrees degree];

        degreeBin=de2bi(degree,degreeBits,'left-msb');
        KBin=de2bi(frameCount,KBits,'left-msb');
        seedBin=de2bi(RNGSeed,seedBits,'left-msb');
        degBitsIndex=payloadSize+1;
        KBitsIndex=degBitsIndex+degreeBits;
        seedBitsIndex=KBitsIndex+KBits;
        payload=[packetLT degreeBin KBin seedBin];
                resBin=[resBin crcGen1(payload.')];

        %frames(packCount,:)=crcGen1(payload.'); 
    end
    errors=errSeqF(startIndex:endIndex).';
    %BERL=mean(errors)
   startIndex=startIndex+packetsPerIteration*frameSize;
      endIndex=endIndex+packetsPerIteration*frameSize;

    framesRX=reshape( bitxor( resBin,errors),frameSize,[]).';
    intact=false;
    newPackets=zeros(packetsPerIteration,payloadSize);
    newPacketDetails=zeros(packetsPerIteration,2);
    loopRecCount=0;
    for packCount=1:packetsPerIteration
        [payloadRX,CRCDetectFrame]=crcDetect1(framesRX(packCount,:).');
        if(~CRCDetectFrame)
            intactCount=intactCount+1;
            loopRecCount=loopRecCount+1;
            newPackets(loopRecCount,:)=payloadRX(1:payloadSize).';
            degRBits=payloadRX(degBitsIndex:degBitsIndex+degreeBits-1).';
            KRBits=payloadRX(KBitsIndex:KBitsIndex+KBits-1).';
            seedRBits=payloadRX(seedBitsIndex:seedBitsIndex+seedBits-1).';
            degreeDe=bi2de(degRBits,'left-msb');
            KDe=bi2de(KRBits,'left-msb');
            seedDe=bi2de(seedRBits,'left-msb');
            newPacketDetails(loopRecCount,:)=[degreeDe,seedDe];
            intact=true;
            recIndex=recIndex+1;
        end
    end
    if(intact)
        [decodedPackets,decoded,G]=LTDecoderOFG(newPackets(1:loopRecCount,:),newPacketDetails(1:loopRecCount,:),loopRecCount,KDe,G,decodedPackets);
    end
        overThresh=recCount>=frameCount*overheadThresh;
end
if(decoded)
overhead=recCount/frameCount
overheadThresh
end
recCount
intactCount
mean(degrees)
nBins=frameCount+1
%h=histogram(degrees,nBins,'Normalization','probability','DisplayStyle','stairs');
%hold on
%plot(dist)
%hold off

