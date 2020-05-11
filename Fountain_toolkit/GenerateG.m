function G = GenerateG(K, N, ColTH, TryNum)
%function G = GenerateG(K, N, ColTH, TryNum)
%
%Decription:
% This function generates the binary matrix for Fountain codes
%
%Input:
% K - number of rows
% N - number of columns
% ColTH - lower bound for number of 1's per col (multiple of K/S)
% TryNum - number of tests to choose from
%
%Output:
% G - a K X N binary matrix
%
%Formed by: Roee Diamant, UBC, July 2012

if nargin < 3
    ColTH = 1.3; %bound for number of 1's in each column
end
if nargin < 4
    TryNum = 10;
end

TryG = {};
MeanSummerRow = zeros(1, TryNum);
MinSummerRow = zeros(1, TryNum);
for TryInd = 1: TryNum
    while(1)
        %-----------------
        %create pdf
        c = 0.2;
        delta = 0.3;
        S = c*log(K/delta)*sqrt(K);
        
        rho = zeros(1, K);
        thu = zeros(1, K);
        d = 1: K;
        
        rho(1) = 1/K;
        rho(2:K) = 1 ./ (d(2:end) .* (d(2:end)-1));
        
        loc = floor(K/S-1);
        thu(1: loc) = S/K ./ d(1: loc);
        thu(loc+1) = S/K*log(S/delta);
        
        Z = sum(rho + thu);
        mu = (rho + thu) / Z;
        %-----------------
        %threshold for maximum number of ones per column
        MaxColTH = K/S * ColTH;
        
        G = zeros(K, N);
        for n = 1: N
            while(1)
                %-----------------
                %draw a number
                Cmu = cumsum(mu)/sum(mu);
                u = rand(1,1);
                diff = abs(u - Cmu);
                [M, loc] = min(diff);
                Num = d(loc);
                %-----------------
                if Num <= MaxColTH
                    break;
                end
            end
            row = randperm(K);
            G(row(1: Num), n) = 1;
        end
        
        SummerRow = sum(G, 2);
        if min(SummerRow) > 0
            MeanSummerRow(TryInd) = mean(SummerRow);
            MinSummerRow(TryInd) = min(SummerRow);
            TryG{TryInd} = sparse(G); %#ok<AGROW>
            break;
        end
    end
end

%maximize weight per row and minimize weight per col
[V, loc] = max(MeanSummerRow);
G = TryG{loc};
G = full(G);