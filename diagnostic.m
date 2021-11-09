
headerToCheck=115;
posToCheck=1;
lengthToCheck=15;
lengthBefore=24;
packet=resBin(headersCleaned(headerToCheck):headersCleaned(headerToCheck)+bitCount-1);
errSeq=bitxor(packet,packetStream.');
pos=find(errSeq);
debugBit=pos(posToCheck)+headersCleaned(headerToCheck)-1;
toFind=packet(pos(posToCheck):pos(posToCheck)+lengthToCheck);
posF=strfind(packetStream.',toFind);

test=bitxor(packet(pos(posToCheck)-lengthBefore:pos(posToCheck)+lengthToCheck),[packetStream(pos(posToCheck)-lengthBefore:pos(posToCheck)-1).' packetStream(posF(1):posF(1)+lengthToCheck).']);
%sum(test)
%pos(posToCheck)
%posF(1)

pos(posToCheck)-posF(1)
debugBit=pos(posToCheck)+headersCleaned(headerToCheck)-1;