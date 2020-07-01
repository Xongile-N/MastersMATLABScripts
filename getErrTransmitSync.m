values=real(out.Signal.data).';
frequency=10000;
masterClock=100000000;
decimFactor=10;
sampleRate=masterClock/decimFactor;
twoSec=2*sampleRate+1;
valuesSim=values(1:end);
plotLower=100000000;
plotUpper=plotLower+10000000;
valuesSim=valuesSim(twoSec:end);
%pos=find(valuesSim>upper);
%valuesSim(pos)=upper;

clc
train=false;
frameCount=100-train;%
payloadSize=1000;
gold=[1,1,0,1,0,1,0,0,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1,1,0,0,1,0,1,0,0];
goldAutoCorr=31;

goldLength=length(gold);
%bitCount=frameCount*payloadSize;

frameLength=payloadSize;
bitCount=frameCount*payloadSize+goldLength;
LFSRSeed=100;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=184;%[1 0 1 1 1 0 0 0 ];
packetStream=LFSRGaloisSyncHeader(LFSRSeed,LFSRPoly,bitCount,gold,payloadSize);
% LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
% LFSRPoly=[15 14 0];
% payloadStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
% packets=reshape(payloadStream,payloadSize,[]).';
% packetsHeader=zeros(frameCount,frameLength);
% for count=1:frameCount
% packetsHeader(count,:)=[gold packets(count,:)];
% end
% packetsHeader(1,:);
% tempTranspose=packetsHeader.';
%packetStream=tempTranspose(1:end);
useFrames=false;
useBaseThresh=false;
usePerfSquare=false;
resBin=clockRecoveryFrame(valuesSim,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh).';
% headers=headerIndices(gold,resBin,  goldAutoCorr-3,goldAutoCorr);
% headersCleaned=cleanHeaders(headers,goldLength);
% headersCleaned=headersCleaned(:,1);
% (headersCleaned-headersCleaned(1))/frameLength;
trueHeaders=headerIndices(gold,packetStream,  goldAutoCorr-1,goldAutoCorr);%get header positions of
trueHeadersCleaned=cleanHeaders(trueHeaders,goldLength);
trueHeadersCleaned=trueHeadersCleaned(:,1);
headersCleaned=[1;2;3;4];
[BERS,avgBER,errSeq]=BER_packets_HRSync(headersCleaned,resBin.',packetStream);
[gaps,EFR,gapsCumul,unscaledGaps]=runLengthDisitrbution(errSeq);