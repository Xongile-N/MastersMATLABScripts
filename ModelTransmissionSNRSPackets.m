clear all;
clc
payloadSize=1000;
packetCount=500;
overheadThresh=100;
%packetSize;
bitCount=1000000;
%rng('default');
bitCount=payloadSize*packetCount;
transmitFreq=1e5;
samplesPerClock=4;
samplingFreq=transmitFreq*4*samplesPerClock;
upSampleFreq=samplingFreq*3;
LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
LFSRPoly=[15 14 0];
payloadStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
packets=reshape(payloadStream,payloadSize,[]).';
[dist,cumulative]=RobustSoliton(packetCount,0.5,0.1);
receivedPackets=zeros(size(packets,1)*overheadThresh,size(packets,2));
receivedPacketDetails=zeros(size(receivedPackets,1),2)-1;%stores the current degree and the seed used. In that order
decodedPackets=zeros(size(packets));
decodePacketCheck=zeros(packetCount,1);
decoded=false
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
poly = [32,26,23,22,16,12,11,10,8,7,5,4,2,1,0];
crcGen1 = comm.CRCGenerator(...
    'Polynomial', poly, ...
    'InitialConditions', 1, ...
    'DirectMethod', true, ...
    'FinalXOR', 1);
frameSize=payloadSize+CRCLength;

frames=zeros(packetCount,frameSize);
 for count=1:packetCount
     frames(count,:)=crcGen1(packets(count,:).');    
 end
bitStream=reshape(frames.',[],1);
waveFormTX=OOK(bitStream,transmitFreq,samplingFreq);
%axis([0 length(waveFormTX)+10 -0.5 1.5]);
%[resBin,~,~]=clockRecovery(waveFormTX,transmitFreq,samplingFreq,true,true,0.05);
bitCount=length(bitStream);

 turbulence=turbulenceModel(samplingFreq,length(waveFormTX), upSampleFreq, false);
 SNRS=(1:16);
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
for count=1:6
    count
    if(count<4)
        waveFormRX=2*waveFormTX.';
    else
        waveFormRX=2*(waveFormTX.').*turbulence;
    end
    
    for index =1:length(SNRS)
     waveFormRXA=awgn(waveFormRX,SNRS(index)); 
    [resBin,thresholds(count,index)]=clockRecoveryFrame(waveFormRXA,transmitFreq,samplingFreq,true, types(1,count), frameSize, types(2,count));
     [ErrorCount(count,index),BERS(count,index),Errors(count,index,:)]=biterr(resBin,bitStream);
     framesRX=reshape(resBin,frameSize,[]).';
     errorCounts=biterr(framesRX,OrigFrames,[],'row-wise');
     packetErrors(count,index,:)=errorCounts;
     for CRCIndex=1:packetCount
          [~,CRCDetect(count,index,CRCIndex)]=crcDetect1(framesRX(CRCIndex,:).');
     end
     intactCount(count,index)=packetCount-sum(CRCDetect(count,index,:));
          Erasures(count,index)=sum(CRCDetect(count,index,:));

     maxErrors(count,index)=max(errorCounts);
     resBins(count,:)=resBin;
    end
end

maxErrors
ErrorCount
BERS
CRCDetect(1,:,:);
legendStrings=cell(size(BERS,1),1);
intactCount
Erasures
semilogy(SNRS,BERS(1,:), '-*');
hold on

legendStrings{1}=['AWGN Mean threshold'];
intactCount
semilogy(SNRS,BERS(2,:), '-*');
legendStrings{2}=['AWGN 0.5 threshold'];
semilogy(SNRS,BERS(3,:), '-*');
legendStrings{3}=['AWGN Mean threshold on frames'];
semilogy(SNRS,BERS(4,:), '-*');
legendStrings{4}=['AWGN + Turbulence Mean threshold'];


semilogy(SNRS,BERS(5,:), '-*');
legendStrings{5}=['AWGN + Turbulence 0.5 threshold'];
    
semilogy(SNRS,BERS(6,:), '-*');
legendStrings{6}=['AWGN + Turbulence Mean threshold on frames'];

grid
ylabel('BER');
xlabel('SNR(dB)');
legend(legendStrings);
hold off;
