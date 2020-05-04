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

% Connect to instrument object, obj1.
fopen(obj1);

%% Instrument Configuration and Control

% Communicating with instrument object, obj1.
preAmb=query(obj1,'WFMOUTPRE?')
%IDN=query(obj1,'*IDN?')
fclose(obj1);
delete(obj1);
clear obj1;