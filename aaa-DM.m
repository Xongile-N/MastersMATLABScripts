% Create an output structure similar to the input
OutputPort1 = InputPort1;
% log-normal
MU=0;
SIGMA=0.1;
numberofsamples = length(InputPort1.Sampled(1,1).Signal);
x=normrnd(MU,SIGMA,1,numberofsamples);
y=exp(2*x); 
if strcmp(InputPort1.TypeSignal ,'Optical')
% verify how many sampled signals are in the structure
[ls, cs] = size(InputPort1.Sampled);

if( ls > 0 )

for counter1=1:cs
OutputPort1.Sampled(1, counter1).Signal = InputPort1.Sampled(1, counter1).Signal.*y;
end
end
[lp, cp] = size(InputPort1.Parameterized);
  if( lp > 0 )

OutputPort1.Parameterized.Power = InputPort1.Parameterized.Power*mean(y) ;

  end
end