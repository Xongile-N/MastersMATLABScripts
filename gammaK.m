function [K] = gammaK(rytov)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    R=rytov;
    A=(0.49*R)/(1+1.11*R^(6/5))^(7/6); 
    B=(0.51*R)/(1+0.69*R^(6/5))^(5/6); 
    alpha=1/(exp(A)-1);
    a=alpha;
    beta=1/(exp(B)-1);
    sigNSqr=exp(A+B)-1;
    b=beta;
    k=(a+b)/2;
    k1=a*b;
    K =2*(k1^k)/(gamma(a)*gamma(b));
end

