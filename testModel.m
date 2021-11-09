clear all;
simFileName='simSettings';
createSimVars(simFileName);
load(simFileName);
addpath '..\..\data'symbols=[0,1];
errSeqLen=10000000;
BERTests=zeros(fritchCount,1);
for fritchInd=1:fritchCount
    fritchInd
setChoice=fritchToUse(fritchInd);

filenameData =fileNames(setChoice);
load(filenameData);
[errSeqF,~]=hmmgenerate(errSeqLen,estTR,estE,'Symbols',symbols);
mean(errSeqF)
end
