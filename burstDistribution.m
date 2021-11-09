function dist = burstDistribution(errSeq,BERThresh)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
dist=zeros(size(errSeq));
burstLength=0;
finished=false;
index=1;
while(~finished)
    seq=errSeq(index-burstLength:index);
    currBer=mean(seq);
    if(index==length(errSeq))
        finished=true;
                pos=find(seq);
        if(length(pos)>1)
            dist(pos(end))=dist(pos(end))+1;
                    burstLength=0;
        else
                    burstLength=burstLength+1;

        end
    elseif(burstLength==0)
        burstLength=errSeq(index);
    elseif(currBer>=BERThresh)
        burstLength=burstLength+1;
    else
        pos=find(seq);
        if(length(pos)>1)
            dist(pos(end))=dist(pos(end))+1;
                    burstLength=0;
        else
                    burstLength=burstLength+1;

        end
    end
    index=index+1;
end
trimPos=find(dist);
if(trimPos(end)~=length(dist))
    dist(trimPos(end)+1:end)=[];
end
%unscaled=dist;
dist=dist./sum(dist);
end

