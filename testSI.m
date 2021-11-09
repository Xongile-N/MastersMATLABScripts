clear all;
Rytov=3.5;
sampleCount=1e6;
limit=8;
[turbulence,SI]=gammaTurb(Rytov,sampleCount,limit);
nBins=100;

[I,gammaPDF,SI]=gammaDist(Rytov,nBins,limit);
h=histogram(turbulence.',nBins,'Normalization','pdf','DisplayStyle','stairs');
hold on
plot(I,gammaPDF)
hold off

           [SI_T,~,~]=ScintIndex1(turbulence,1, -1);
