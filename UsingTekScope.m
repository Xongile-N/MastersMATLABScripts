clear all
scope = visa('tek','TCPIP::192.168.0.20::INSTR');
fopen(scope);
get(scope,{'EOSMode','EOIMode'})

fprintf(scope,'*IDN?');
idn=fscanf(scope)
%fprintf(scope,'MEASUREMENT:IMMED:SOURCE?')
%source=fscanf(scope)

fprintf(scope,'MEASUREMENT:MEAS1:TYPE MINIMUM')
fprintf(scope,'MEASUREMENT:MEAS1:TYPE?')
type=fscanf(scope)
fprintf(scope,'MEASUREMENT:MEAS1:VALUE?')
value=fscanf(scope)
%fprintf(scope,'MEASUREMENT:MEAS1:UNITS?')
%units=fscanf(scope)
fclose(scope)
delete(scope)

clear scope