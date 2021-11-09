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
fh1Child=fh1.Children;
fh2Child=fh2.Children;
fh3Child=fh3.Children;
fh4Child=fh4.Children;
fh5Child=fh5.Children;

fh1Child.Children;
fh1DataObjs=ans;
fh2Child.Children;
fh2DataObjs=ans;
fh3Child.Children;
fh3DataObjs=ans;
fh4Child.Children;
fh4DataObjs=ans;
fh5Child.Children;
fh5DataObjs=ans;

fh1X1=fh1DataObjs(1).XData;
fh1Y1=fh1DataObjs(1).YData;
fh1X2=fh1DataObjs(2).XData;
fh1Y2=fh1DataObjs(2).YData;
fh1X3=fh1DataObjs(3).XData;
fh1Y3=fh1DataObjs(3).YData;

fh2X1=fh2DataObjs(1).XData;
fh2Y1=fh2DataObjs(1).YData;
fh2X2=fh2DataObjs(2).XData;
fh2Y2=fh2DataObjs(2).YData;
fh2X3=fh2DataObjs(3).XData;
fh2Y3=fh2DataObjs(3).YData;

fh3X1=fh3DataObjs(1).XData;
fh3Y1=fh3DataObjs(1).YData;
fh3X2=fh3DataObjs(2).XData;
fh3Y2=fh3DataObjs(2).YData;
fh3X3=fh3DataObjs(3).XData;
fh3Y3=fh3DataObjs(3).YData;

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


fh1.Children.Children;
 fh1Child=ans;
 fh2.Children.Children;
  fh2Child=ans;
  fh3.Children.Children;
 fh3Child=ans;
  f=figure;

t=tiledlayout(3,16)
dim1=[1,8];
dim2=[3,8];
dim3=[2,8];
axEP=nexttile(dim1);
plot(fh4X3,fh4Y3,'LineWidth',2)
hold on
plot(fh4X2,fh4Y2,'LineWidth',2)
plot(fh4X1,fh4Y1,'LineWidth',2)
set(gca,'xtick',[])
set(gca,'ytick',[])

axEFR=nexttile(dim2);
hold on
copyobj(fh1Child,axEFR);
copyobj(fh2Child,axEFR);
copyobj(fh3Child,axEFR);
currAxis=gca;
set(currAxis,'xscale','log')
h=get(currAxis,'Children');
legendString= ["C-" "C-" "C-" "B-" "B-" "B-" "A-" "A-" "A-"];
for count =1:9
    legendString(count)=strcat(legendString(count),h(10-count).DisplayName);
    h(count).LineStyle=lineStyles(count);
    h(count).LineWidth=lineWidths(count);
   % h(count).Color=defaultColors(newcolors(count),:);
end
%set(currAxis,'yscale','log')
legend(legendString);
   ylabel('Pr(0^{m}|1)')
xlabel("length of interval (m)")

axEC=nexttile(dim3);

plot(fh5X3,fh5Y3,'LineWidth',2)
hold on
plot(fh5X2,fh5Y2,'LineWidth',2)
plot(fh5X1,fh5Y1,'LineWidth',2)
ylabel('BER')
xlabel("Time (s)")

close(fh1);
close(fh2);
close(fh3);
close(fh4);
close(fh5);