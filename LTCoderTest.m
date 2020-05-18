clear all;
clc
payloadSize=1000;
packetCount=50;
bitCount=payloadSize*packetCount;
LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
LFSRPoly=[15 14 0];
payloadStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
packets=reshape(payloadStream,payloadSize,[]).';
[dist,cumulative]=RobustSoliton(packetCount,0.5,0.1);

iterCount=5;
degrees=zeros(iterCount,1);
degreeBitLen=16;
degreeBits=zeros(iterCount,16);
degreesR=zeros(iterCount,1);
rng('default');
for count =1:iterCount

    [~,degrees(count),~]=LTCoder(packets,dist);
    degreeBits(count,:)=de2bi(degrees(count),degreeBitLen,'left-msb');
    degreesR(count)=bi2de(degreeBits(count,:),'left-msb');
end
sum(degrees- degreesR)
min(degrees)