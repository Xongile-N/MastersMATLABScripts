function [gapDistribution, EFR, gapsCumul,unscaledGaps] = runLengthDisitrbution(errSeq)
errSeq=[1 ;errSeq];
    [gapDistribution,gapsCumul,P01,diff,unscaledGaps] = getGapDistribution(errSeq);
    EFR=zeros(diff,1);
    EFR(1)=P01;
    for i=2:length(EFR)
        EFR(i)=(1-gapsCumul(i-1))*P01;
    end
end

