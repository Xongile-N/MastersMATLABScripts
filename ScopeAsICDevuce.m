clear all
fileID=fopen('rec.bin','w')
scopeObj = visa('tek','TCPIP::192.168.0.20::INSTR');
% fopen(scope);
% get(scope,{'EOSMode','EOIMode'})
% 
% fprintf(scope,'*IDN?');
% idn=fscanf(scope)
% fprintf(scope,'DATA:SOURCE CH1')
% fprintf(scope,'DATA:ENCDG SRIBINARY')
% %fprintf(scope,'DATA:ENCDG ASCII')
% 
% fprintf(scope,'DATA:ENCDG?')
% 
% source=fscanf(scope)
% fprintf(scope,'WFMOUTPRE?')
% dataFormat=fscanf(scope)
% fprintf(scope,'CURVE?')
% data=fscanf(scope)
% fwrite(fileID,data)
fclose(fileID)
fclose(scopeObj)
delete(scopeObj)
%plot(data)
clear scope