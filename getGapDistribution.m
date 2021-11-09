function [dist,cumul,P01,diff,unscaled] = getGapDistribution(errorSequence)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    pos=find(errorSequence);

    pos=[pos; length(errorSequence)+1];
    diff=0;
    diffPos=1;
    diffPos2=1;
    for posI=1:length(pos)-1
        if((pos(posI+1)-pos(posI))>diff)
            diff=pos(posI+1)-pos(posI);
            diffPos=pos(posI);
            diffPos2=pos(posI+1);

        end
    end
    dist=zeros(diff,1);
    for posI=1:length(pos)-1
        gapLength=(pos(posI+1)-pos(posI));
        dist(gapLength)=dist(gapLength)+1;
    end
    P01=sum(dist)/sum(errorSequence);
    unscaled=dist;
    dist=dist/sum(dist);
    %sum(errSeq(diffPos:diffPos2))
    cumul=cumsum(dist);
    
end

