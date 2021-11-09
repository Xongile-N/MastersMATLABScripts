
function [turbVector,sigNSqr] = gammaTurb(SI,turbLength,limit)
   % sigLSqr=0.55;
%alphaW=1.23
%sigLSqr=alphaW*CnSqr*k^(7/6)*L^(11/6)
    R=SI;
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
    I=0.01:0.01:limit;
    K1=I.^(k-1);
    Z=2*sqrt(k1*I);
    p=K.*K1.*besselk((a-b),Z); 
    %plot(I,p)
    turbVector=ones(turbLength,1);
    a=I(1);
    b=I(end);
    c=max(p);
    count=1;
    while count<turbLength
        x=rand();
        y=rand();
        xscaled=x*(b-a)+a;
        yscaled=y*c;
        values=find(I<xscaled);
        testPos=values(end);
        pTest=p(testPos);
        if(yscaled<pTest)
            turbVector(count)=xscaled;
            count=count+1;
        end
    end
end

