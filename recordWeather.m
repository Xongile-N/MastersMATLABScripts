weatherData=["Timestamp"]
res=webread("http://weather.wits.ac.za/?command=DataQuery&uri=HttpDataloggerSource%3APublic&format=json&mode=most-recent");
seconds=3600*24
seconds=300
searchQueries=["Windsonic_WS" "Windsonic_WD" "EE180_AirTemp" "EE180_RH" "CS320_SlrW" "TR525USW_Rain" "AQT400_HUM" "PTB110_BPress" "AQT400_PM2point5" "AQT400_PM10"]
weatherData=["Timestamp" searchQueries]    
searchQueryIndex=zeros(size(searchQueries))
for count =1:length(searchQueries)
    for fieldCount=1:length(res.head.fields)
        cell=res.head.fields(fieldCount);
        if(getfield(cell{1},"name")==searchQueries(count))
            searchQueryIndex(count)=fieldCount;
            break;
        end

    end
end
disp('recording')
for i = 1 : seconds
    startTime = tic;
    res=webread("http://weather.wits.ac.za/?command=DataQuery&uri=HttpDataloggerSource%3APublic&format=json&mode=most-recent");
    dataFields=res.data.vals(searchQueryIndex).';
    
    weatherData(end+1,1)=res.data.time;
        weatherData(end,2:end)=dataFields;

    elapsedTime = toc(startTime); % In seconds
    while  elapsedTime < 1
        elapsedTime = toc(startTime); % In seconds
    end
    
end
save("weather.mat","weatherData");