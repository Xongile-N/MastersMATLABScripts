%The Gamma-gamma pdf 
laserDir=360*15/16;

waveLength=520e-9;
linkLength=300;

% dataW=loopWeather;
% timeStr=dataW(1:end,1);
% WSStr=dataW(1:end,2);
% WDStr=dataW(1:end,3);
% WDNum=str2double(WDStr);
% WSNum=str2double(WSStr);
% for count=2:length(WDNum)
%     if(isnan(WDNum(count)))
%         WDNum(count)=WDNum(count-1);
%     end
%     if(isnan(WSNum(count)))
%         WSNum(count)=WSNum(count-1);
%     end
% end
% WDNumAdj=abs(WDNum-laserDir);
% perp=abs(sind(WDNumAdj));
% pos=find(WSNum==0);
% posAdj=pos-1;
% WSNum(pos)=WSNum(posAdj);
% perpWS=WSNum.*perp;
% corrTimeDec=(sqrt(waveLength*linkLength));
% corrTimeEg=corrTimeDec/5;
% corrTime=corrTimeDec./perpWS;
% infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
% timeNum=datetime(timeStr,'InputFormat',infmt);
% time=str2double(timeStr).';
% temp=str2double(dataW(1:end,4)).';
% temp=temp+273.15;
% laserDir=360*15/16;
% pressure=str2double(dataW(1:end,9)).';
% 
% clc
% 
% k=2*pi/waveLength;
% L=150;
% CtSqr=1;
% 
% exT=expectedValue(temp);
% exP=expectedValue(pressure);
% CnSqr=(79e-6*exP/exT^2)^2*CtSqr;
CnSqr=1e-15 ;

sigLSqr=0.55;
alphaW=1.23
sigLSqr=alphaW*CnSqr*k^(7/6)*L^(11/6)
R=sigLSqr;
A=(0.49*R)/(1+1.11*R^(6/5))^(7/6); 
B=(0.51*R)/(1+0.69*R^(6/5))^(5/6); 
alpha=1/(exp(A)-1);
a=alpha;
beta=1/(exp(B)-1);
sigNSqr=exp(A+B)-1
b=beta;



