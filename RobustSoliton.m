function [distribution,cumulative] = RobustSoliton(K,delta,c)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
distribution=1:K;
p_d=distribution;
r_d=distribution;
S=c*log(K/delta)*sqrt(K)
p_d(1)=1/K;
for count =2:K
p_d(count)=1/(count*(count-1));
end
for count=1:K
    if (count<(K/S))
        r_d(count)=(1/count);
    elseif count==ceil(K/S)
        r_d(count)=log(S/delta);
    else
        r_d(count)=0;    
    end
end
r_d=r_d*S/K;
Z=sum(p_d)+sum(r_d);
distribution=(p_d+r_d)/Z;
cumulative=cumsum(distribution);
% 
%  hold off
%  plot(1:K,distribution);
%  hold on
%  plot(1:K,cumulative);

end
