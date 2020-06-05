function [outputArg1,outputArg2] = gTurbulence(maxI,alpha,beta)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%alpha=4.2;
a=alpha;
%beta=1.4;
b=beta;
k=(a+b)/2;
k1=a*b;
K =2*(k1^k)/(gamma(a)*gamma(b));
I=0.01:0.01:maxI;
K1=I.^(k-1);
Z=2*sqrt(k1*I);
p=K.*K1.*besselk((a-b),Z);
%hold on
plot(I,p)
xlabel('Irradiance, I') 
ylabel('Gamma gamma pdf, p(I)')
end

