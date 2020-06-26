clear all 


payloadSize=1000;
packetCount=10;
frameSize=1000;
rng('shuffle');
bitCount=payloadSize*packetCount;
transmitFreq=1e5;
samplesPerClock=4;
samplingFreq=transmitFreq*4*samplesPerClock;

LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
LFSRPoly=[15 14 0];
SNRS=(2:8)*2;
bitStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
waveFormTX=OOK(bitStream,transmitFreq,samplingFreq);
regime=3%1=weak, 2=moderate, 3=strong
alphaVec=[11.6,4,4.2];
betaVec=[10.1,1.9,1.4];

thresh=0.5;
errVal=0.3;
turbulence=gammaTurb(length(waveFormTX),alphaVec(regime),betaVec(regime),thresh,errVal);
atten=find(turbulence==errVal);
length(atten)
length(atten)/length(turbulence)
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