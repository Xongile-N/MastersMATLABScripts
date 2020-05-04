function [BERS,avgBER,packets,skipped] = BER_NumberedPackets(headersData,data,trueSeqHeaders,...
    trueSeq, frameLength,headerLength)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
BERS=zeros(length(headersData)-1,1);
packetCount=length(trueSeqHeaders);
packetNumbers=ceil((headersData-headersData(1))/frameLength)+1;
packets=zeros(length(headersData),2);
skipped=[];
for count =1:length(headersData)-1
    numBin=bi2de(data(headersData(count)+headerLength:headersData(count)+headerLength+7).','left-msb');
    %trueSeqIndex=mod(packetNumbers(count)-1,packetCount)+1
    trueSeqIndex=numBin;
    packets(count,1)=numBin;
    packets(count,2)=count;
   BERS(count)=biterr(trueSeq(trueSeqHeaders(trueSeqIndex):trueSeqHeaders(trueSeqIndex)+frameLength-1),data(headersData(count):headersData(count)+frameLength-1))/frameLength;

    
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

