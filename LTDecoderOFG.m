function [decodedPackets,decoded,G] = LTDecoderGE(newPackets,newPacketDetails,newPacketCount,K, origG, origDecoded)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
G=origG;
indices=indexRecover(newPacketDetails,K,newPacketCount);
decodedPackets=origDecoded;

index=1;
while(index<newPacketCount)
    tempG=G;
    tempDecoded=decodedPackets;
    b_i=indices(index,:);
    LT_i=newPackets(index,:);
    deg=sum(b_i);
    s_i=find(b_i);
    s_i=s_i(1);
    if(sum(G(s_i,:))==0)
        G(s_i,:)=b_i;
        decodedPackets(s_i,:)=LT_i;
        index=index+1;
        continue;
    end
    if(sum(G(s_i,:))<deg)
        indices(index,:)=bitxor(indices(index,:),tempG(s_i,:));
        newPackets(index,:)= bitxor(newPackets(index,:),tempDecoded(s_i,:));
        continue;
    end
    if(sum(G(s_i,:))==deg)
        index=index+1
        continue
    end
    pos=find(G(s_i,:));
    full=pos(1)==s_i;
    if(sum(G(s_i,:))>deg&&full)
        G(s_i,:)=b_i;
        decodedPackets(s_i,:)=LT_i;
        indices(index,:)=tempG(s_i,:);
        newPackets(index,:)= tempDecoded(s_i,:);
        continue;
    end

end
solvable=diag(G==K);

if(solvable)

end

