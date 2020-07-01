function [turbVector] = gammaTurb1(turbLength,alpha,beta,resolution)
    
a=alpha;
    b=beta;
    k=(a+b)/2;
    k1=a*b;
    K =2*(k1^k)/(gamma(a)*gamma(b));
    
    Ires=0.01;
    I=0.01:Ires:5;
    K1=I.^(k-1);
    Z=2*sqrt(k1*I);
    p=K.*K1.*besselk((a-b),Z); 
    probX=0:resolution:I(end);
    probValues=zeros(size(probX));
    for count=2:length(probValues)
        pos=find(abs(I-probX(count))<Ires/10);
        range=1:pos;
        probValues(count)=trapz(I(range),p(range));
    end
    turbVector=ones(turbLength,1);
    for count=1:turbLength
        num=rand();
        pos=find(probValues>num,1);
        if(isempty(pos))
            pos=length(probValues);
        end
        probX(pos);
        val=rand()*probX(pos);
        turbVector(count)=val;
    end
end

