masterClock=100000000;
decimFactor=500;
sampleRate=masterClock/decimFactor;

filename = '20200728_Transmit_1830_200Khz_2Khz_100K.bin';   %as appropriate
[fid, msg] = fopen(filename, 'r');
if fid < 0
    error('Failed to open file "%s" because "%s"', filename, msg);
end
readAmount=sampleRate*3600;
ftell(fid)
data = fread(fid, readAmount, '*float32');
ftell(fid)

fclose(fid);
length(data)/sampleRate
