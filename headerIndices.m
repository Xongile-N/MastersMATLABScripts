function indicesCorr = headerIndices(header,data,thresh,perfThresh)
%function to retrieve the indices of headers in a binary stream
headerBi=header*2-1;
dataBi=data*2-1;
dataLength=length(data);
headerLength=length(header);
indices=[];
corrs=[];
count=1;
maximum=0;
maximumPos=1;
while count<dataLength-headerLength
    sample=dataBi(count:count+headerLength-1);
    corr=xcorr(sample,headerBi);
    corrMax=ceil(max(corr));
    if(corrMax>maximum)
        maximum=corrMax;
        maximumPos=count;
    end
    
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
maximum
maximumPos

