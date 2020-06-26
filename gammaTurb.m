function [turbVector] = gammaTurb(turbLength,alpha,beta,thresh, errOut)
    a=alpha;
    b=beta;
    k=(a+b)/2;
    k1=a*b;
    K =2*(k1^k)/(gamma(a)*gamma(b));
    I=0.01:0.01:5;
    K1=I.^(k-1);
    Z=2*sqrt(k1*I);
    p=K.*K1.*besselk((a-b),Z); 
    pos=find(I==thresh);
    range=1:pos;
    pG=1-trapz(I(range),p(range))
    turbVector=ones(turbLength,1);
    for count=1:turbLength
        if(rand()>pG)
            turbVector(count)=errOut;
        end
    end
end

