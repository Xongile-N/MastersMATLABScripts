clear all
clc
addpath '..\..\data'
addpath '..\..\Figures\Paper'
 fh1 = openfig('FadeLog.fig','invisible' );
 fh2 = openfig('FadeModLog.fig','invisible' ); 
 fh3 = openfig('FadeStrongLog.fig','invisible' );

fh1.Children.Children;
 fh1Child=ans;
 fh2.Children.Children;
  fh2Child=ans;
  fh3.Children.Children;
 fh3Child=ans;

fh1X1=fh1Child(1).XData;
fh1Y1=fh1Child(1).YData;
fh1X2=fh1Child(2).XData;
fh1Y2=fh1Child(2).YData;

fh2X1=fh2Child(1).XData;
fh2Y1=fh2Child(1).YData;
fh2X2=fh2Child(2).XData;
fh2Y2=fh2Child(2).YData;

fh3X1=fh3Child(1).XData;
fh3Y1=fh3Child(1).YData;
fh3X2=fh3Child(2).XData;
fh3Y2=fh3Child(2).YData;

%newcolors = {'#F00','#F80','#FF0','#0B0','#00F','#50F','#A0F','#000','#BBB'};
defaultColors=[0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250 ;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880;0.3010 0.7450 0.9330;0.6350 0.0780 0.1840;]
newcolors=[1 0 0; 1 0 0; 1 0 0; 0 1 0; 0 1 0; 0 1 0; 0 0 1; 0 0 1 ;0 0 1];
newcolors=[1;1;2;2;3;3];
markers=["none" "none" "*" "none" "none" "*" "none" "none" "*"];
lineStyles=[ ":" "-"  ":" "-"  ":" "-"];
lineWidths=[ 3 1  3 1  3 1];
legendFig=figure();
ax = axes(legendFig);
%colororder(
hold on

copyobj(fh1Child,ax);
copyobj(fh2Child,ax);
copyobj(fh3Child,ax);
currAxis=gca;




hold off
currAxis=gca;
%set(currAxis,'xscale','log')
h=get(currAxis,'Children')
legendString= ["" "" "" "" "" "" ];
 for count =1:6
     legendString(count)=strcat(legendString(count),h(7-count).DisplayName);
     h(count).Color=defaultColors(newcolors(count),:);
    % h(count).Marker=markers(count);
     h(count).LineStyle=lineStyles(count);
      h(count).LineWidth=lineWidths(count);

%     %h(count).Color=[1 1 1];
 end
 
set(currAxis,'yscale','log')
legend(legendString);
  ylabel('PDF')
  fontHeightmm=3.175;

  currAxis.FontUnits="centimeters"
  currAxis.FontSize=fontHeightmm/10;
  %  currAxis.Legend.FontUnits="centimeters"

xlabel("Log Irradiance")
xlim([-4 8])
close(fh1);
close(fh2);
close(fh3);