clearvars;
FritchmanNoLT;
FritchmanNoLT_WithRS;
FritchmanLT_WithRS_Throughput;
FritchmanLT_WithRS_DecodeProbOFG;


if(addBP)
    FritchmanLT_WithRS_ThroughputBP;
     FritchmanLT_WithRS_DecodeProbBP;
    load("LTCodedBP.mat");

end
load("uncoded.mat");
load("RSCoded.mat");
load("LTCoded.mat");
simFileName='simSettings';
createSimVars(simFileName);
load(simFileName);
schemes=[];
for fritchInd=1:fritchCount
setChoice=fritchToUse(fritchInd);

    schemes=[schemes "sigma = "+rytovs(setChoice)];

end

legendStrings=["Uncoded","RS Coded", "RS + LT Coded OFG Overhead "+(overheadThresh-1)*100+"%", ];
throughputsCombined=[throughputsUncoded throughputsRSCoded throughputsLTCoded];

if(addBP)
legendStrings=[legendStrings "RS + LT Coded BP Overhead "+(overheadThresh-1)*100+"%"];
throughputsCombined=[throughputsCombined throughputsLTCodedBP];

end
figure();
bar((1:fritchCount),throughputsCombined)
ylabel("Throughput");
legend(legendStrings);
xticks(1:fritchCount)
xticklabels(schemes)