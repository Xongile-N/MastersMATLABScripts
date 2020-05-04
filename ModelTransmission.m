clear all;
clc
bitCount=10000000;
transmitFreq=1e6;
samplesPerClock=3;
samplingFreq=transmitFreq*4*samplesPerClock;
upSampleFreq=samplingFreq*6;
LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
LFSRPoly=[15 14 0];

bitStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
waveFormTX=OOK(bitStream,transmitFreq,samplingFreq);
%axis([0 length(waveFormTX)+10 -0.5 1.5]);
%[resBin,~,~]=clockRecovery(waveFormTX,transmitFreq,samplingFreq,true,true,0.05);


 turbulence=turbulenceModel(samplingFreq,length(waveFormTX), upSampleFreq, false);
 waveFormRX=(waveFormTX.').*turbulence;
 AWGNSnrs=(3:8)*2;
%  subplot(3,1,1)
%  plot(waveFormTX)
%  title('Transmitted waveform')
%  subplot(3,1,2)
%  plot(turbulence)
%  title('Turbulence')
%   subplot(3,1,3)
% plot(waveFormRX);
%  title('Received waveform')
% axis([0 length(waveFo)rmTX)+10 -0.5 1.5]);
sigMean=mean(waveFormRX);

thresholds=linspace(0,sigMean,10);
thresholdsA=zeros(length(AWGNSnrs),10);
BERS=zeros(10,1);
Errors=zeros(10,length(bitStream));

BERSA=zeros(length(AWGNSnrs),10);
ErrorsSA=zeros(10,length(bitStream));
for count=1:10
 [resBin,~,~]=clockRecovery(waveFormRX,transmitFreq,samplingFreq,true,true,thresholds(count));
 [~,BERS(count),~]=biterr(resBin,bitStream);
%     for index=1:length(AWGNSnrs)
%      waveFormRXA=awgn(waveFormRX,AWGNSnrs(index));
%      waveFormRXA=waveFormRXA.*(waveFormRXA>0);
%      sigMeanA=mean(waveFormRXA);
%      thresholdsA(index,:)=linspace(0,sigMeanA,10);
%      [resBinA,~,~]=clockRecovery(waveFormRXA,transmitFreq,samplingFreq,true,true,thresholds(count));
%      [~,BERSA(index,count),~]=biterr(resBinA,bitStream);
%     end
%  %errors=find(comp);
%  %BERNum
%  %BER
end
semilogy(thresholds,BERS, '+');
legendStrings=cell(1+length(AWGNSnrs),1);
legendStrings{1}=['Turbulence only'];
hold on
    for index=1:length(AWGNSnrs)

        semilogy(thresholdsA(index,:),BERSA(index,:), '-*');
        legendStrings{1+index}=['Turbulence and AWGN. SNR: ', num2str(AWGNSnrs(index)), ' dB'];    
    end
grid
ylabel('BER');
xlabel('Modulation threshold');
legend(legendStrings);
