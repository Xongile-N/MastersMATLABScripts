%clear all;
clc;
%delta=0.5;
%c=0.1;
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
SNRS=[10]
for index0=1:length(configs)
    count=configs(index0)
    for index =1:length(SNRS)
        waveFormRX=2*waveFormTX.';
        waveFormRXA=awgn(waveFormRX,SNRS(index)); 
        waveFormRXA=waveFormRXA.*turbulence(1:length(waveFormRXA));
        [resBin,~]=clockRecoveryFrame(waveFormRXA,transmitFreq,samplingFreq,true, types(1,count), frameSize, types(2,count));
        errSeq=bitxor(resBin,bitStream);
        pos=find(errSeq);
        posSort=sort(pos);
        diff=0;
        diffPos=1;
        diffPos2=1;
        for posI=1:length(posSort)-1
            if((posSort(posI+1)-posSort(posI))>diff)
                diff=posSort(posI+1)-posSort(posI);
                diffPos=posSort(posI);
                                diffPos2=posSort(posI+1);

            end
        end
        gaps=zeros(diff,1);
        for posI=1:length(posSort)-1
            gapLength=(posSort(posI+1)-posSort(posI));
            gaps(gapLength)=gaps(gapLength)+1;
        end
        P01=sum(gaps)/sum(errSeq);
        gapCount=sum(gaps);
        errorCount=sum(errSeq);
        gaps=gaps/sum(gaps);
        [count index sum(errSeq) diff diffPos diffPos2 ]
        BER=errorCount/bitCount
        sum(errSeq(diffPos:diffPos2))
        EFR=zeros(diff,1);
        gapsCumul=cumsum(gaps);
        EFR(1)=P01;
        for i=2:length(EFR)
            EFR(i)=(1-gapsCumul(i-1))*P01;
        end
        
    end
    plotLimit=100;
        plot(gapsCumul(1:plotLimit))

    hold on
    %plot(1:diff,gaps(1:diff))
    plot(EFR(1:plotLimit))
    %plot(cumsum(gaps))
    hold off
end