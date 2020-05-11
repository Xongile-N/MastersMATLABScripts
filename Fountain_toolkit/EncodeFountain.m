function Code = EncodeFountain(G, msg, Base)
%function Code = EncodeFountain(G, msg, Base)
%
%Description:
%This function encodes fountain code
%
%Input:
% G - a K X N binary matrix
% msg - vector of K symbols to decode
% Base - base of codeword
%
%Output:
% Code - vector of N coded symbols
%
%Formed by: Roee Diamant, UBC, July 2012

Code = mod(G' * msg, Base);