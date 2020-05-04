clear all
t=serialport('COM10',9600)
for count=1:10000
write(t,85,"uint8")
%write(t,mod(count,2),"uint8")
end
delete(t)