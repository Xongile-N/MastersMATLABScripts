function [distribution,cumulative] = RobustSolitonQ(K,delta,Q)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
distribution=1:K;
p_d=distribution;
r_d=distribution;

R=K/Q;
p_d(1)=1/K;
for count =2:K
p_d(count)=1/(count*(count-1));
end
for count=1:K
    if (count<(K/R))
        r_d(count)=(1/count);
    elseif count==ceil(K/R)
        r_d(count)=log(R/delta);
    else
        r_d(count)=0;    
    end
end
r_d=r_d*R/K;
Z=sum(p_d)+sum(r_d);
distribution=(p_d+r_d)/Z;
cumulative=cumsum(distribution);

 % plot(1:K,distribution);%

end

