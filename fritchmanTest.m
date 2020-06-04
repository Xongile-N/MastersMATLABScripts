clc;
beamSize=200;% default=w_ST = 200; 
payloadSize=1000;
packetCount=1000;
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
configs=[6];% choose which configs to test.
SNRS=[4]
for index0=1:length(configs)
    count=configs(index0)
    for index =1:length(SNRS)
        waveFormRX=2*waveFormTX.';
        waveFormRXA=awgn(waveFormRX,SNRS(index)); 
        waveFormRXA=waveFormRXA.*turbulence(1:length(waveFormRXA));
        [resBin,~]=clockRecoveryFrame(waveFormRXA,transmitFreq,samplingFreq,true, types(1,count), frameSize, types(2,count));
       errSeq=bitxor(resBin,bitStream);
         errorCount=sum(errSeq);
        [count index sum(errSeq)]
        BER=errorCount/bitCount

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
[estTR,estE] = hmmtrain(errSeq.',trans_hat,emis_hat,'Symbols',symbols,'Verbose',true);

estTR,estE
