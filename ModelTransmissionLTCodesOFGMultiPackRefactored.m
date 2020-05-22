clear all;
clc;
delta=0.01;
c=0.1;
beamSize=300;% default=w_ST = 200; 
payloadSize=1000;
packetCount=1000;
overheadThresh=1000;
packetsPerIteration=packetCount/5;
        rng('shuffle');
%packetSize;
%rng(packetCount);
bitCount=payloadSize*packetCount;
transmitFreq=1e5;
samplesPerClock=2;
samplingFreq=transmitFreq*4*samplesPerClock;
upSampleFreq=samplingFreq*3;
LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
LFSRPoly=[15 14 0];
payloadStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
packets=reshape(payloadStream,payloadSize,[]).';
[dist,~]=RobustSoliton(packetCount,delta,c);

% indices
% [LTPacket,indices,seedUsed]=LTCoder(packets,dist);
% sum(LTPacket)
%  for count =1:length(indices)
%  LTPacket=bitxor(LTPacket,packets(indices(count),:));
% end
%  sum(LTPacket)
 
test=packets(1,:).';
sum(test-payloadStream(1:1000));
size(packets)
CRCLength=32;
degreeBits=16;
KBits=16;
seedBits=16;
LTHeaderLength=degreeBits+KBits+seedBits; %16 bits for K, 16 bits for degree and 8 bits for seed
poly = [32,26,23,22,16,12,11,10,8,7,5,4,2,1,0];
crcGen1 = comm.CRCGenerator(...
    'Polynomial', poly, ...
    'InitialConditions', 1, ...
    'DirectMethod', true, ...
    'FinalXOR', 1);
frameSize=payloadSize+CRCLength+LTHeaderLength;

