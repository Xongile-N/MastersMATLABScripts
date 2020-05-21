function [decodedPackets,decoded] = LTDecoderGE(receivedPackets,receivedPacketDetails,receivedCount,K)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if(receivedCount<K)
 return;
end
indices=zeros(receivedPacketCount,K);
for count=1:receivedPacketCount
 rng(receivedPacketDetails(count,2));
 loopDeg=receivedPacketDetails(count,1);
 loopIndices=randi(totalPackets,loopDeg,1);
 for index=1:loopDeg
    indices(count,loopIndices(index))=bitxor(  indices(count,loopIndices(index)),1);
 end
end
EqMatrixLeft=indices;
EqMatrixRight=receivedPackets;
solvable=false;
if(solvable)

end

end

