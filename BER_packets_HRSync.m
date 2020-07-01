function [BERS,avgBER,errSeq] = BER_packets_HRSync(headersData,data,trueSeq, frameLength)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
BERS=zeros(length(headersData),1);
packetCount=length(trueSeqHeaders);
packets=zeros(length(headersData),2);
errSeq=zeros(length(headersData)*frameLength,1);
trueSeqLength=length(trueSeq);
index=1;
endIndex=trueSeqLength;
for count=1:length(headersData)
    firstHeader=headersData(1)+(count-1)*trueSeqLength;
    errSeq(index:endIndex)=bitxor(trueSeqLength,data(firstHeader:firstHeader+trueSeqLength-1);
    index=index+trueSeqLength;
    endIndex=endIndex+trueSeqLength;
    BERS(count)=sum(errSeq)/trueSeqLength;

end

avgBER=mean(BERS);
end
