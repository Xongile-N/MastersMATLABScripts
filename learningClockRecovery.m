SymbolTime = 100e-12;
SamplesPerSymbol = 16;
dt = SymbolTime/SamplesPerSymbol;
loss = 5;
chan = serdes.ChannelLoss('Loss',loss,'dt',dt,...
       'TargetFrequency',1/SymbolTime/2,'RiseTime',SamplesPerSymbol/4*dt);
   ord = 10;                       %PRBS order
nrz=prbs(ord,2^ord-1);
nrzPattern = nrz(:)' - 0.5;     %[0,1] --> [-0.5,0.5];
ChannelPulseResponse = impulse2pulse(chan.impulse, SamplesPerSymbol, dt);
waveprbs = pulse2wave(ChannelPulseResponse(:,1),nrzPattern,SamplesPerSymbol);
wave2 = [waveprbs; waveprbs];
CDR1 = serdes.CDR('Modulation',2,'Count',8,'Step',1/64,...
       'SymbolTime',SymbolTime,'SampleInterval',dt);
   plot(wave2)
% phase = zeros(1,length(wave2));
% CDRearlyLateCount = zeros(1,length(wave2));
% for ii = 1:length(wave2)
%       [phase(ii), ~, optional] = CDR1(wave2(ii));
%       CDRearlyLateCount(ii) = optional.CDRearlyLateCount;
% end
% t = (0:length(wave2)-1)/SamplesPerSymbol;
% teye = (0:SamplesPerSymbol-1)/SamplesPerSymbol;
% eyed = reshape(wave2,SamplesPerSymbol,[]);
%  figure,
% subplot(2,2,[1,3]), yyaxis left, plot(teye,eyed, '-b'),
% title('Eye Diagram with Recovered Clock Distribution')
% xlabel('Symbol Time'), ylabel('Voltage')
% yyaxis right,
% histogram(phase,SamplesPerSymbol/2)
% set(gca,'YTick',[])
% subplot(2,2,2), plot(t,phase)
% xlabel('Number of Symbols'), ylabel('Symbol Time');
% title('Clock Phase vs. Time')
% subplot(224), plot(t,CDRearlyLateCount)
% xlabel('Number of Symbols'), ylabel('Count')
% title('Early/Late Count Threshold vs. Time')