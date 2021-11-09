function costs= FritchmanRSCostBPDist(setChoice,dist,K,overheadThresh)

disp("started")

addpath '..\..\data'
%delta=RSParam(1);
%c=RSParam(2);
dist=dist/sum(dist).';

 st2 = 4831;
 NBch = 255;
KBch = 87;
NRS = 127;
KRS = 85;
[gp] = bchgenpoly(NBch,KBch);

bchEncoder = comm.BCHEncoder(NBch,KBch,gp);
bchDecoder = comm.BCHDecoder(NBch,KBch,gp);
[gpRS] = rsgenpoly(NRS,KRS,[],0);
useBits=true;
rsEncoder=comm.RSEncoder(NRS,KRS,gpRS,"BitInput", useBits);
rsDecoder=comm.RSDecoder(NRS,KRS,gpRS,"BitInput", useBits);

messageCount=gpRS.m;
payloadSize=messageCount*KBch-80;
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
frameSize=messageCount*NBch/KRS*NRS;

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

receivedPackets=zeros(size(frames,1)*overheadThresh,payloadSize);
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
%dist=RobustSoliton(frameCount,delta,c);    
degrees=[];
intactCount=0;
while (~decoded&&~overThresh)
    raw=[];
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
                raw=[raw crcGen1(payload.')];

        %frames(packCount,:)=crcGen1(payload.'); 
    end
    encodedBch=bchEncoder(raw);
    inter=   randintrlv(encodedBch,st2);

          encoded=rsEncoder(inter);

    errors=errSeqF(startIndex:endIndex).';
    %BERL=mean(errors)
   startIndex=startIndex+packetsPerIteration*frameSize;
      endIndex=endIndex+packetsPerIteration*frameSize;
    rxBits=encoded;
    framesRX=reshape( bitxor( rxBits,errors),frameSize,[]);
    
    decodedBits=rsDecoder(framesRX);
    deinter=randdeintrlv(decodedBits,st2);
    final=bchDecoder(deinter);
    intact=false;
    newPackets=zeros(packetsPerIteration,payloadSize);
    newPacketDetails=zeros(packetsPerIteration,2);
    loopRecCount=0;
    for packCount=1:packetsPerIteration
        [payloadRX,CRCDetectFrame]=crcDetect1(final);
        if(~CRCDetectFrame)
            receivedPackets(recIndex,:)=payloadRX(1:payloadSize).';
            degRBits=payloadRX(degBitsIndex:degBitsIndex+degreeBits-1).';
            KRBits=payloadRX(KBitsIndex:KBitsIndex+KBits-1).';
            seedRBits=payloadRX(seedBitsIndex:seedBitsIndex+seedBits-1).';
            degreeDe=bi2de(degRBits,'left-msb');
            KDe=bi2de(KRBits,'left-msb');
            seedDe=bi2de(seedRBits,'left-msb');
           % recCountA(count,index)=recCountA(count,index)+1;
            receivedPacketDetails(recIndex,:)=[degreeDe,seedDe];
            [decodedPackets,decodedPacketCheck,decoded]=LTDecoderBP(receivedPackets,receivedPacketDetails,recIndex,KDe,decodedPackets,decodedPacketCheck);
            recIndex=recIndex+1;

            %if(degreeDe==1)
            %    decodedableCount(count,index)=1+decodedableCount(count,index);
            %end
        end
    end
    if(intact)
        [decodedPackets,decoded,G]=LTDecoderOFG(newPackets(1:loopRecCount,:),newPacketDetails(1:loopRecCount,:),loopRecCount,KDe,G,decodedPackets);
    end
        overThresh=recCount>=frameCount*overheadThresh;
end

overhead=recCount/frameCount;

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

end

