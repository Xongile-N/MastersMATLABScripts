clear all;   
frameLen=2500;
baseSampleRate=100000000;
decim=4;
sampleRate=baseSampleRate/decim
timePerFrame=frameLen/sampleRate
timePerPoint=timePerFrame/frameLen
totalTime=2;    
frequency=1000000;
totalTime=4;
rx_SDRu = comm.SDRuReceiver('Platform','N200/N210/USRP2', ...
        'IPAddress','192.168.10.5', ...
        'CenterFrequency',0, ...
            'Gain', 4, ...
        'DecimationFactor',decim, ...
        'SamplesPerFrame',frameLen,...
    'OutputDataType','single');
%             radio = comm.SDRuReceiver(...
%                 'Platform',             prmQPSKReceiver.Platform, ...
%                 'IPAddress',            prmQPSKReceiver.Address, ...
%                 'CenterFrequency',      prmQPSKReceiver.USRPCenterFrequency, ...
%                 'Gain',                 prmQPSKReceiver.USRPGain, ...
%                 'DecimationFactor',     prmQPSKReceiver.USRPDecimationFactor, ...
%                 'SamplesPerFrame',      prmQPSKReceiver.USRPFrameLength, ...
%                 'OutputDataType',       'double');
    rx_log = dsp.SignalSink;
    %rx_SDRu.CenterFrequency=0;
    info(rx_SDRu)
    counter=0
    data=complex(zeros(frameLen,1));
    timeElapsed=0;
    while timeElapsed <totalTime
     % data = rx_SDRu();
      [data,len]=step(rx_SDRu);
      if(len>0)
        rx_log(data);
        timeElapsed=timeElapsed+timePerFrame
      end
    end

    values=rx_log.Buffer;
    values_real=real(values);
         timeScale=linspace(0,totalTime,length(values));

    plot(timeScale,values_real)
    max(values_real)
    release(rx_SDRu);
    