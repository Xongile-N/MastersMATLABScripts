function [turbVector,Var_l]  = LNTurb(Var_l,turbLength,limit)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% E[I] value 
Io=1;
I=0:0.005:limit;
turbVector=zeros(turbLength,1);
%Log irradinace variance values 
for j=1:length(I)
B=sqrt(2*pi*Var_l); 
C(j)=log(I(j)/Io)+(Var_l/2); 
D=2*Var_l;
pdf(j)=(1/I(j))*(1/B)*exp(-((C(j))^2)/D); 
end
    a=I(1);
    b=I(end);
    c=max(pdf);
    count=1;
    while count<turbLength
        x=rand();
        y=rand();
        xscaled=x*(b-a)+a;
        yscaled=y*c;
        values=find(I<xscaled);
        testPos=values(end);
        pTest=pdf(testPos);
        if(yscaled<pTest)
            turbVector(count)=xscaled;
            count=count+1;
        end
    end

end

