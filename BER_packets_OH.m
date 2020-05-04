function [BERS,avgBER] = BER_packets_OH(headersData,data,trueSeqHeaders,trueSeq, frameLength)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
BERS=zeros(length(headersData),1);
packetCount=length(trueSeqHeaders);
currHeader=headersData(1);
frameCount=floor(length(data)/frameLength)
for count =1:frameCount
    trueSeqIndex=mod(count-1,packetCount)+1;
    BERS(count)=biterr(trueSeq(trueSeqHeaders(trueSeqIndex):trueSeqHeaders(trueSeqIndex)+frameLength-1),data(currHeader:currHeader+frameLength-1))/frameLength;
    currHeader=currHeader+1031;

end
avgBER=mean(BERS);
end

