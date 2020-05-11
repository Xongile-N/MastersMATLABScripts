function Decoded = DecodeFountainLT(G, Code, Base)
%function Decoded = DecodeFountainLT(G, Code, Base)
%
%Decription:
% This function decodes Fountain LT code
%
%Input:
% G - binary matrix (K X N)
% Code - code word to decode (vector size of N)
% Base - base of codeword
%
%Output:
% Decoded - vector of K decoded symbols (-1 indicates unseccesfull decoding)
% 
%Formed by: Roee Diamant, UBC, July 2012

K = size(G, 1);
N = size(G, 2);

GTag = G;
Decoded = -ones(K, 1);
Summer = zeros(1, K);
while(1)
    loc = find(sum(GTag,1) == 1);
    if isempty(loc)
        %code fails
        break;
    end
    for ind = 1: length(loc)
        pos = find(GTag(:, loc(ind)) == 1);
        loc2 = find(GTag(pos, :) == 1);
        GTag(pos, :) = 0;
        Summer(pos) = 1;
        Decoded(pos) = Code(loc(ind));
        Code(loc2) = mod(Code(loc2)-Decoded(pos), 2^(Base));
    end
    if sum(Summer) == K
        break;
    end
end
