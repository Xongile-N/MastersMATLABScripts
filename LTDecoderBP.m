function [decodedPackets,decodedPacketsBool,decoded] = LTDecoderBP(receivedPackets,receivedPacketDetails,receivedPacketCount,totalPackets,decodedPacketsOrig,decodedPacketsOrigBool)
decoded=false;
decodedPackets=decodedPacketsOrig;
decodedPacketsBool=decodedPacketsOrigBool;
if(isempty(find(receivedPacketDetails(:,1)==1)))
    return
end
indices=zeros(receivedPacketCount,totalPackets);
for count=1:receivedPacketCount
 rng(receivedPacketDetails(count,2));
 loopDeg=receivedPacketDetails(count,1);
 loopIndices=randi(totalPackets,loopDeg,1);
 indices(count,loopIndices)=1;
end
[decodedPackets,decodedPacketsBool] = LTDecoderBPMain(receivedPackets,receivedPacketDetails,receivedPacketCount,totalPackets,decodedPacketsOrig,decodedPacketsOrigBool,indices);
decoded=isempty(find(decodedPacketsBool==0));

end

