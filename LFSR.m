function sequence = LFSR(seed,polynomial,length)
pnSequence = comm.PNSequence('Polynomial',polynomial, ...
    'SamplesPerFrame',length,'InitialConditions',seed);
sequence=pnSequence();
end

