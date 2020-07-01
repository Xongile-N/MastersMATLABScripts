function [BERS,avgBER,errSeq] = BER_packets_HRSync(headersData,data,trueSeq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
BERS=zeros(length(headersData),1);
errSeq=zeros(length(data)-headersData(1),1);
trueSeqLength=length(trueSeq);
index=1;
endIndex=trueSeqLength;
for count=1:length(headersData)
    firstHeader=headersData(1)+(count-1)*trueSeqLength;
    errSeq(index:endIndex)=bitxor(trueSeq(1:(endIndex-index)+1),data(firstHeader:firstHeader+trueSeqLength-1));
    index=index+trueSeqLength;
    if(endIndex+trueSeqLength>length(errSeq))
        endIndex=length(errSeq);
    else
        endIndex=endIndex+trueSeqLength;
    end

end

avgBER=sum(errSeq)/length(errSeq);
end
