function [BERS,avgBER,errSeq] = BER_packets_HRSync(firstHeader,data,trueSeq)
%UNTITLED Find BER using one headers
%   Detailed explanation goes here
BERS=[];
errSeq=[];
trueSeqLength=length(trueSeq);
index=1;
packetLength=trueSeqLength;
    notFinished=true;
    count=0;
while (notFinished)
        currHeader=firstHeader+count*trueSeqLength;

    if(packetLength>=length(data(currHeader:end)))
        packetLength=length(data(currHeader:end));
        notFinished=false;
    end
    packet=data(currHeader:currHeader+packetLength-1);
    loopErrSeq=bitxor(trueSeq(1:packetLength),packet);
    BERS(end+1)=sum(loopErrSeq)/length(loopErrSeq);
    errSeq=[errSeq; loopErrSeq];
    index=index+trueSeqLength;
    count=count+1;


end

avgBER=sum(errSeq)/length(errSeq);
end
