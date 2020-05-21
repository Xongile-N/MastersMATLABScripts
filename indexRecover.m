function indices = indexRecover(details,K,indexCount)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
indices=zeros(indexCount,K);
for count=1:newPacketCount
    rng(details(count,2));
    loopDeg=details(count,1);
    loopIndices=randi(K,loopDeg,1);
    for index=1:loopDeg
        indices(count,loopIndices(index))=bitxor(  indices(count,loopIndices(index)),1);
    end
end

