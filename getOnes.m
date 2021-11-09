function onesSamples = getOnes(bitSamples, onePos, packetLength, startPoint)
    bitSamples(1:startPoint-1)=[];

    data=bitSamples;
    notFinished=true;
    index=0;
    onesSamples=[];
    while (notFinished)
        currHeader=1+index*packetLength;
        if(packetLength>=length(data(currHeader:end)))
            packetLength=length(data(currHeader:end));
            notFinished=false;
        end
        packet=data(currHeader:currHeader+packetLength-1);
        %binaryPacket=binary(currHeader:currHeader+packetLength-1);
        canCheck=find(onePos<=packetLength);
        for count=1:length(canCheck)
            onesSamples=[onesSamples; cell2mat(packet(canCheck(count))).'];
        end
        index=index+1;

    end


end

