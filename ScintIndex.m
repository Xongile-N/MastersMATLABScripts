function SI = ScintIndex(weather,waveLength)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

laserDir=360*15/16;

linkLength=300;
dataW=weather;
timeStr=dataW(2:end,1);
WSStr=dataW(2:end,2);
WDStr=dataW(2:end,3);
WDNum=str2double(WDStr);
WSNum=str2double(WSStr);
for count=2:length(WDNum)
    if(isnan(WDNum(count)))
        WDNum(count)=WDNum(count-1);
    end
    if(isnan(WSNum(count)))
        WSNum(count)=WSNum(count-1);
    end
end
WDNumAdj=abs(WDNum-laserDir);
perp=abs(sind(WDNumAdj));
pos=find(WSNum==0);
posAdj=pos-1;
WSNum(pos)=WSNum(posAdj);
perpWS=WSNum.*perp;
corrTimeDec=(sqrt(waveLength*linkLength));
corrTimeEg=corrTimeDec/5;
corrTime=corrTimeDec./perpWS;
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
timeNum=datetime(timeStr,'InputFormat',infmt);
time=str2double(timeStr).';
temp=str2double(dataW(2:end,4)).';

%temp=temp+273.15;
pressure=str2double(dataW(1:end,9)).';


k=2*pi/waveLength;
L=linkLength;
CtSqr=2e-6;

exT=expectedValue(temp);
exP=expectedValue(pressure);
CnSqrN=(79e-6*exP/exT^2)^2;
CnSqr=CnSqrN*CtSqr;
CnSqr=4.1e-13;

%sigLSqr=0.55;
alphaW=1.23;
sigLSqr=alphaW*CnSqr*k^(7/6)*L^(11/6);
R=sigLSqr;
A=(0.49*R)/(1+1.11*R^(6/5))^(7/6); 
B=(0.51*R)/(1+0.69*R^(6/5))^(5/6); 

SI=exp(A+B)-1;
end

