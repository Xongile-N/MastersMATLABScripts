function createSimVars(filename)

clearvars -except filename
RSParam=[0.05,10];
overheadThresh=1.3;
overheadThreshes=[1.1 1.2 1.3 1.4]
K=100;
iterationCount=200;
symbols=[0,1];
addBP=false;
delta=RSParam(1);
Q=RSParam(2);
useFullLTThroughput=false;
legendStrings=[];
decodeablesRange=3;
useCRC=true;
poly32=[32 26 23 22 16 12 11 10 8 7 5 4 2 1 0];
poly24=[24,22,20,19,18,16,14,13,11,10,8,7,6,3,1,0];
poly16=[16,15,2,0];
poly8=[8,7,6,4,2,1,0];
poly4=[4,1,0];
poly3=[3,1,0];
poly1=[1,0];
poly = poly32;
crcGen1 = comm.CRCGenerator(...
    'Polynomial', poly, ...
    'InitialConditions', 1, ...
    'DirectMethod', true, ...
    'FinalXOR', 1);
crcDetect1=comm.CRCDetector(...
    'Polynomial', poly, ...
    'InitialConditions', 1, ...
    'DirectMethod', true, ...
    'FinalXOR', 1);

NRS = 255;
KRS = 239;
[gpRS] = rsgenpoly(NRS,KRS,[],0);
useBits=true;
rsEncoder=comm.RSEncoder('CodewordLength',NRS,'MessageLength',KRS,"BitInput", useBits,"GeneratorPolynomial",gpRS);
rsDecoder=comm.RSDecoder('CodewordLength',NRS,'MessageLength',KRS,"BitInput", useBits,"GeneratorPolynomial",gpRS);
degreeBits=16;
KBits=16;
seedBits=16;
LTHeaderLength=degreeBits+KBits+seedBits;
fileNames=["dataWeak" "dataMod" "dataStrong" "data0" "data1" "data2"];
rytovs=[0.18,0.32,0.53,0.45,0.41,0.46]
fritchToUse=[1,4,5,6];
fritchCount=length(fritchToUse);
aveBers=zeros(fritchCount,1);
LFSRSeed=10000;%[0 1 1 0 0 1 0 0 ];
LFSRPoly=53256;%[1 0 1 1 1 0 0 0 ]


save(filename);
end