clear all
fileID=fopen('rec.bin','w')
scope = visa('tek','TCPIP::192.168.0.20::INSTR');
fopen(scope);
get(scope,{'EOSMode','EOIMode'})

fprintf(scope,'*IDN?');
idn=fscanf(scope)
fprintf(scope,'DATA:SOURCE CH1')
fprintf(scope,'DATA:ENCDG SRIBINARY')
%fprintf(scope,'DATA:ENCDG ASCII')

fprintf(scope,'DATA:ENCDG?')

source=fscanf(scope)
fprintf(scope,'WFMOUTPRE?')
dataFormat=fscanf(scope)
fprintf(scope,'CURVE?')
data=fscanf(scope)
fwrite(fileID,data)
fclose(fileID)
fclose(scope)
delete(scope)
%plot(data)
clear scope