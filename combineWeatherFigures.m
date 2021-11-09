clear all
clc
filenameWeather = 'weather20200731T080150.mat';   %as appropriate
load(filenameWeather);
 f=figure;
% subplot(3,1,1)
% plot(timeBaseAdj,SIs(:,1))
% subplot(3,1,2)
% plot(timeBaseAdj,tempAdj)
% subplot(3,1,3)
% plot(timeBaseAdj,perpWSAdj)
t=tiledlayout(3,1)

nexttile
plot(timeBaseAdj,SIs(:,1),'LineWidth',2)
ylabel("SI")
set(gca,'xtick',[])

nexttile
plot(timeBaseAdj,tempAdj,'LineWidth',2)
ylabel("T(^oC)")
set(gca,'xtick',[])

nexttile
plot(timeBaseAdj,perpWSAdj,'LineWidth',2)
ylabel("u (m/s)")


xlabel(t,'Time')
t.Padding = 'none';
t.TileSpacing = 'none';
%close(f)