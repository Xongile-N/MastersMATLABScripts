clc
trans = [0.95,0.05;
      0.10,0.90];
emis = [1/6, 1/6, 1/6, 1/6, 1/6, 1/6;
   1/10, 1/10, 1/10, 1/10, 1/10, 1/2];
emis=[1,0;0.2 0.8]
symbols=[0,1]
seq1 = hmmgenerate(100,trans,emis,'Symbols',symbols);
seq2 = hmmgenerate(200,trans,emis,'Symbols',symbols);
seqs = {seq1,seq2};
[estTR,estE] = hmmtrain(seqs,trans,emis,'Symbols',symbols,'Verbose',true);

estTR
estE