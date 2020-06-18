% values=real(out.Signal.data).';
% frequency=2500;
% masterClock=100000000;
% decimFactor=10;
% sampleRate=masterClock/decimFactor;
% valuesSim=values(1:end);
% plotLower=100000000;
% plotUpper=plotLower+10000000;
% valuesSim=valuesSim(20000000:end);
%clc
frameCount=100;
payloadSize=1000;
gold=[1,1,0,1,0,1,0,0,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1,1,0,0,1,0,1,0,0];
goldLength=length(gold);
bitCount=frameCount*payloadSize;
frameLength=payloadSize+goldLength;
LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
LFSRPoly=[15 14 0];
payloadStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
packets=reshape(payloadStream,payloadSize,[]).';
packetsHeader=zeros(frameCount,frameLength);
for count=1:frameCount
packetsHeader(count,:)=[gold packets(count,:)];
end
packetsHeader(1,:);
resBin=clockRecoveryFrame(valuesSim,frequency,sampleRate,false,true,frameLength,false);