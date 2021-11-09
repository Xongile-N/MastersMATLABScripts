clear all
clc
addpath '..\..\data'
addpath '..\..\Figures\Paper'
fh1 = openfig('EFR.fig','invisible' );
fh2 = openfig('EFRMod.fig','invisible' ); 
fh3 = openfig('EFRStrong.fig','invisible' );
fh4 = openfig('ErrorPlot.fig','invisible' );
fh5 = openfig('ErrorCorr.fig','invisible' ); 
lineStyles=[ ":" ":" ":" "--" "--" "--" "-" "-" "-"];
lineWidths=[ 3 3 3 3 3 3 3 3 3];
% 
% fh1.Children.Children;
% fh1Child=ans;
% fh2.Children.Children;
% fh2Child=ans;
% fh3.Children.Children;
% fh3Child=ans;
% fh4.Children.Children;
% fh4Child=ans;
% fh5.Children.Children;
% fh5Child=ans;
fh4Child=fh4.Children;
fh5Child=fh5.Children;

fh4Child.Children;
fh4DataObjs=ans;
fh5Child.Children;
fh5DataObjs=ans;


fh4X1=fh4DataObjs(1).XData;
fh4Y1=fh4DataObjs(1).YData;
fh4X2=fh4DataObjs(2).XData;
fh4Y2=fh4DataObjs(2).YData;
fh4X3=fh4DataObjs(3).XData;
fh4Y3=fh4DataObjs(3).YData;

fh5X1=fh5DataObjs(1).XData;
fh5Y1=fh5DataObjs(1).YData;
fh5X2=fh5DataObjs(2).XData;
fh5Y2=fh5DataObjs(2).YData;
fh5X3=fh5DataObjs(3).XData;
fh5Y3=fh5DataObjs(3).YData;

  f=figure;

t=tiledlayout(3,8)
dim1=[1,8];
dim3=[2,8];
axEP=nexttile(dim1);
plot(fh4X3,fh4Y3,'LineWidth',2)
hold on
plot(fh4X2,fh4Y2,'LineWidth',2)
plot(fh4X1,fh4Y1,'LineWidth',2)
set(gca,'xtick',[])
set(gca,'ytick',[])
legendString= ["Log Normal" "Observed" "Fritchman Model"];

axEC=nexttile(dim3);
plot(fh5X3,fh5Y3,'LineWidth',2)
hold on
plot(fh5X2,fh5Y2,'LineWidth',2)
plot(fh5X1,fh5Y1,'LineWidth',2)
ylabel('BER')
xlabel("Time (s)")
legend(legendString);

close(fh4);
close(fh5);