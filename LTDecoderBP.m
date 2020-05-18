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
 for index=1:loopDeg
    indices(count,loopIndices(index))=bitxor(  indices(count,loopIndices(index)),1);
 end
 %indices(count,loopIndices)=1;
end
receivedPacketDetails(1:receivedPacketCount,1)=sum(indices,2);
[decodedPackets,decodedPacketsBool] = LTDecoderBPMain(receivedPackets(1:receivedPacketCount,:),receivedPacketDetails(1:receivedPacketCount,:),receivedPacketCount,totalPackets,decodedPacketsOrig,decodedPacketsOrigBool,indices);
decoded=isempty(find(decodedPacketsBool==0));

end

