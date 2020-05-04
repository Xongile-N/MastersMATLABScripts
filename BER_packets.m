function [BERS,avgBER] = BER_packets(headers,data,trueSeq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
packetSize=length(trueSeq);
BERS=zeros(length(headers),1);
for count =1:length(headers)-1
   BERS(count)=biterr(trueSeq.',data(headers(count):headers(count)+packetSize-1))/packetSize;
end
avgBER=mean(BERS);
end

