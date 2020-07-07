function [BERS,avgBER,errSeq] = BER_packets_HRSyncNF(headersData,data,trueSeq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
BERS=zeros(length(headersData),1);
seqLength=length(data);
errSeq=zeros(seqLength,1);
trueSeqLength=length(trueSeq);
index=1;
endIndex=0;

   
for count=1:length(headersData)
    header=headersData(count);
        dataEnd=header+trueSeqLength-1;
    endIndex=endIndex+trueSeqLength;

    if(header+trueSeqLength-1>length(data))
        dataEnd=length(data);
        endIndex=index+dataEnd-header;
    end
    errSeq(index:endIndex)=bitxor(trueSeq(1:(endIndex-index)+1),data(header:dataEnd));
    BERS(count)=sum(bitxor(trueSeq(1:(endIndex-index)+1),data(header:dataEnd)))/(endIndex-index);
    index=index+trueSeqLength;

end
errSeq(endIndex:end)=[];
avgBER=sum(errSeq)/length(errSeq);
end
