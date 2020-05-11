function [x, CompleteCount] = XorGaussElim(A, b, base)
%function [x, CompleteCount] = XorGaussElim(A, b, base)
%
%Description:
% This function solves the linear equation Ax=b under gf(base)
%
%Input:
% A - a binary matrix (represented in decimal values)
% b - column vector in GF(base) (represented in decimal values)
% base - base of code b (must be prime)
%
%Output:
% x - resulting vector in GF(base) (represented in decimal values). -1 indicates an error in decoding
% CompleteCount - binary column vector of calculated entrees

Th = 1e-5; %threshold for numerical problems

m = size(A, 1);
n = size(A, 2);
x = -ones(n, 1);
%under rank matrix fails
if m > n
      
    CompleteCount = zeros(n, 1);
    
    if nargin >= 3
        ModFlag = 1;
    else
        ModFlag = 0;
    end
    if (~ModFlag) || (ModFlag && isprime(base))
        MakeLookUp;
    
        FlagErr = 0; %exit if singular
        for k = 1: n
            %Find pivot for column k:
            i_max = find(abs(A(k:m, k)));
            if ~any(i_max)
                %error('singular');
                FlagErr = 1;
                break;
            end
            i_max = i_max(1) + k -1;
            
            if i_max ~= k
                temp = A(k, :);
                A(k, :) = A(i_max, :);
                A(i_max, :) = temp;
                temp = b(k);
                b(k) = b(i_max);
                b(i_max) = temp;
            end
            
            %Do for all rows below pivot:
            for i = k+1: m
                %Do for all remaining elements in current row:
                if ~ModFlag
                    b(i) = b(i) - (A(i,k)/A(k,k))  * b(k);
                    A(i, :) = A(i, :) - A(i, k)/A(k, k)*A(k, :);
                else
                    %factor from lookup table
                    Factor = LookUp(A(k,k)+1, A(i,k)+1);
                    b(i) = mod(b(i) - Factor * b(k), base);
                    A(i, :) = mod(A(i, :) - Factor*A(k, :), base);
                end
            end
        end
        
        if ~FlagErr
            loc = find(sum(A,2) < Th);
            A(loc, :) = [];
            b(loc) = [];
            
            %otherwise process failed
            if size(A,1) == size(A,2)
                %back tracing
                while(size(A,1) > 0)
                    loc = find(sum(~~A,2) == 1);
                    if any(loc)
                        for ind = 1: length(loc)
                            pos = find(A(loc(ind), :));
                            if ~ModFlag
                                x(pos) = b(loc(ind)) / A(loc(ind), pos);
                            else
                                %factor from lookup table
                                Factor = LookUp(A(loc(ind), pos)+1, 1+1);
                                x(pos) = mod(b(loc(ind)) * Factor, base);
                            end
                            CompleteCount(pos) = 1;
                            
                            loc2 = find(A(:, pos));
                            if ~ModFlag
                                b(loc2) = b(loc2) - A(loc2, pos)* x(pos);
                            else
                                b(loc2) = mod(b(loc2) - A(loc2, pos)* x(pos), base);
                            end
                            A(:, pos) = 0;
                        end
                        A(loc, :) = [];
                        b(loc) = [];
                    else
                        break;
                    end
                end
            end
        end
    end
end