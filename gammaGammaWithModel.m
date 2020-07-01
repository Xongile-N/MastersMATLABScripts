clear all;
clc;
%delta=0.5;
%c=0.1;
beamSize=100;% default=w_ST = 200; 
payloadSize=1000;
packetCount=100;
frameSize=1000;
overheadThresh=1;
        rng('shuffle');
bitCount=payloadSize*packetCount;
transmitFreq=1e5;
samplesPerClock=4;
samplingFreq=transmitFreq*4*samplesPerClock;
upSampleFreq=samplingFreq*3;
LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
LFSRPoly=[15 14 0];
 SNRS=(2:8)*2;
regime=2%1=weak, 2=moderate, 3=strong
alphaVec=[11.6,4,4.2];
betaVec=[10.1,1.9,1.4];

thresh=0.5;
errVal=0.1;
resolution=0.1;
bitStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
waveFormTX=OOK(bitStream,transmitFreq,samplingFreq);
turbulenceM=turbulenceModelTime(samplingFreq,length(waveFormTX), upSampleFreq, false,overheadThresh,beamSize);
turbulenceG=gammaTurb1(length(waveFormTX),alphaVec(regime),betaVec(regime),resolution);

types=[ 0 0 1 0 0 1;...
    0 1 0 0 1 0];
configs=[6];% choose which configs to test.
SNRS=[3]
for index0=1:length(configs)
    count=configs(index0)
    for index =1:length(SNRS)
        waveFormRX=2*waveFormTX.';
        waveFormRXA=awgn(waveFormRX,SNRS(index)); 
        waveFormRXAM=waveFormRXA.*turbulenceM(1:length(waveFormRXA));

        [resBin,~]=clockRecoveryFrame(waveFormRXAM,transmitFreq,samplingFreq,true, types(1,count), frameSize, types(2,count));
        errSeq=bitxor(resBin,bitStream);
                errorCount=sum(errSeq);
        BERG=errorCount/bitCount

        [gapsT,gapsTCumul,P01,diffT,unscaledT]=getGapDistribution(errSeq);

         EFRT=zeros(diffT,1);
         EFRT(1)=P01;
         for i=2:length(EFRT)
             EFRT(i)=(1-gapsTCumul(i-1))*P01;
         end
        waveFormRXAG=waveFormRXA.*turbulenceG(1:length(waveFormRXA));
        [resBin,~]=clockRecoveryFrame(waveFormRXAG,transmitFreq,samplingFreq,true, types(1,count), frameSize, types(2,count));
        errSeq=bitxor(resBin,bitStream);
                errorCount=sum(errSeq);
        BERM=errorCount/bitCount

        [gapsTG,gapsTGCumul,P01G,diffTG,unscaledTG]=getGapDistribution(errSeq);

         EFRTG=zeros(diffTG,1);
         EFRTG(1)=P01G;
         for i=2:length(EFRTG)
             EFRTG(i)=(1-gapsTGCumul(i-1))*P01G;
         end
    end

end
legendStrings=cell(2,1);
legendStrings{1}=['Turbulence Transmission model'];
legendStrings{2}=['Gamma Gamma Transmission model'];
clf
nexttile;
             barLimitT=100;
             if(barLimitT>length(gapsT))
                barLimitT=length(gapsT);
             end
                          barLimitG=100;
             if(barLimitG>length(gapsTG))
                barLimitG=length(gapsTG);
             end
    bC1=bar(gapsTCumul );
  %  bC1.FaceAlpha = 0.2;
    hold on
    bC2=bar(gapsTGCumul );
    bC2.FaceAlpha = 0.4;
    grid
    title('Cumulative distribution of gap lengths')
    ylabel('Cumulative Distribution');
    xlabel('Gap Lengths');
    legend(legendStrings);
    hold off
nexttile;
    bP1=bar(gapsT(1:barLimitT) );
  %  bP1.FaceAlpha = 0.2;
    hold on
    bP2=bar(gapsTG(1:barLimitG) );    
    bP2.FaceAlpha = 0.4;
    grid
    title('PDF of gap lengths')
    ylabel('Gaps PDF');
    xlabel('Gaps');
    legend(legendStrings);
    hold off
nexttile;
    bPU1=bar(unscaledT(1:barLimitT) );
   % bPU1.FaceAlpha = 0.2;
    hold on
    bPU2=bar(unscaledTG(1:barLimitG) );
    bPU2.FaceAlpha = 0.4;
    grid
    title('Distribution of gap lengths unscaled')
    ylabel('Gaps Count');
    xlabel('Gap lengths');
    legend(legendStrings);
    hold off
nexttile;
    bE1=bar(EFRT );
    %bE1.FaceAlpha = 0.2;
    hold on
    bE2=bar(EFRTG );
    bE2.FaceAlpha = 0.4;
    grid
    title('Distribution of error free length probabilities')
    ylabel('Error free run distribution');
    xlabel('EFR length');
    legend(legendStrings);
    hold off


