function indicesCorr = headerIndices(header,data,thresh,perfThresh)
headerBi=header*2-1;
dataBi=data*2-1;
dataLength=length(data);
headerLength=length(header);
indices=[];
corrs=[];
count=1;
while count<dataLength-headerLength
    sample=dataBi(count:count+headerLength-1);
    corr=xcorr(sample,headerBi);
    corrMax=ceil(max(corr));
    if(corrMax>=thresh)
        indices(end+1)=count;
        corrs(end+1)=corrMax;
        if(corrMax>=perfThresh)
            count=count+headerLength-2;
        end
    end
    count=count+1;
end
indicesCorr=[indices;corrs].';

