function [ypred_ad , ci_ad,ypred_wt, ci_wt] = Dopp_flow_art_func(ci_int,plt)

nsamp = 1000;
age = 0:0.1:6;
wk = linspace(11,35,length(age));

fixef = [1.4398804 ;   -0.7533208  ];
Sig = [0.01516823   -0.01339995; -0.01339995    0.01553367];


pars = mvnrnd(fixef, Sig,nsamp);
yvals = pars(:,1) + pars(:,2)./(1+exp((-0.3-age)/0.75));
y = fixef(1) + fixef(2)./(1+exp((-0.3-age)/0.75));

lwr = zeros(size(age));
upr = zeros(size(age));
l = (100-ci_int)/2; u = 100-l;
for i = 1:length(age)
    lwr(i) = prctile(yvals(:,i),l);
    upr(i) = prctile(yvals(:,i),u);
end

if plt ==1
figure; hold on
a = plot(wk,y, 'r'); plot(wk,upr,'r'); plot(wk,lwr,'r')
end

ci_ad = [lwr' upr'];
ypred_ad = y;


 fixef = [1.2720202 -0.4213077  ];
 Sig = [0.02031020 -0.02110588; -0.02110588  0.03045347];
%Sig =[   7.133706e-04 -8.353495e-05; -8.353495e-05  6.854396e-04];


pars = mvnrnd(fixef, Sig,nsamp);
yvals = pars(:,1) + pars(:,2)./(1+exp((-0.3-age)/0.5)); 
y = fixef(1) + fixef(2)./(1+exp((-0.3-age)/0.5));

lwr = zeros(size(age));
upr = zeros(size(age));
l = (100-ci_int)/2; u = 100-l;
for i = 1:length(age)
    lwr(i) = prctile(yvals(:,i),l);
    upr(i) = prctile(yvals(:,i),u);
end
ci_wt = [lwr' upr'];
ypred_wt = y;

if plt ==1
hold on
b = plot(wk,y, 'b'); plot(wk,upr,'b'); plot(wk,lwr,'b')

ylim([0.5 1.5])
legend([b a], {'WT', 'AD'})
set(gca,'fontsize', 16)
xlim([10 36])
pbaspect([1 1 1])
end

