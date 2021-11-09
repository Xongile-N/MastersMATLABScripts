function [samples] = LNSample(Var_l,I)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
Io=1;
%I=0:0.005:limit;
%Log irradinace variance values 

    for j=1:length(I)
        B=sqrt(2*pi*Var_l); 
        C(j)=log(I(j)/Io)+(Var_l/2); 
        D=2*Var_l;
        samples(j)=(1/I(j))*(1/B)*exp(-((C(j))^2)/D); 
    end
    samples=samples.';
end

