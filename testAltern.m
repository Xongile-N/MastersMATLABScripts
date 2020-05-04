function [positions,BER,origData] = testAltern(testData,first)
bitCount=length(testData);
origData=zeros(1,bitCount);
for count=1:bitCount
    origData(count)=mod((count-1)+first,2);
end
temp=abs(testData-origData);
positions=find(temp);
BER=mean(temp);

