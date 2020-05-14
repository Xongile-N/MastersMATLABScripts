function [decodedPackets,decodePacketsBool,decoded] = LTDecoderBP(receivedPackets,receivedPacketDetails,receivedPacketCount,totalPackets,decodePacketsOrig,decodePacketsOrigBool)
decoded=false;
decodedPackets=decodePacketsOrig;
decodePacketsBool=decodePacketsOrigBool;
if(isempty(find(receivedPacketDetails(:,1)==1)))
    return
end
indices=zeros(receivedPacketCount,totalPackets)
for count=1:receivedPacketCount
 rng(receivedPacketDetails(count,2))
 loopDeg=receivedPacketDetails(count,1)
 loopIndices=randi(totalPackets,loopDeg,1)
 indices(count,loopIndices)=1;
end
[decodedPackets,decodePacketsBool] = LTDecoderBPMain(receivedPackets,receivedPacketDetails,receivedPacketCount,totalPackets,decodePacketsOrig,decodePacketsOrigBool,indices);
decoded=isempty(find(decodedPacketsBool==0))

end

