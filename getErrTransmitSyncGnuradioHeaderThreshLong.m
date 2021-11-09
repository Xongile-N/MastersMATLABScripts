filename = '20200724_Transmit_1441_1Mhz_10Khz_100K.bin';   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end
data = fread(fid, inf, '*float32');
fclose(fid);
valuesSim=data;
frequency=2000;
masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;
start=0*sampleRate+1;
plotLower=100000000;
plotUpper=plotLower+10000000;
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
thresh=0.15;
[resBin,thresh,bitPos,sampler]=clockRecoveryFrame(valuesSim,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,thresh);
resBin=resBin.';
headers=headerIndices(gold,resBin,  goldAutoCorr-2,goldAutoCorr);
headersCleaned=cleanHeaders(headers,goldLength);
headersCleaned=headersCleaned(:,1);

trueHeaders=headerIndices(gold,packetStream,  goldAutoCorr-1,goldAutoCorr);%get header positions of
trueHeadersCleaned=cleanHeaders(trueHeaders,goldLength);
trueHeadersCleaned=trueHeadersCleaned(:,1);
[BERSnf,avgBERnf,errSeqnf]=BER_packets_HRSyncNF(headersCleaned,resBin.',packetStream);

firstHeader=[bitPos(headersCleaned(1)-1)+1 bitPos(headersCleaned(1)+goldLength-1)]

useFrames=false;
useLargeFrame=true;
useBaseThresh=true;
usePerfSquare=false;
threshH= mean(valuesSim(firstHeader(1):firstHeader(2)));
[resBinH,threshH,bitPosH,samplerH]=clockRecoveryFrame(valuesSim,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,threshH);
resBinH=resBinH.';
headersH=headerIndices(gold,resBinH,  goldAutoCorr-2,goldAutoCorr);
headersCleanedH=cleanHeaders(headersH,goldLength);
headersCleanedH=headersCleanedH(:,1);

trueHeaders=headerIndices(gold,packetStream,  goldAutoCorr-1,goldAutoCorr);%get header positions of
trueHeadersCleaned=cleanHeaders(trueHeaders,goldLength);
trueHeadersCleaned=trueHeadersCleaned(:,1);
[BERSnfH,avgBERnfH,errSeqnfH]=BER_packets_HRSyncNF(headersCleanedH,resBinH.',packetStream);
