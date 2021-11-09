function [distribution,cumulative] = Soliton(K)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
distribution=1:K;
p_d=distribution;
p_d(1)=1/K;
for count =2:K
p_d(count)=1/(count*(count-1));
end
distribution=(p_d);
cumulative=cumsum(distribution);
 
% hold off
  %plot(1:K,distribution);
 % hold on
%  plot(1:K,cumulative);

end