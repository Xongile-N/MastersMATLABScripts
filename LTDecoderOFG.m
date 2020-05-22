function [decodedPackets,decoded,G] = LTDecoderOFG(newPackets,newPacketDetails,newPacketCount,K, G, decodedPackets)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    indices=indexRecover(newPacketDetails,K,newPacketCount);

    [G,decodedPackets]=populateG(G,decodedPackets,indices,newPackets);
    
    sum(diag(G))
    solvable=sum(diag(G))==K;
    decoded=false;
    if(solvable)
        [G,decodedPackets]=backSubstitution(G,decodedPackets);
        decoded=true;
    end
end