frames=zeros(packetCount,frameSize);
bitStream=reshape(frames.',[],1);
bitCount=length(bitStream);
%waveFormTXTemp=OOK(bitStream,transmitFreq,samplingFreq);
overThresh=false;
 %turbulence=turbulenceModelTime(samplingFreq,length(waveFormTXTemp), upSampleFreq, false,overheadThresh,beamSize);
 SNRS=(2:8)*2;
BERS=zeros(6,length(SNRS));
Errors=zeros(2,length(SNRS),length(bitStream));
thresholds=BERS;
types=[ 0 0 1 0 0 1;...
    0 1 0 0 1 0];
resBins=zeros(6,bitCount);
intactCount=BERS;
Erasures=BERS;
OrigFrames=reshape(bitStream,floor(frameSize),[]).';
maxErrors=zeros(size(BERS));
ErrorCount=maxErrors;
packetErrors=zeros(6,length(SNRS),packetCount);
CRCDetect=packetErrors;
crcDetect1=comm.CRCDetector(...
    'Polynomial', poly, ...
    'InitialConditions', 1, ...
    'DirectMethod', true, ...
    'FinalXOR', 1);
rates=BERS+1/overheadThresh;
recCountA=BERS;
minDeg=BERS;
decodedCheck=recCountA;
decodedableCount=recCountA;
BERS=BERS+1;
frames=zeros(packetsPerIteration,frameSize);
configs=[6];% choose which configs to test.
for index0=1:length(configs)
    count=configs(index0)
    for index =1:length(SNRS)
        index
        %loopTurbulence=turbulence;
        recCount=0;
        recIndex=1;
       decodedPackets=zeros(size(packets));
        decodedPacketCheck=zeros(packetCount,1);
        decoded=false;    
        overThresh=false;
rng('shuffle')
G=zeros(packetCount);
        while (~decoded&&~overThresh)
            for packCount=1:packetsPerIteration
                recCount=recCount+1;
                [packetLT,degree,RNGSeed]=LTCoder(packets,dist,seedBits);
                degreeBin=de2bi(degree,degreeBits,'left-msb');
                KBin=de2bi(packetCount,KBits,'left-msb');
                seedBin=de2bi(RNGSeed,seedBits,'left-msb');
                degBitsIndex=payloadSize+1;
                KBitsIndex=degBitsIndex+degreeBits;
                seedBitsIndex=KBitsIndex+KBits;
                payload=[packetLT degreeBin KBin seedBin];
                frames(packCount,:)=crcGen1(payload.'); 
            end
            waveFormTX=OOK(reshape(frames.',[],1),transmitFreq,samplingFreq);
            waveFormRX=2*waveFormTX.';
            waveFormRXA=awgn(waveFormRX,SNRS(index)); 
            if(count>4)
                loopTurbulence=turbulenceModelTime(samplingFreq,length(waveFormRXA), upSampleFreq, false,1,beamSize);
                waveFormRXA=waveFormRXA.*loopTurbulence(1:length(waveFormRXA));
            end
            [resBin,thresholds(count,index)]=clockRecoveryFrame(waveFormRXA,transmitFreq,samplingFreq,true, types(1,count), frameSize, types(2,count));
             %[ErrorCount(count,index),BERS(count,index),Errors(count,index,:)]=biterr(resBin,bitStream);
            framesRX=reshape(resBin,frameSize,[]).';
            intact=false;
            newPackets=zeros(packetsPerIteration,payloadSize);
            newPacketDetails=zeros(packetsPerIteration,2);
            loopRecCount=0;
            for packCount=1:packetsPerIteration
                [payloadRX,CRCDetectFrame]=crcDetect1(framesRX(packCount,:).');
                if(~CRCDetectFrame)
                    loopRecCount=loopRecCount+1;
                    newPackets(loopRecCount,:)=payloadRX(1:payloadSize).';
                    degRBits=payloadRX(degBitsIndex:degBitsIndex+degreeBits-1).';
                    KRBits=payloadRX(KBitsIndex:KBitsIndex+KBits-1).';
                    seedRBits=payloadRX(seedBitsIndex:seedBitsIndex+seedBits-1).';
                    degreeDe=bi2de(degRBits,'left-msb');
                    KDe=bi2de(KRBits,'left-msb');
                    seedDe=bi2de(seedRBits,'left-msb');
                    recCountA(count,index)=recCountA(count,index)+1;
                    newPacketDetails(loopRecCount,:)=[degreeDe,seedDe];
                    intact=true;
                    recIndex=recIndex+1;
                end
            end
            if(intact)
                [decodedPackets,decoded,G]=LTDecoderOFG(newPackets(1:loopRecCount,:),newPacketDetails(1:loopRecCount,:),loopRecCount,KDe,G,decodedPackets);
            end
            overThresh=recCount>=packetCount*overheadThresh;
        end
        decodedCheck(count,index)=decoded;
        if(decoded)
            rates(count,index)=packetCount/recCount;
            [~,BERS(count,index)]=biterr(decodedPackets,packets);
        else
            GCount=sum(diag(G))
        end
    end
end
overHeads=(rates(configs,:));
for count=1:length(overHeads)
overHeads(count)=(1/overHeads(count))-1;
end
overHeads
recCountAC=recCountA(configs,:)
decodedCheckC=decodedCheck(configs,:)
BERSC=BERS(configs,:)
legendStrings=cell(size(rates,1),1);
semilogy(SNRS,rates(1,:), '-*');
hold on

legendStrings{1}=['AWGN Mean threshold'];
%intactCount
semilogy(SNRS,rates(2,:), '-*');
legendStrings{2}=['AWGN 0.5 threshold'];
semilogy(SNRS,rates(3,:), '-*');
legendStrings{3}=['AWGN Mean threshold on frames'];
semilogy(SNRS,rates(4,:), '-*');
legendStrings{4}=['AWGN + Turbulence Mean threshold'];


semilogy(SNRS,rates(5,:), '-*');
legendStrings{5}=['AWGN + Turbulence 0.5 threshold'];
    
semilogy(SNRS,rates(6,:), '-*');
legendStrings{6}=['AWGN + Turbulence Mean threshold on frames'];

grid
ylabel('rates');
xlabel('SNR(dB)');
legend(legendStrings);
hold off;
