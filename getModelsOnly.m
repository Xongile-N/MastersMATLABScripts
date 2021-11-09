clear all;
addpath '..\..\data'

clc
setChoice=1;
rytovs=[0.18 0.35 0.44];
rytov=rytovs(setChoice);
fileNames=["dataWeak" "dataMod" "dataStrong"];
filenameData =fileNames(setChoice);  %as appropriate

fritchBase=3;
switch(fritchBase)
    case 1
        trans = [0.65,0,0.25,0.1;
        0, 0.4,0.35,0.25;
        0.2,0.3,0.5,0;           
        0.1,0.15,0,0.75];
        emis=[1,0;1,0;0 1;0 1;];
        symbols=[0,1];
        p=[0.3 0.5 0.1 0.1];
        stateNames=["Good State" "Good State" "Error State" "Deep fade State"];
    case 2      
        trans = [0.7,0,0.3;
        0, 0.5,0.5;
        0.1,0.2,0.7];
        emis=[1,0;1,0;0 1;]
        symbols=[0,1];
        p=[0.5 0.4 0.1];
        stateNames=["Good State" "Good State" "Error State"];
    case 3      
        trans = [0.85,0,0,0.15;
        0, 0.5,0,0.5;
        0,0,0.2,0.8;           
        0.15,0.15,0.1,0.6];
        emis=[1,0;1,0;1 0;0 0.1];
        symbols=[0,1];
        p=[0.5 0.3 0.1 0.1];
        stateNames=["Good State" "Good State" "Good State" "Error State"];
    otherwise
        trans = [0.8,0,0.2;
        0, 0.7,0.3;
        0.1,0.2,0.7];
        emis=[1,0;1,0;0 1;]
        symbols=[0,1];
        p=[0.5 0.4 0.1];
        stateNames=["Good State" "Good State" "Error State"];
end

tol=1e-6;
maxIter=40;
emis_hat = [zeros(1,size(emis,2)); emis];
trans_hat = [0 p; zeros(size(trans,1),1) trans];

load(filenameData);


    [estTR,estE,logLik] = hmmtrain(errSeqH.',trans_hat,emis_hat,'Symbols',symbols,'Verbose',true,'Tolerance',tol,'maxIterations',maxIter);
    [errSeqHF,~]=hmmgenerate(length(errSeqH),estTR,estE,'Symbols',symbols);
    [~, efrFritch, ~,~] = runLengthDisitrbution(errSeqHF.');
        [~, efrObs, ~,~] = runLengthDisitrbution(errSeqH);  
    avgBERO=mean(errSeqH)
    avgBEROF=mean(errSeqHF)

    f=figure;
    semilogx(efrObs,'k')
    hold on
    %semilogx(EFRF,'-*')
    %semilogx(EFRFF,'-*')
    semilogx(efrFritch,'r')
    hold off
    
save("data.mat","x","y","w","xAdj","xH","yH","wH","xHAdj","tailored","tailoredH","errSeq","errSeqnf","errSeqH","errSeqnfH","errSeqnfH","errSeqH","estTR","estTRH","estE","estEH")

