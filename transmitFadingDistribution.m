clear all;
filename = '20200724_Fading_1114_1Mhz.bin';   %as appropriate
addpath '..\..\data'

Fs = 1000000;          %1 megabit/s data rate for basic DPSK ?
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end
data = fread(fid, inf, '*float32');
fclose(fid);
recTime=300;

SR=1000000;
valuesSim=data(1:SR*recTime);
valuesSim(valuesSim<0)=0;
E=expectedValue(valuesSim);
           [SI_T,~,~]=ScintIndex1(valuesSim,1, -1);

valuesSim=valuesSim/E;
nBins=500;
GG=@(r,x) gammaSample(r,x);
Ln=@(r,x) LNSample(r,x);

h=histogram(valuesSim,nBins,'Normalization','pdf','DisplayStyle','stairs');
x=h.BinEdges;
y=h.Values;
w=h.BinWidth;
xAdj=x(1:end-1)+w;
plot(xAdj,y)
hold on
%mdlGG=fitnlm(xAdj,y,GG,SI_T);
mdlLn=fitnlm(xAdj,y,Ln,0.2);
line(xAdj.',predict(mdlLn,xAdj.'),'Color','r');

%[turbVec,sigNSqr]=gammaTurb(0.2,1000000,3);
 %[turbVec,sigNSqr]=LNTurb(SI_T,1000000,5);

%h1=histogram(turbVec,nBins,'Normalization','pdf','DisplayStyle','stairs');
ylabel('PDF');

legend("Observed sequence","Log Normal Weak Turbulence SI="+mdlLn.Coefficients.Estimate);
xlabel('Intensity (Normalised to mean)');
hold off

