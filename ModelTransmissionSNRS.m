clear all;
clc

bitCount=1000000;
transmitFreq=1e5;
samplesPerClock=4;
samplingFreq=transmitFreq*4*samplesPerClock;
upSampleFreq=samplingFreq*3;
LFSRSeed=[1 0 1 0 1 1 1 0 1 0 1 0 1 0 0];
LFSRPoly=[15 14 0];

bitStream=LFSR(LFSRSeed, LFSRPoly,bitCount);
waveFormTX=OOK(bitStream,transmitFreq,samplingFreq);
%axis([0 length(waveFormTX)+10 -0.5 1.5]);
%[resBin,~,~]=clockRecovery(waveFormTX,transmitFreq,samplingFreq,true,true,0.05);


 turbulence=turbulenceModel(samplingFreq,length(waveFormTX), upSampleFreq, false);
 SNRS=(1:12);
BERS=zeros(6,length(SNRS));
Errors=zeros(2,length(SNRS),length(bitStream));
thresholds=BERS;
types=[ 0 0 1 0 0 1;...
    0 1 0 0 1 0];
resBins=zeros(6,bitCount);
frameSize=1000;
OrigFrames=reshape(bitStream,floor(frameSize),[]).';
maxErrors=zeros(size(BERS));
ErrorCount=maxErrors;
packetErrors=zeros(6,length(SNRS),bitCount/frameSize);
size(packetErrors)
for count=1:6
    count
    if(count<4)
        waveFormRX=2*waveFormTX.';
    else
        waveFormRX=2*(waveFormTX.').*turbulence;
    end
    
    for index =1:length(SNRS)
     waveFormRXA=awgn(waveFormRX,SNRS(index)); 
    [resBin,thresholds(count,index)]=clockRecoveryFrame(waveFormRXA,transmitFreq,samplingFreq,true, types(1,count), frameSize, types(2,count));
     [ErrorCount(count,index),BERS(count,index),Errors(count,index,:)]=biterr(resBin,bitStream);
     frames=reshape(resBin,floor(frameSize),[]).';
     errorCounts=biterr(frames,OrigFrames,[],'row-wise');
     packetErrors(count,index,:)=errorCounts;
     maxErrors(count,index)=max(errorCounts);
     resBins(count,:)=resBin;
    end
end

maxErrors
ErrorCount
BERS

legendStrings=cell(size(BERS,1),1);

semilogy(SNRS,BERS(1,:), '-*');
hold on

legendStrings{1}=['AWGN Mean threshold'];

semilogy(SNRS,BERS(2,:), '-*');
legendStrings{2}=['AWGN 0.5 threshold'];
semilogy(SNRS,BERS(3,:), '-*');
legendStrings{3}=['AWGN Mean threshold on frames'];
semilogy(SNRS,BERS(4,:), '-*');
legendStrings{4}=['AWGN + Turbulence Mean threshold'];


semilogy(SNRS,BERS(5,:), '-*');
legendStrings{5}=['AWGN + Turbulence 0.5 threshold'];
    
semilogy(SNRS,BERS(6,:), '-*');
legendStrings{6}=['AWGN + Turbulence Mean threshold on frames'];

grid
ylabel('BER');
xlabel('SNR(dB)');
legend(legendStrings);
hold off;
