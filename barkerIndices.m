function indices = barkerIndices(barker,data,thresh)
barkerBi=barker*2-1;
dataBi=data*2-1;
dataLength=length(data);
barkerLength=length(barker);
indices=[];
for count=1:dataLength-barkerLength
    sample=dataBi(count:count+barkerLength-1);
    corr=xcorr(sample,barkerBi);
    corrMax=max(corr);
    if(corrMax>=thresh)
        indices(end+1)=count;
    end
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

end

