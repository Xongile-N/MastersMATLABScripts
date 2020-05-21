function [LTPackets,packets,decodedPackets,decodedPacketsBool,indices] = genTestPackets
    clear all;
    packets=[ 1 0 1 0 1 1 1; 1 1 0 0 1 1 0; 0 0 1 0 1 0 1];
    indices=zeros(3);
    indices(1,:)=[ 1 1 1];
    indices(2,:)=[ 1 0 1];
    indices(3,:)=[ 0 0 1];
    LTPackets=indices*packets;
    LTPackets=mod(LTPackets,2);
    decodedPackets=zeros(size(packets));
    decodedPacketsBool=[0 0 0];
end

