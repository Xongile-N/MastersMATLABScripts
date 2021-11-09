function [encodedPacket,degree,rngSeed] = LTCoder(packets,degreeDistribution,seedBits)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
trial=rand;
cumulative=cumsum(degreeDistribution);
degree=find(trial<cumulative,1,'first');
passed=false;
rngSeed=randi(2^seedBits)-1;
rng(rngSeed);
indices=randperm(size(packets,1),degree);

encodedPacket=zeros(1,size(packets,2));
for count=1:degree
    encodedPacket=bitxor(encodedPacket,packets(indices(count),:));
%     trial=rand;
%     degrees(count)=find(trial<cumulative,1,'first');
end
end

