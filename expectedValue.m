function E = expectedValue(dataSet);
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fig=figure; 
set(fig,'visible','on');
nBins=100;
dist=histogram(dataSet,nBins,'Normalization','probability');
bins=dist.BinEdges(2:end)-dist.BinWidth/2;
values=dist.Values;
weigthed=bins.*values;
E=sum(weigthed);
%histogram(dataSet./E,nBins,'Normalization','probability');
close(fig)

end

