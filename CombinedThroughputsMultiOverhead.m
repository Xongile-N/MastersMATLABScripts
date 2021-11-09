clear all;
simFileName='simSettings';
createSimVars(simFileName);
load(simFileName);


throughputsLTCodedCombined=[];
for count=1:length(overheadThreshes)
    throughputsLTCodedCombined=FritchmanLT_WithRS_ThroughputMultiOverhead(count,throughputsLTCodedCombined);
end
%FritchmanNoLT;
%FritchmanNoLT_WithRS;
%FritchmanLT_WithRS_DecodeProbOFG;
load("uncoded.mat");
load("RSCoded.mat");

simFileName='simSettings';
createSimVars(simFileName);
load(simFileName);
schemes=[];
for fritchInd=1:fritchCount
setChoice=fritchToUse(fritchInd);

    schemes=[schemes "sigma = "+rytovs(setChoice)];

end
throughputsCombined=[throughputsUncoded throughputsRSCoded throughputsLTCodedCombined];
throughputsCombined=throughputsLTCodedCombined

%legendStrings=["Uncoded","RS Coded" ];
  %  legendStrings=[legendStrings "RS + LT Coded OFG Overhead "+(overheadThreshes(3)-1)*100+"%"];

 for count=1:length(overheadThreshes)
     legendStrings=[legendStrings "RS + LT Coded OFG Overhead "+(overheadThreshes(count)-1)*100+"%"];
 end
figure();
bar((1:fritchCount),throughputsCombined)
ylabel("Throughput");
legend(legendStrings);
xticks(1:fritchCount)
xticklabels(schemes)
