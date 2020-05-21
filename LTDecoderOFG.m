function [decodedPackets,decoded,G] = LTDecoderGE(newPackets,newPacketDetails,newPacketCount,K, origG, origDecoded)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    G=origG;
    indices=indexRecover(newPacketDetails,K,newPacketCount);
    decodedPackets=origDecoded;

    [G,decoded]=populateG(origG,origDecoded,indices,newPackets);
    solvable=diag(G==K);

    if(solvable)
        [G,decoded]=backSubstitution(G,decoded);
    end
end

