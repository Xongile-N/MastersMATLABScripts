function [G,B] = backSubstitution(G,B)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    K=size(G,1);
    for count=1:K
        index=K-count+1;
        for backIndex=1:index-1;

            B(backIndex,:)=bitxor(B(backIndex,:),B(index,:)*G(backIndex,index));
            G(backIndex,:)=bitxor(G(backIndex,:),G(index,:)*G(backIndex,index));
        end
    end
end

