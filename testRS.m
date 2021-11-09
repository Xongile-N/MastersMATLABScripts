clear all;
rng(1993);     % Seed random number generator for repeatable results
M = 4;         % Modulation order
bps = log2(M); % Bits per symbol
N = 7;         % RS codeword length
K = 5;         % RS message length

pskModulator = comm.PSKModulator('ModulationOrder',M,'BitInput',true);
pskDemodulator = comm.PSKDemodulator('ModulationOrder',M,'BitOutput',true);
awgnChannel = comm.AWGNChannel('BitsPerSymbol',bps);
errorRate = comm.ErrorRate;

rsEncoder = comm.RSEncoder('BitInput',true,'CodewordLength',N,'MessageLength',K);
rsDecoder = comm.RSDecoder('BitInput',true,'CodewordLength',N,'MessageLength',K);
ebnoVec = (3:0.5:8)';
ebnoVecCodingGain = ebnoVec + 10*log10(K/N); % Account for RS coding gain
errorStats = zeros(length(ebnoVec),3);

for i = 1:length(ebnoVec)
    awgnChannel.EbNo = ebnoVecCodingGain(i);
    reset(errorRate)
    while errorStats(i,2) < 100 && errorStats(i,3) < 1e7
        data = randi([0 1],3000,1);                % Generate binary data
        encData = rsEncoder(data);                 % RS encode
        modData = pskModulator(encData);           % Modulate
        rxSig = awgnChannel(modData);              % Pass signal through AWGN
        rxData = pskDemodulator(rxSig);            % Demodulate
        [decData,errCount] = rsDecoder(rxData);               % RS decode
       errCount
        errorStats(i,:) = errorRate(data,decData); % Collect error statistics
    end
end