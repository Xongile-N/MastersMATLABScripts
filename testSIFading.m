filename = '20200724_Fading_1114_1Mhz.bin';   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end    
data = fread(fid, inf, '*float32');
  respons=0.3;
  dataStart=1;;
  dataEnd=60*1e6;
recorded=data(dataStart:dataEnd);
expected=expectedValue(recorded);
normalR=recorded./expected;
nbins=100;
h=histogram(normalR,nbins,'Normalization','pdf');
xlim([0,3]);
ylabel('p(I)');
xlabel('Normalised Irradiance, I/E[I]');
%[SI,meanWave,meanSquare]=ScintIndex1(recorded,respons,0);