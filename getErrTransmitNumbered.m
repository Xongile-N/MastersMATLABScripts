values=real(out.Signal.data).';
frequency=2500;
masterClock=100000000;
decimFactor=10;
sampleRate=masterClock/decimFactor;
twoSec=2*sampleRate+1;
valuesSim=values(1:end);
plotLower=100000000;
plotUpper=plotLower+10000000;
valuesSim=valuesSim(twoSec:end);
pos=find(valuesSim>upper);
valuesSim(pos)=upper;

clc
frameCount=100;
payloadSize=1000;
gold=[1,1,0,1,0,1,0,0,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1,1,0,0,1,0,1,0,0];
goldAutoCorr=31;

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
tempTranspose=packetsHeader.';
packetStream=tempTranspose(1:end);
resBin=clockRecoveryFrame(valuesSim,frequency,sampleRate,false,false,frameLength,false).';
headers=headerIndices(gold,resBin,  goldAutoCorr-1,goldAutoCorr);
headersCleaned=cleanHeaders(headers,goldLength);
headersCleaned=headersCleaned(:,1);
(headersCleaned-headersCleaned(1))/frameLength;
trueHeaders=headerIndices(gold,resBin,  goldAutoCorr-1,goldAutoCorr);
trueHeadersCleaned=cleanHeaders(trueHeaders,goldLength);
trueHeadersCleaned=trueHeadersCleaned(:,1);
headersCleaned=[headersCleaned(1)-frameLength; headersCleaned];
[BERS,avgBER,skipped]=BER_packets_NR(headersCleaned,resBin,trueHeadersCleaned,packetStream,frameLength);