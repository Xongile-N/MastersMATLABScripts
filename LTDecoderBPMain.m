function [decodedPackets,decodedPacketsBool] = LTDecoderBPMain(receivedPackets,receivedPacketDetails,receivedPacketCount,totalPackets,decodedPacketsOrig,decodedPacketsOrigBool,indices)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
canDecode=true;
origPackets=receivedPackets;
decodedPackets=decodedPacketsOrig;
decodedPacketsBool=decodedPacketsOrigBool;
while canDecode
    for index=1:receivedPacketCount% recover decoded packets
         if(receivedPacketDetails(index,1)~=1)
             continue
         end
         decIndex=find(indices(index,:));% Find the index of the packet that has been recovered
         decodedPackets(decIndex,:)=receivedPackets(index,:);% put decoded packet in the array of decoded packets
         decodedPacketsBool(decIndex)=1;
    end
    index=1;
    while(index<=receivedPacketCount)%removes fully decoded packets
        if(receivedPacketDetails(index,1)~=1)% skip if degree is not one
            index=index+1;
            continue
        end
        receivedPacketCount=receivedPacketCount-1;
        receivedPackets(index,:)=[];%remove completely decoded packet
        receivedPacketDetails(index,:)=[];%remove details of completely decoded packet
        indices(index,:)=[];
    end

    for count=1:totalPackets%use existing recovered packets to decode
        if(~decodedPacketsBool(count))% if this packet is not found yet, continue
            continue
        end

        for index=1:receivedPacketCount % if packet is found, use it on the received packets
            if(~indices(index,count))% if final packet is not part of the paacket at index, continue
                continue
            end
            receivedPackets(index,:)=bitxor(decodedPackets(count,:),receivedPackets(index,:)); % xor packet with endoded apckets that contain it
            indices(index,count)=0;% remove packet index
            receivedPacketDetails(index,1)=receivedPacketDetails(index,1)-1;% decrease degree

        end
    end
    canDecode=(~isempty(find(receivedPacketDetails(:,1)==1)));% check if there are still any packets with degree one. 

end
end

