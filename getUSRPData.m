 values=real(out.Signal.data).';
upper=0.45;%get rid of spikes
 masterClock=100000000;
 decimFactor=10;
 sampleRate=masterClock/decimFactor;
 twoSec=2*sampleRate;

valuesSim=values(1:end);
plotLower=100000000;
plotUpper=plotLower+10000000;
valuesSim=valuesSim(twoSec:end);
pos=find(valuesSim>upper);
valuesSim(pos)=upper;
plot(valuesSim(1:10000000))%

