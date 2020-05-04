% Generates samples (300 Hz model) for beam wander with the following
% turbulence: 
% Ref: https://arxiv.org/abs/1907.10519
%
% Moderately strong turbulence:
% model = arima('Constant',0,'AR',{1.759,-0.76259},'MA',{-1.2889, 0.31655},'Variance',2150); % 300Hz, w_ST = 103 (115um), r_0 = 0.01m, C_n^2=4.1e-13, \sigma_I=0.55


%% Simulate Wander

samples = 1e4;
freq=300;

period=1/freq;
bits=period*2e6;
totalPeriod=samples*period;
time=linspace(0,totalPeriod,samples);
model = arima('Constant',0,'AR',{1.759,-0.76259},'MA',{-1.2889, 0.31655},'Variance',2150); % r_0=0.01m, C_n^2=4.1e-13, \sigma_I=0.55

simY = simulate(model,samples);
%plot(1:numSim, simY)

simX = simulate(model,samples);
%plot(1:numSim, simX)

[simTheta, simRho] = cart2pol(simX, simY);

%% Plot Simulations

figure
subplot(2,2,1)
plot(simX)
title('Simulated \beta_x')
subplot(2,2,3)
plot(simY)
title('Simulated \beta_y')

subplot(2,2,2)
a = plot(simX,simY);
set(gca,'dataAspectRatio',[1 1 1]);
a.Color(4) = 0.25;
set(gca, 'Visible', 'off')
print(gcf,'WanderTrace.png','-dpng','-r600'); 

subplot(2,2,4)
sf = simX;
s = scatter(sf(2:end),sf(1:end-1),'filled')
s.MarkerFaceAlpha = 0.3;
ylabel('\beta_x(t)')
xlabel('\beta_x(t-1)')

%% Convert to intensities
% The spatial simulation is great, but needs to be mapped into intensities

I_0 = 1; %initial intensity
w_ST = 200; %beam size, 103 (115um) experiement, make bigger for less fading
r = 0; %detector position
fudgeScale = 1;

simI = I_0.*exp(-2 * ((r-simRho).^2)./((w_ST*fudgeScale).^2)); 

%% Plot intensities
figure;
subplot(2,1,1)
plot(time,simI)
title('Simulated Wander Fading')
subplot(2,1,2)
histogram(simI,50)
title('Simulated Wander Histogram (sort of PDF)')
