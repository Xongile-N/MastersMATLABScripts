function binRes=waveToBinary(wavePoints,threshold, skipCount)
clc
length(wavePoints)
threshold
binRes=zeros(floor(length(wavePoints)/skipCount)+1,1);
length(binRes)
index=floor(skipCount/2)

for count=1:length(binRes)-1
    binRes(count)=wavePoints(index)>threshold;
    index=index+skipCount;
end
binRes=binRes.';
end

