function [ypred_ad , ci_ad,ypred_wt, ci_wt] = Dopp_diam_art_func(ci_int,plt)

nsamp = 1000;
age = 0:0.1:6;
wk = linspace(11,35,length(age));
fixef = [1.3828374 -0.5737105 ]; %values from R 
Sig = [0.005423598 -0.005678777; -0.005678777  0.007019364];

pars = mvnrnd(fixef, Sig,nsamp);
yvals = pars(:,1) + pars(:,2)./(1+exp((-0.348-age)/0.5));
y = fixef(1) + fixef(2)./(1+exp((-0.348-age)/0.5));


lwr = zeros(size(age));
upr = zeros(size(age));
l = (100-ci_int)/2; u = 100-l;
for i = 1:length(age)
    lwr(i) = prctile(yvals(:,i),l);
    upr(i) = prctile(yvals(:,i),u);
end

ci_ad = [lwr' upr'];
ypred_ad = y;

if plt ==1
figure; hold on
a = plot(wk,y, 'r'); plot(wk,upr,'r'); plot(wk,lwr,'r')
xlabel('Age (WOA)')
box off
set(gca,'fontsize', 16)
xlabel('Age (weeks)')
ylabel('Normalized diameter')
pbaspect([1 1 1])
xlim([10 36])
end

 fixef = [1.3450237 -0.4489429 ];
 Sig = [0.01213151 -0.01245875; -0.01245875  0.01354773];



pars = mvnrnd(fixef, Sig,nsamp);
yvals = pars(:,1) + pars(:,2)./(1+exp((-0.6-age)/0.5)); 
y = fixef(1) + fixef(2)./(1+exp((-0.6-age)/0.5));

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
pbaspect([1 1 1])
end
%%
