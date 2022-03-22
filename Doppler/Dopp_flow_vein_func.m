function [ypred_ad , ci_ad,ypred_wt, ci_wt] = Dopp_flow_vein_func(ci_int,plt)
lme1 = load('Dopp_vein_wt_mod.mat');

nsamp = 1000;
age = 0:0.1:6;
wk = linspace(11,35,length(age));

fixef = [1.0456985,    -0.2994795 ];
Sig = [0.005853407 -0.002782858; -0.002782858  0.003472581];


pars = mvnrnd(fixef, Sig,nsamp);
yvals = pars(:,1) + pars(:,2)./(1+exp((0.6-age)/0.35));
y = fixef(1) + fixef(2)./(1+exp((0.6-age)/0.35));
%yvals = pars(:,1) + pars(:,2)./(1+exp((0.9-age)/-0.1)); 
%y = fixef(1) + fixef(2)./(1+exp((0.9-age)/-0.1)); 
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
%plot(AD_diam, 'k')
plot(wk,y, 'r'); plot(wk,upr,'r'); plot(wk,lwr,'r')
box off
set(gca,'fontsize', 16)
xlabel('Age (weeks)')
ylabel('Normalized flow')
pbaspect([1 1 1])
xlim([10 36])
end

lme1 = lme1.lme1;

pop_tab_wt = table(repmat(age',1,1), categorical(zeros(length(age),1)),categorical(zeros(length(age),1)),repmat(categorical(cellstr('wt')),length(age),1), 'variablenames', {'age', 'id', 'Vesselnum', 'group'});

[ypred_wt, ci_wt] = (predict(lme1, pop_tab_wt, 'alpha', 0.0615));

if plt ==1
 plot(wk,ypred_wt,'b'); hold on; plot(wk,ci_wt,'b')
end

 wt1 = 0.95 ; std_wt1 =   0.1308 ;
 ad1 = 0.7461; std_ad1 =  0.1218;
  
 
 t = (wt1-ad1)./sqrt(std_wt1^2/6 + std_ad1^2/7);
 p = 1-tcdf(abs(t),6+7-4);
% p = 0.0089;

