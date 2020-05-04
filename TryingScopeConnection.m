scope = instrfind('Type', 'tcpip', 'RemoteHost', '192.168.0.21', 'RemotePort', 5555, 'Tag', '');
% Create the tcpip object if it does not exist
% otherwise use the object that was found.
if isempty(scope)
    scope = tcpip('192.168.0.21', 5555);
else
    fclose(scope);
    scope = scope(1);
end
% Connect to instrument object, scope.
fopen(scope);
%% Instrument Configuration and Control
% Communicating with instrument object, scope.
data=query(scope, '*IDN?')
