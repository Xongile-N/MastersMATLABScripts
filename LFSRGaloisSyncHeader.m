function sequence = LFSRGaloisSyncHeader(seed,poly,totLength,header)
sequence=zeros(totLength,1);
lfsr=seed;
headerLength=length(header);
index=1;
for hIndex=1:headerLength
    sequence(index)=header(hIndex);
    index=index+1;
end
while (index<=totLength)

        sequence(index)=bitand(lfsr,1,'uint16');
        lfsr=bitshift(lfsr,-1,'uint16');
        if(sequence(index)==1)
            lfsr=bitxor(lfsr,poly,'uint16');
        end
       index=index+1;

end

end

