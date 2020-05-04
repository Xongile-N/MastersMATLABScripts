function [timeBase,fundFreq, freqStep]=quickFFT(data, sampleFrequency)
Fs=sampleFrequency;
T=1/Fs;
L=length(data);
timeBase = (0:L-1)*T;  
Y = fft(data);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
P1(1)
P1(1)=0;
f = Fs*(0:(L/2))/L;
freqStep=f(2);
resolution=f(11)-f(10)
plot(f,P1) 
[val,idx]=max(P1)
fundFreq=f(idx);
f(idx-1:idx+1)
P1(idx-1:idx+1)
disp("fundFreq= "+num2str(fundFreq,'%.0f'))
period=1/fundFreq
cycles=period*600000000
periodDes=1/1000000
delta=(periodDes-period)*10^9
end