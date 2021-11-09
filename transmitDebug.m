clc;
errorPackCount=length(find(BERSnf))-1;
errorPackIndices=find(BERSnf);
errorPackIndices=errorPackIndices(1:errorPackCount);
errSeqs=zeros(errorPackCount,length(packetStream));

for count=1:1
errSeqs(count,:)=bitxor(resBin(headersCleaned(errorPackIndices(count)):headersCleaned(errorPackIndices(count))+bitCount-1),packetStream.');
posErr=find(errSeqs(count,:));
end

debugBit=headersCleaned(errorPackIndices(1))+posErr(2);
leeway=3;
expected=packetStream(posErr(2)-leeway:posErr(2)+leeway).'
demodded=resBin(debugBit-leeway:debugBit+leeway)
resBinDebug=clockRecoveryFrameDebug(valuesSim,frequency,sampleRate,usePerfSquare,useFrames,frameLength,useBaseThresh,debugBit,leeway).';

