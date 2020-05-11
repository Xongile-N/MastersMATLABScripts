function G = GenerateGMatrix(K, N)
%function G = GenerateGMatrix(K, N)
%
%Decription:
% This function generates the binary matrix for Fountain codes
%
%Input:
% K - number of rows
% N - number of columns
%
%Output:
% G - a K X N binary matrix
%
%Formed by: Roee Diamant, UBC, Oct 2012

Sigma = ceil(2*log(K));
if Sigma/2 == floor(Sigma/2)
    Sigma = Sigma + 1;
end

W = ceil(2 * (sqrt(K)-1)*(Sigma-1)/(Sigma-2));

G = zeros(K, N);
for n = 1: N
    loc = round(rand(1,1)*K);
    PosVec = [loc+1: min(K, loc+W), 1: W-(K-loc)];
    pos = randperm(W);
    G(PosVec(pos(1: Sigma)), n) = 1;
end