function [A] = gammaAlpha(rytov)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
R=rytov;

    A=(0.49*R)/(1+1.11*R^(6/5))^(7/6); 

end

