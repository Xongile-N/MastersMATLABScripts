K=100;
delta=0.05;
c=0.1;
Q=10;
[distS,cumulS]=Soliton(K);
[distRS,cumulRS]=RobustSolitonQ(K, delta,Q);
% t=tiledlayout(4,1);
% dim1=[2,1];
% dim2=[2,1];
% soli=nexttile(dim1);
% plot(distS)
% ylabel("Probability")
% 
% rSoli=nexttile(dim2);
% plot(distRS)
% ylabel("Probability")
% xlabel("Degree (d)")
plot(distS)
hold on
plot(distRS)
ylabel("Probability")
xlabel("Degree (d)")
legend(["Soliton"; "Robust Soliton"])