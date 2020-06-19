function [BERS,avgBER,skipped] = BER_packets_NR(headersData,data,trueSeqHeaders,trueSeq, frameLength)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
BERS=zeros(length(headersData),1);
packetCount=length(trueSeqHeaders);
packets=zeros(length(headersData),2);

for count =1:length(headersData)-1
    trueSeqIndex=mod(count-1,packetCount)+1;%checks if packets have cycled to beginning
        packets(count,1)=trueSeqIndex;
    packets(count,2)=count;
    trueSeqLoop=trueSeq(trueSeqHeaders(trueSeqIndex):trueSeqHeaders(trueSeqIndex)+frameLength-1);
    dataLoop=data(headersData(count):headersData(count)+frameLength-1).';
   BERS(count)=biterr(trueSeqLoop,dataLoop)/frameLength;
    avgBER=mean(BERS);
end

prevPacket=packets(1,1)-1;
index=1;
for count=1:length(packets(:,1))
currPacket=packets(count,1);
if(currPacket-1~=mod(prevPacket,length(trueSeqHeaders)));
skipped(index,1)=currPacket-1;
skipped(index,2)=packets(count,2);
index=index+1;
end
prevPacket=currPacket;
end
avgBER=mean(BERS);
end
