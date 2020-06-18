 values=real(out.Signal.data).';

 masterClock=100000000;
 decimFactor=10;
 sampleRate=masterClock/decimFactor;
valuesSim=values(1:end);
plotLower=100000000;
plotUpper=plotLower+10000000;
valuesSim=valuesSim(20000000:end);
%plot(valuesSim(plotLower:plotUpper))%
