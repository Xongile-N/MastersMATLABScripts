function [BERS,avgBER] = BER_packets_NR_match(headersData,data,trueSeqHeaders,trueSeq, frameLength)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
BERS=zeros(length(headersData),1);
packetCount=length(trueSeqHeaders);
packetNumbers=ceil((headersData-headersData(1))/frameLength)+1;
packetNumbers(500:600)
for count =1:length(headersData)-1

    trueSeqIndex=mod(packetNumbers(count)-1,packetCount)+1;
   BERS(count)=biterr(trueSeq(trueSeqHeaders(trueSeqIndex):trueSeqHeaders(trueSeqIndex)+frameLength-1),data(headersData(count):headersData(count)+frameLength-1))/frameLength;

    
end
avgBER=mean(BERS);
end

