clear all;
frequency=2000;

masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;


infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
filenameWeather = '20200731_Weather_1000_24h.mat';   %as appropriate
loadWeather = load(filenameWeather);
dataW=loadWeather.weatherData;
startTime=datetime(dataW(2,1),'InputFormat',infmt)

totalHours=24;
hoursToRead=24;
minutesToRead=0;
timeToRead=hoursToRead+minutesToRead/60;
readAmount=3600*timeToRead;
laserDir=360*15/16;
linkLength=150;
waveLength=520e-9;


    weather=dataW(timeToRead*3600*(count-1)+2:timeToRead*3600*(count-1)+readAmount,:);
    timeStr=weather(1:end,1);
    WSStr=weather(1:end,2);
    WDStr=weather(1:end,3);
    WDNum=str2double(WDStr);
    WSNum=str2double(WSStr);
    loopTime=startTime+hours(timeToRead)*(count-1);
    for iCount=2:length(WDNum)
        if(isnan(WDNum(iCount)))
            WDNum(iCount)=WDNum(iCount-1);
        end
        if(isnan(WSNum(iCount)))
            WSNum(iCount)=WSNum(iCount-1);
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
    temp=str2double(weather(1:end,4)).';
    h = figure;
    set(h, 'Visible', 'off');
    subplot(2,2,1)
    plot(timeNum,temp)
    title("Temperature ")
    xlabel("Time")
    ylabel("Temperature ( C^{o})")
        subplot(2,2,4)
    plot(timeNum,WSNum)
        title("wind speed ")
    xlabel("Time")
    ylabel("Wind Speed (m/s)")
    
    subplot(2,2,2)

    plot(timeNum,perpWS)
        title("Perpendicular wind speed")
    xlabel("Time")
    ylabel("Wind Speed (m/s)")
    subplot(2,2,3)

    plot(timeNum,corrTime)
        title("Correlation time")
    xlabel("Time")
    ylabel("Correlation time (s)")
    sgtitle(datestr(loopTime))

    
    saveas(h,datestr(loopTime,30)+"Weather",'fig')
    saveas(h,datestr(loopTime,30)+"Weather",'png')

    saveas(h,"H"+datestr(loopTime,30)+"Weather",'fig')
    saveas(h,"H"+datestr(loopTime,30)+"Weather",'png')

