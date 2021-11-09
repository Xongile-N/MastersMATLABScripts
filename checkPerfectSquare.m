clc
values=real(out.data).';
frequency=10000;
masterClock=100000000;
decimFactor=100;
sampleRate=masterClock/decimFactor;
start=2*sampleRate+1;
valuesSim=values(1:end);
plotLower=100000000;
plotUpper=plotLower+10000000;
valuesSim=valuesSim(start:end);
frameLength=1000;

useFrames=false;
useLargeFrame=true;
useBaseThresh=false;
usePerfSquare=false;
resBin=clockRecoveryFrame(valuesSim,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh).';
onePos=find(resBin);
test=resBin(onePos(2):end);
errSeq=zeros(size(test));
for count=1:length(test)
errSeq(count)=mod(test(count)+count,2);
end
pos=find(errSeq);
%pos(1:10)
%test(pos(1)-3:pos(1)+3)
if(~isempty(pos))
    debugBit=pos(1)+onePos(1)-1;
leeway=3;
    resBinDebug=clockRecoveryFrameDebug(valuesSim,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,debugBit,leeway,1000000000).';

end

