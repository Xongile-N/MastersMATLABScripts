function [dist,cumul,P01,diff] = getGapDistribution(errorSequence)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    pos=find(errorSequence);
    posSort=sort(pos);
    diff=0;
    diffPos=1;
    diffPos2=1;
    for posI=1:length(posSort)-1
        if((posSort(posI+1)-posSort(posI))>diff)
            diff=posSort(posI+1)-posSort(posI);
            diffPos=posSort(posI);
            diffPos2=posSort(posI+1);

        end
    end
    dist=zeros(diff,1);
    for posI=1:length(posSort)-1
        gapLength=(posSort(posI+1)-posSort(posI));
        dist(gapLength)=dist(gapLength)+1;
    end
    P01=sum(dist)/sum(errorSequence);
    dist=dist/sum(dist);
    %sum(errSeq(diffPos:diffPos2))
    cumul=cumsum(dist);
end

