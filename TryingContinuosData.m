%% GETTINGDATA Code for communicating with an instrument.
%
%   This is the machine generated representation of an instrument control
%   session. The instrument control session comprises all the steps you are
%   likely to take when communicating with your instrument. These steps are:
%   
%       1. Instrument Connection
%       2. Instrument Configuration and Control
%       3. Disconnect and Clean Up
% 
%   To run the instrument control session, type the name of the file,
%   GettingData, at the MATLAB command prompt.
% 
%   The file, GETTINGDATA.M must be on your MATLAB PATH. For additional information 
%   on setting your MATLAB PATH, type 'help addpath' at the MATLAB command 
%   prompt.
% 
%   Example:
%       gettingdata;
% 
%   See also SERIAL, GPIB, TCPIP, UDP, VISA, BLUETOOTH, I2C, SPI.
% 
%   Creation time: 02-Mar-2020 12:26:25

%% Instrument Connection

% Find a tcpip object.
obj1 = instrfind('Type', 'tcpip', 'RemoteHost', '192.168.0.20', 'RemotePort', 4000, 'Tag', '');

% Create the tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = tcpip('192.168.0.20', 4000);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.

%% Instrument Configuration and Control

% Configure instrument object, obj1.
set(obj1, 'Name', 'TCPIP-192.168.0.20');
set(obj1, 'RemoteHost', '192.168.0.20');
set(obj1, 'OutputBufferSize', 10000000);
set(obj1, 'InputBufferSize', 10000000);

%% Instrument Connection
set(obj1, 'Timeout', 5.0);
freq=5000000;
period=1/freq;
% Connect to instrument object, obj1.
fopen(obj1);

%% Instrument Configuration and Control

% Communicating with instrument object, obj1.
%preAmb=query(obj1,'WFMOUTPRE?')
%scale=query(obj1,'wfmo:ymu?')
scale=0.04 % scale on 2V/div and 50 Ohm termination
windowLength=0;
windowSize=0.01;
fprintf(obj1,'DATA:SOURCE CH2')
query(obj1,'DATA:SOURCE?')
%fprintf(obj1, 'CURVE?');
data2=[];
while(length(data2)<10000000)
    datLen=length(data2)
    fprintf(obj1, 'CURVE?');
    temp=[];
    tmpLen=0;
    temp=binblockread(obj1, 'int8')*scale;
    tmpLen=length(temp)
    data2 = [data2; temp];
    windowLength=windowLength+windowSize;

end
time=linspace(0,windowLength,length(data2));
length(data2)
length(time)
plot(time,data2)

%% Disconnect and Clean Up

% Disconnect from instrument object, obj1.
fclose(obj1);

%% Instrument Configuration and Control

% Configure instrument object, obj1.
set(obj1, 'Name', 'TCPIP-192.168.0.20');
set(obj1, 'RemoteHost', '192.168.0.20');

%% Disconnect and Clean Up

% The following code has been automatically generated to ensure that any
% object manipulated in TMTOOL has been properly disposed when executed
% as part of a function or script.

% Clean up all objects.
delete(obj1);
clear obj1;

