clear all
clc
addpath '..\..\data'
addpath '..\..\Figures\Paper'
fig = openfig('EFR.fig','invisible' );
axObjs = fig.Children
axObjs
axObjs.Children;
dataObjs = ans;
fritchX=dataObjs(1).XData;
fritchY=dataObjs(1).YData;

ObsX=dataObjs(2).XData;
ObsY=dataObjs(2).YData;

SimX=dataObjs(3).XData;
SimY=dataObjs(3).YData;

mean(fritchY)
mean(ObsY)
mean(SimY)


mean(fritchY.*fritchX)
mean(ObsY.*ObsX)
mean(SimY.*SimX)