clear all
clc
K=4;
origPackets=[1 1 0 1];
decodedPackets=zeros(4,1);
packets=[1 ;1;0;1;1;0];
indicesOrig=[1 0 0 0; 0 1 1 0; 0 1 0 1; 0 0 1 1; 1 1 1 0; 1 0 0 1]
decoded=false;
G=zeros(4);
for packCount=1:length(packets)
    indices=indicesOrig(packCount,:)
    newPackets=packets(packCount);
    [G,decodedPackets]=populateG(G,decodedPackets,indices,newPackets);
    G
    solvable=sum(diag(G))==K;
    decoded=false;
    if(solvable)
        [G,decodedPackets]=backSubstitution(G,decodedPackets);
        decoded=true;
    end
end
decoded
decodedPackets
decodedPacketsBool=zeros(K,1);
decodedPacketsOrigBool=zeros(K,1);

decoded=false;
decodedPackets=zeros(4,1);
receivedPacketDetails=zeros(6,1);
decodedPacketsOrig=decodedPackets;
for packCount=1:length(packets)
        indices=indicesOrig(1:packCount,:);
            receivedPacketDetails(packCount)=sum(indices(packCount,:));

  [decodedPackets,decodedPacketsBool] = LTDecoderBPMain(packets(1:packCount,:),receivedPacketDetails(1:packCount,:),packCount,K,decodedPacketsOrig,decodedPacketsOrigBool,indices);
  decodedPackets
  decodedPacketsBool  
  decoded=isempty(find(decodedPacketsBool==0)); 
end

