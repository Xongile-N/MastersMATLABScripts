function cleaned = cleanHeaders(headerIndices, headerLength)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
cleanedHeaders=[];
cleanedCorr=[];
for count=1:size(headerIndices,1)
    index=headerIndices(count,1);
    corr=headerIndices(count,2);
    diff=abs(headerIndices(:,1)-index);
    matchingCorrsIndex=find(diff<headerLength);
    matchingCorrs=headerIndices(matchingCorrsIndex,2);
    if corr==max(matchingCorrs)
        cleanedHeaders(end+1)=index;
        cleanedCorr(end+1)=corr;
    end
end
cleaned=[cleanedHeaders;cleanedCorr].';
end

