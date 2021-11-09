clear all;
addpath '..\..\data'

clc
weatherFiles=["20200729_Weather_1000_24h.mat";"20200731_Weather_1000_24h.mat";"20200801_Weather_1200_24h.mat"];
choice=2;
filenameWeather = weatherFiles(choice);   %as appropriate
loadWeather = load(filenameWeather);
infmt='yyyy-MM-dd''T''HH:mm:ss.SSS';
%dataIndex=64;
 
dataW=loadWeather.weatherData;
startTime=datetime(dataW(2,1),'InputFormat',infmt)
fritchBase=2;
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
        trans = [0.65,0,0.25,0.1;
        0, 0.4,0.35,0.25;
        0.2,0.3,0.5,0;           
        0.15,0.25,0,0.6];
        emis=[1,0;1,0;0.7 0.3;0.1 0.8;];
        symbols=[0,1];
        p=[0.3 0.5 0.1 0.1];
        stateNames=["Good State" "Good State" "Error State" "Deep fade State"];
    otherwise
        trans = [0.8,0,0.2;
        0, 0.7,0.3;
        0.1,0.2,0.7];
        emis=[1,0;1,0;0 1;]
        symbols=[0,1];
        p=[0.5 0.4 0.1];
        stateNames=["Good State" "Good State" "Error State"];
end

filenameData = "MSIs"+datestr(startTime,30);   %as appropriate
load(filenameData);
for dataIndex=1:length(SIs)
    dataIndex
    ind=ceil((dataIndex)*timeToRead*3600);
    plotTime=datetime(dataW(ind,1),'InputFormat',infmt);

    resBin=cell2mat(resBins(dataIndex));
    resBinH=cell2mat(resBinsH(dataIndex));
    errSeqnf=cell2mat(errSeqs(dataIndex)).';
    errSeqnfH=cell2mat(errSeqsH(dataIndex)).';
    
    BER=BERS(dataIndex);
    BERH=BERSh(dataIndex);
    SI=SI_Ts(dataIndex,1);
    SIh=SIH_Ts(dataIndex,1);
    if(isnan(SI))
        continue;
    end
    if(BERS(dataIndex)==0||isnan(BERS(dataIndex)))
        continue
    end
    estTR=cell2mat(models(dataIndex,1));
     estE=cell2mat(models(dataIndex,2));
    estTRH=cell2mat(modelsH(dataIndex,1));
     estEH=cell2mat(modelsH(dataIndex,2));
     BER;
     [gapDistribution, EFR, gapsCumul,unscaledGaps] = runLengthDisitrbution(errSeqnf);
    [gapDistributionH, EFRH, gapsCumulH,unscaledGapsH] = runLengthDisitrbution(errSeqnfH);

    [errSeqnfF,~]=hmmgenerate(length(errSeqnf),estTR,estE,'Symbols',symbols);
    [errSeqnfHF,~]=hmmgenerate(length(errSeqnfH),estTRH,estEH,'Symbols',symbols);
    [~, EFRF, ~,~] = runLengthDisitrbution(errSeqnfF.');
    [~, EFRHF, ~,~] = runLengthDisitrbution(errSeqnfHF.');
    % estTR(1,:)=[];
    % estTR(:,1)=[];
    % estE(1,:)=[];
    % estTRH(1,:)=[];
    % estTRH(:,1)=[];
    % estEH(1,:)=[];

    h = figure;
    set(h, 'Visible', 'off');
    subplot(2,1,1)
    semilogx(EFR,'-*')
    hold on
    semilogx(EFRF,'-+')
    hold off
    title("EFR ")
    xlabel("length of interval m")
    ylabel('Pr(0^{m}|1)')
    legend('Observed EFR',"3 State Fritchman model");
    subplot(2,1,2)
    mc=dtmc(estTR,'StateNames',stateNames);
    graphplot(mc,'ColorEdges',true,'LabelEdges',true);
    title("Fritchman model")
    sgtitle(datestr(plotTime)+" Index: "+dataIndex+" BER:"+ BER+" S.I: "+SI)


        h1 = figure;
            set(h1, 'Visible', 'off');

    subplot(2,1,1)
    semilogx(EFRH,'-*')
    hold on
    semilogx(EFRHF,'-+')
    hold off
    title("EFR(H)")
    xlabel("length of interval m")
    ylabel('Pr(0^{m}|1)')
    legend('Observed EFR',"3 State Fritchman model");
    subplot(2,1,2)
    mcH=dtmc(estTRH,'StateNames',stateNames);
    graphplot(mcH,'ColorEdges',true,'LabelEdges',true);
    title("Fritchman model");
    sgtitle(datestr(plotTime)+" Index: "+dataIndex+" BER:"+ BERH+" S.I: "+SIh)

    saveas(h,datestr(plotTime,30),'fig')
    saveas(h,datestr(plotTime,30),'png')
    saveas(h1,"H"+datestr(plotTime,30),'fig')
    saveas(h1,"H"+datestr(plotTime,30),'png')
    BER;
end
