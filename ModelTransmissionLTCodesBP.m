giclear all;
clc;

payloadSize=1000;
packetCount=1000;
overheadThresh=10;
packetsPerIteration=10;
        rng('shuffle');
%packetSize;
%rng(packetCount);
bitCount=payloadSize*packetCount;
transmitFreq=1e5;
samplesPerClock=3;
samplingFreq=transmitFreq*4*samplesPerClock;
upSampleFreq=samplingFreq*3;
LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
LFSRPoly=[15 14 0];
payloadStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
packets=reshape(payloadStream,payloadSize,[]).';
[dist,~]=RobustSoliton(packetCount,0.5,0.1);

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
waveFormTXTemp=OOK(bitStream,transmitFreq,samplingFreq);
overThresh=false;
 turbulence=turbulenceModelTime(samplingFreq,length(waveFormTXTemp), upSampleFreq, false,overheadThresh);
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
decodedCount=recCountA;
decodedableCount=recCountA;
BERS=BERS+1;
configs=[3 4 6];% choose which configs to test.
for index0=1:length(configs)
    count=configs(index0)
    for index =1:length(SNRS)
        index
        loopTurbulence=turbulence;
        recCount=0;
        recIndex=1;
        receivedPackets=zeros(size(packets,1)*overheadThresh,size(packets,2));
        receivedPacketDetails=zeros(size(receivedPackets,1),2)-1;%stores the current degree and the seed used. In that order
        decodedPackets=zeros(size(packets));
        decodedPacketCheck=zeros(packetCount,1);
        decoded=false;    
        overThresh=false;
rng('shuffle')

        while (~decoded&&~overThresh)
            recCount=recCount+1;
            [packetLT,degree,RNGSeed]=LTCoder(packets,dist,seedBits);
            degreeBin=de2bi(degree,degreeBits,'left-msb');
            KBin=de2bi(packetCount,KBits,'left-msb');
            seedBin=de2bi(RNGSeed,seedBits,'left-msb');
            degBitsIndex=payloadSize+1;
            KBitsIndex=degBitsIndex+degreeBits;
            seedBitsIndex=KBitsIndex+KBits;
            payload=[packetLT degreeBin KBin seedBin];
            frame=crcGen1(payload.');  
            waveFormTX=OOK(frame,transmitFreq,samplingFreq);
            if(count<4)
                waveFormRX=2*waveFormTX.';
            else
                waveFormRX=2*(waveFormTX.').*loopTurbulence(1:length(waveFormTX));
                loopTurbulence(1:length(waveFormTX))=[];
            end
             waveFormRXA=awgn(waveFormRX,SNRS(index)); 
            [resBin,thresholds(count,index)]=clockRecoveryFrame(waveFormRXA,transmitFreq,samplingFreq,true, types(1,count), frameSize, types(2,count));
             %[ErrorCount(count,index),BERS(count,index),Errors(count,index,:)]=biterr(resBin,bitStream);
             %framesRX=reshape(resBin,frameSize,[]).';
             frameRX=resBin;
             [payloadRX,CRCDetectFrame]=crcDetect1(frameRX);
             if(~CRCDetectFrame)
                 receivedPackets(recIndex,:)=payloadRX(1:payloadSize).';
                 degRBits=payloadRX(degBitsIndex:degBitsIndex+degreeBits-1).';
                 KRBits=payloadRX(KBitsIndex:KBitsIndex+KBits-1).';
                 seedRBits=payloadRX(seedBitsIndex:seedBitsIndex+seedBits-1).';
                 degreeDe=bi2de(degRBits,'left-msb');
                KDe=bi2de(KRBits,'left-msb');
                seedDe=bi2de(seedRBits,'left-msb');
                recCountA(count,index)=recCountA(count,index)+1;
                 receivedPacketDetails(recIndex,:)=[degreeDe,seedDe];
                 [decodedPackets,decodedPacketCheck,decoded]=LTDecoderBP(receivedPackets,receivedPacketDetails,recIndex,KDe,decodedPackets,decodedPacketCheck);
                  recIndex=recIndex+1;

                  if(degreeDe==1)
                  decodedableCount(count,index)=1+decodedableCount(count,index);
                  end
             end
             overThresh=recCount>=packetCount*overheadThresh;
        end
        if(recCountA(count,index)>0)
        minDeg(count,index)=min(receivedPacketDetails(1:recCountA(count,index),1));
        end
        decodedCount(count,index)=sum(decodedPacketCheck);
        if(decoded)
            rates(count,index)=packetCount/recCount;
            [~,BERS(count,index)]=biterr(decodedPackets,packets);
        end
    end
end
ratesC=rates(configs,:)
recCountAC=recCountA(configs,:)
decodedCountC=decodedCount(configs,:)
BERSC=BERS(configs,:)
minDegC=minDeg(configs,:)
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
