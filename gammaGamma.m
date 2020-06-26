%The Gamma-gamma pdf 
clear all 
clc
alpha=4.2;
a=alpha;
beta=1.4;
b=beta;
k=(a+b)/2;
k1=a*b;
K =2*(k1^k)/(gamma(a)*gamma(b));
I=0.01:0.01:5;
K1=I.^(k-1);
Z=2*sqrt(k1*I);
p=K.*K1.*besselk((a-b),Z); 
plot(I,p)
xlabel('Irradiance, I') 
ylabel('Gamma gamma pdf, p(I)')
pos=find(I==0.5);
%range=1:floor(length(I)/2);
range=1:pos;
pG=1-trapz(I(range),p(range))
