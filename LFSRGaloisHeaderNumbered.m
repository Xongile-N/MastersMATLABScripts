function sequence = LFSRGaloisHeaderNumbered(seed,poly,totLength,header,frameLength)
sequence=zeros(totLength,1);
lfsr=seed;
headerLength=length(header)
index=1
packetNumber=0;
while (index<=totLength)
    isHeader=mod(index-1,frameLength+headerLength+8)==0;
    if(isHeader)
        packetNumber=packetNumber+1;
        for hIndex=1:headerLength
            sequence(index)=header(hIndex);
            index=index+1;
        end
        numBin=de2bi(packetNumber,8,'left-msb');
        for numIndex=1:8
            sequence(index)=numBin(numIndex);
            index=index+1;
        end
        index=index-1;
    else
        sequence(index)=bitand(lfsr,1,'uint8');
        lfsr=bitshift(lfsr,-1,'uint8');
        if(sequence(index)==1)
            lfsr=bitxor(lfsr,poly,'uint8');
        end
    end
        index=index+1;

end

end

