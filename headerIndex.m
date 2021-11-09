function headerIndex = headerIndices(header,data,thresh,perfThresh)
%function to retrieve the indices of headers in a binary stream
headerBi=header*2-1;
dataBi=data*2-1;
dataLength=length(data);
headerLength=length(header);
index=1;
corrFinal=0;
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
    
    if(corrMax>corrFinal)
        index=count;
        corrFinal=corrMax;
        if(corrMax>=perfThresh)
            count=dataLength-headerLength-1;
        end
    end
    count=count+1;
end
headerIndex=[index;corrFinal].';

