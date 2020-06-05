%Plot of gamma-gamma model parameters alpha and beta against log intensity
%variance (Rytov parameter)
clear all;
clc
R2=0:0.05:80; %Log intensity variance (Rytov variance) 
for i=1:length(R2) 
    R=R2(i);
    A=(0.49*R)/(1+1.11*R^(6/5))^(7/6);
    B=(0.51*R)/(1+0.69*R^(6/5))^(5/6); 
    Sci_ind(i)=exp(A+B) - 1; 
    alpha(i)=(exp(A) - 1)^-1;
    beta(i)=(exp(B) - 1)^-1;
end
%Plot function 
semilogx(R2,alpha,R2,beta)
xlabel('Log intensity variance \sigma_l^2') 
ylabel('Parameters: \alpha, \beta')
