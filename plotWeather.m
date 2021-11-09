filenameWeather = '20200801_Weather_1200_24h.mat';   %as appropriate
loadWeather = load(filenameWeather);
dataW=loadWeather.weatherData;
laserDir=360*15/16;
linkLength=150;
waveLength=520e-9;
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
subplot(3,1,1)
plot(timeNum,temp)
subplot(3,1,2)

plot(timeNum,perpWS)
subplot(3,1,3)

plot(timeNum,corrTime)

