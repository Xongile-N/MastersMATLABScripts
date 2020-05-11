%Test Fountain

%flag to control implementation
LTFlag = 1;

%******
%parameters
K = 520;
MaxN = 1016; %maximum N

%parameters for Reed-Solomon Raptor code
FountainDelta = 1.1; %to determine the N of the outer code for Raptor
RS_Base = 8;
NRaptor = ceil(K/RS_Base*FountainDelta);
if floor((NRaptor-K)/2) ~= (NRaptor-K)/2
    error('Code rate infeasible');
end
if floor(K/RS_Base) ~= K/RS_Base
    error('Change FountainDelta or K');
end
NRaptorBig = 2^(ceil(log2(NRaptor + 1))) - 1;

RaptorCoderRS = comm.RSEncoder(NRaptorBig, K/RS_Base);
RaptorPuncRS = RaptorCoderRS.PuncturePattern;
RaptorPuncture = NRaptorBig - NRaptor;
RaptorPuncRS(end - RaptorPuncture + 1: end) = ~(RaptorPuncRS(end - RaptorPuncture + 1: end));
RaptorCoderRS.PuncturePattern = RaptorPuncRS;
RaptorDecoderRS =  comm.RSDecoder(RaptorCoderRS);

LTBase = 8; %base for codeword 
MatrixBase = 2; %base for codeword 
%(Note: for matrix implementation, MatrixBase has to be a GF field, i.e, prime or power of prime)
% This implementation supports prime base only till base=7. For other bases, fill in the
% lookup table at MakeLoopUp.m. For non-prime bases, matrix inversion will
% have to be in gf.
%******

%current N: this value should change as part of a loop
CurrentN = floor(MaxN/4*3);

%Fountain matrix
if LTFlag
    G = GenerateG(K, CurrentN); %LT
    G_Raptor = GenerateG(NRaptor*RS_Base, CurrentN);
else
    G = GenerateGMatrix(K, CurrentN); %Matrix
    G_Raptor = GenerateGMatrix(NRaptor*RS_Base, CurrentN);
end

%-------------------
%generate message
msg = randi(RaptorDecoderRS.N, K/RS_Base, 1);
if LTFlag
    Bits = (dec2base(msg, LTBase, RS_Base))';
else
    Bits = (dec2base(msg, MatrixBase, RS_Base))';
end
Bits = (Bits(:))';
BitsVec = zeros(length(Bits), 1);
for Ind = 1: length(Bits)
    BitsVec(Ind) = str2double(Bits(Ind));
end
%-----------------
%encode

%Fountain
if LTFlag
    F = EncodeFountain(G, BitsVec, LTBase);
else
    F = EncodeFountain(G, BitsVec, MatrixBase);
end

%Raptor
RaptorCodeRS = encode(RaptorCoderRS, msg);

%Transfer into base
if LTFlag
    RaptorCodeRS_Sym = (dec2base(RaptorCodeRS, LTBase, RS_Base))';
else
    RaptorCodeRS_Sym = (dec2base(RaptorCodeRS, MatrixBase, RS_Base))';
end
RaptorCodeRS_Sym = RaptorCodeRS_Sym(:);
RaptorCodeRS_SymVec = zeros(length(RaptorCodeRS_Sym), 1);
for ind = 1: length(RaptorCodeRS_Sym)
    RaptorCodeRS_SymVec(ind) = str2double(RaptorCodeRS_Sym(ind));
end

if LTFlag
    FRaptor = EncodeFountain(G_Raptor, RaptorCodeRS_SymVec, LTBase);
else
    FRaptor = EncodeFountain(G_Raptor, RaptorCodeRS_SymVec, MatrixBase);
end
%-------------

%get expected error
CurrentSNR = 100; %SNR in dB
PeBit = 1/2 * erfc(sqrt(10.^(CurrentSNR./10)));
PeSymbolLT = PeBit * (2^LTBase-1)/(2^(LTBase-1));
PeSymbolMatrix = PeBit * (2^MatrixBase-1)/(2^(MatrixBase-1));
%-------------

%-------------
%place erasures

ErasureVec = zeros(1, CurrentN);
if LTFlag
    ErasureVec(rand(1,length(CurrentN)) < PeSymbolLT) = 1;
else
    ErasureVec(rand(1,length(CurrentN)) < PeSymbolMatrix) = 1;
end

%Fountain
G(:, ErasureVec==1) = [];
F(ErasureVec==1) = [];
%Raptor
G_Raptor(:, ErasureVec==1) = [];
FRaptor(ErasureVec==1) = [];
%-------------

%----------------
%decode message

%Fountain
if LTFlag
    DecBits = DecodeFountainLT(G, F, log2(LTBase)); %LT
    %minus ones are non-decoded symbols (for erasures of next degree, i.e., raptor code)
    loc = find(DecBits<0);
    DecBits(loc) = randi(LTBase, 1, length(loc))-1;
else
    DecBits = XorGaussElim(G', F, MatrixBase); %Matrix
    %minus ones are non-decoded symbols (for erasures of next degree, i.e., raptor code)
    loc = find(DecBits<0);
    DecBits(loc) = randi(MatrixBase, 1, length(loc))-1;
end
%get symbol error rate
errFountain = length(find(DecBits - BitsVec ~= 0))/length(BitsVec);

%Raptor
if LTFlag
    DecBits = DecodeFountainLT(G_Raptor, FRaptor, log2(LTBase));
else
    DecBits = XorGaussElim(G_Raptor', FRaptor, MatrixBase);
end
DecBits = reshape(DecBits, RS_Base, length(DecBits)/RS_Base);
[loc, cloc] = find(DecBits < 0);
DecBits(loc, cloc) = 0;
DecBits = DecBits';
DecBits = num2str(DecBits);
if LTFlag
    DecSymbols = base2dec(DecBits(:,1:3:end), LTBase);
else
    DecSymbols = base2dec(DecBits(:,1:3:end), MatrixBase);
end

ErasureSym = zeros(length(DecSymbols), 1);
ErasureSym(loc) = 1;
decoded = decode(RaptorDecoderRS, DecSymbols, ErasureSym);
Bits = (dec2bin(decoded, RS_Base))';
Bits = (Bits(:))';
DecBits = zeros(1, length(Bits));
for Ind = 1: length(Bits)
    DecBits(Ind) = str2double(Bits(Ind));
end
%get symbol error rate
errRaptor = length(find(DecBits' - BitsVec ~= 0))/length(BitsVec);

%----------------
disp([errFountain, errRaptor])