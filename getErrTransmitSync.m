simValues=real(values.data).';
frequency=20000;
masterClock=100000000;
decimFactor=100;
sampleRate=masterClock/decimFactor;
start=0*sampleRate+1;
valuesSim=simValues(1:end);
plotLower=100000000;
plotUpper=plotLower+10000000;
valuesSim=valuesSim(start:end);
%pos=find(valuesSim>upper);
%valuesSim(pos)=upper;

clc
train=false;
frameCount=50-train;%
payloadSize=1000;
gold=[1,1,0,1,0,1,0,0,1,1,1,0,0,0,1,1,0,1,0,1,0,1,1,1,0,0,1,0,1,0,0];
goldAutoCorr=31;

goldLength=length(gold);
%bitCount=frameCount*payloadSize;

frameLength=payloadSize;
bitCount=frameCount*payloadSize+goldLength;
LFSRSeed=10000;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=53256;%[1 0 1 1 1 0 0 0 ];
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
useLargeFrame=true;
useBaseThresh=false;
usePerfSquare=false;
[resBin,thresh,bitPos,sampler]=clockRecoveryFrame(valuesSim,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh);
resBin=resBin.';
%resBin=clockRecoveryFrameLarge(valuesSim,frequency,sampleRate,usePerfSquare,useLargeFrame,bitCount,useBaseThresh).';
headers=headerIndices(gold,resBin,  goldAutoCorr-4,goldAutoCorr);
headersCleaned=cleanHeaders(headers,goldLength);
headersCleaned=headersCleaned(:,1);
trueHeaders=headerIndices(gold,packetStream,  goldAutoCorr-1,goldAutoCorr);%get header positions of
trueHeadersCleaned=cleanHeaders(trueHeaders,goldLength);
trueHeadersCleaned=trueHeadersCleaned(:,1);
[BERSnf,avgBERnf,errSeqnf]=BER_packets_HRSyncNF(headersCleaned,resBin.',packetStream);
%[BERS,avgBER,errSeq]=BER_packets_HRSync(headersCleaned,resBin.',packetStream);

%[gaps,EFR,gapsCumul,unscaledGaps]=runLengthDisitrbution(errSeq);