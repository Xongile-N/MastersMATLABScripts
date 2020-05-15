function [encodedPacket,degree,rngSeed] = LTCoder(packets,degreeDistribution)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%[dist,cumulative]=RobustSoliton(k,delta,c);
trial=rand;
cumulative=cumsum(degreeDistribution);
degree=find(trial<cumulative,1,'first');
rngSeed=randi(256)-1;
rng(rngSeed);
indices=randi(size(packets,1),degree,1);
% degrees=zeros(k,1);
encodedPacket=zeros(1,size(packets,2));
for count=1:degree
    encodedPacket=bitxor(encodedPacket,packets(indices(count),:));
%     trial=rand;
%     degrees(count)=find(trial<cumulative,1,'first');
end
%histogram(degrees,1:k)
end

