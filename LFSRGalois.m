function sequence = LFSRGalois(seed,poly,length)
sequence=zeros(length,1);
lfsr=seed;
for index=1:length
sequence(index)=bitand(lfsr,1,'uint8');
lfsr=bitshift(lfsr,-1,'uint8');
    if(sequence(index)==1)
        lfsr=bitxor(lfsr,poly,'uint8');
    end
end

end

