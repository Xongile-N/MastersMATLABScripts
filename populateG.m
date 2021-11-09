function [G,B] = populateG(G,B,indices,newPackets)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here]
    index=1;
    newPacketsOrig=newPackets;
newPacketCount=size(newPackets,1);
    while(index<newPacketCount+1)
        tempG=G;
        tempDecoded=B;
        b_i=indices(index,:);
        LT_i=newPackets(index,:);
        deg=sum(b_i);
        if(deg==0)
            index=index+1;
            continue
        end
        s_i=find(b_i);
        s_i=s_i(1);
        if(sum(G(s_i,:))==0)
            G(s_i,:)=b_i;
            B(s_i,:)=LT_i;
            index=index+1;
            continue;
        end
        if(sum(G(s_i,:))<=deg)
            indices(index,:)=bitxor(indices(index,:),tempG(s_i,:));
            newPackets(index,:)= bitxor(newPackets(index,:),tempDecoded(s_i,:));
            continue;
        end
        pos=find(G(s_i,:));
        full=pos(1)==s_i;
        if(sum(G(s_i,:))>deg&&full)
            G(s_i,:)=b_i;
            B(s_i,:)=LT_i;
            indices(index,:)=tempG(s_i,:);
            newPackets(index,:)= tempDecoded(s_i,:);
            continue;
        end

    end
end

