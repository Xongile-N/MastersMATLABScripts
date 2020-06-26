clear all;
clc;
%delta=0.5;
%c=0.1;
beamSize=200;% default=w_ST = 200; 
payloadSize=1000;
packetCount=10;
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

bitStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
waveFormTX=OOK(bitStream,transmitFreq,samplingFreq);
turbulence=turbulenceModelTime(samplingFreq,length(waveFormTX), upSampleFreq, false,overheadThresh,beamSize);
types=[ 0 0 1 0 0 1;...
    0 1 0 0 1 0];
configs=[5];% choose which configs to test.
SNRS=[3]
for index0=1:length(configs)
    count=configs(index0)
    for index =1:length(SNRS)
        waveFormRX=2*waveFormTX.';
        waveFormRXA=awgn(waveFormRX,SNRS(index)); 
        waveFormRXA=waveFormRXA.*turbulence(1:length(waveFormRXA));
        [resBin,~]=clockRecoveryFrame(waveFormRXA,transmitFreq,samplingFreq,true, types(1,count), frameSize, types(2,count));
        errSeq=bitxor(resBin,bitStream);
                errorCount=sum(errSeq);
        BER=errorCount/bitCount
        [gapsT,gapsTCumul,P01,diffT,unscaledT]=getGapDistribution(errSeq);

         EFRT=zeros(diffT,1);
         EFRT(1)=P01;
         for i=2:length(EFRT)
             EFRT(i)=(1-gapsTCumul(i-1))*P01;
         end
         
    end

end
trans = [0.8,0,0.2;
       0, 0.7,0.3;
      0.1,0.2,0.7]
  emis=[1,0;1,0;0 1;]
symbols=[0,1];
p=[0.3 0.3 0.4]
trans_hat = [0 p; zeros(size(trans,1),1) trans]

emis_hat = [zeros(1,size(emis,2)); emis]
maxIter=40;
[estTR,estE] = hmmtrain(errSeq.',trans_hat,emis_hat,'Symbols',symbols,'Verbose',true,'MaxIterations',maxIter)
genErrSeq=hmmgenerate(bitCount,  estTR,estE,'Symbols',symbols).';
        [gapsF,gapsFCumul,P01F,diffF,unscaledF]=getGapDistribution(genErrSeq);
         EFRF=zeros(diffF,1);
         EFRF(1)=P01F;
         for i=2:length(EFRF)
             EFRF(i)=(1-gapsFCumul(i-1))*P01F;
         end
             barLimit=100;
             if(barLimit>length(gapsT))
                 barLimit=length(gapsT)
             end
legendStrings=cell(2,1);
legendStrings{1}=['Turbulence Transmission model'];
legendStrings{2}=[strcat(num2str(size(trans,1)),' state Fritchman model')];
clf
nexttile;

    bC1=bar(gapsTCumul );
  %  bC1.FaceAlpha = 0.2;
    hold on
    bC2=bar(gapsFCumul );
    bC2.FaceAlpha = 0.4;
    grid
    title('Cumulative distribution of gap lengths')
    ylabel('Cumulative Distribution');
    xlabel('Gap Lengths');
    legend(legendStrings);
    hold off
nexttile;
    bP1=bar(gapsT(1:barLimit) );
  %  bP1.FaceAlpha = 0.2;
    hold on
    bP2=bar(gapsF(1:barLimit) );    
    bP2.FaceAlpha = 0.4;
    grid
    title('PDF of gap lengths')
    ylabel('Gaps PDF');
    xlabel('Gaps');
    legend(legendStrings);
    hold off
nexttile;
    bPU1=bar(unscaledT(1:barLimit) );
   % bPU1.FaceAlpha = 0.2;
    hold on
    bPU2=bar(unscaledF(1:barLimit) );
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
    bE2=bar(EFRF );
    bE2.FaceAlpha = 0.4;
    grid
    title('Distribution of error free length probabilities')
    ylabel('Error free run distribution');
    xlabel('EFR length');
    legend(legendStrings);
    hold off


