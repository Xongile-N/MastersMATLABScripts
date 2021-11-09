%The Gamma-gamma pdf 

clc









sigLSqr=0.55
R=sigLSqr;
A=(0.49*R)/(1+1.11*R^(6/5))^(7/6); 
B=(0.51*R)/(1+0.69*R^(6/5))^(5/6); 
alpha=1/(exp(A)-1)
a=alpha;
beta=1/(exp(B)-1)
sigNSqr=exp(A+B)-1
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
pG=1-trapz(I(range),p(range));
