%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPEA124
% Project Title: Implementation of MOEA/D
% Muti-Objective Evolutionary Algorithm based on Decomposition
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

function legendString=PlotCosts(EP,costNames,it,legendString)
    EPC=[EP.Cost];
    plot(EPC(1,:),EPC(2,:),'x');
        if nargin>1
                xlabel(costNames(1));
    ylabel(costNames(2));
        else
    xlabel('1^{st} Objective');
    ylabel('2^{nd} Objective');

        end
    legendString{size(legendString,2)+1}=strcat("Generation ",num2str(it));
    legend(legendString);
    grid on;

end