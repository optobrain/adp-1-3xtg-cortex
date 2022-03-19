function [ypred_ad, ci_ad, ypred_wt, ci_wt] = Dopp_diam_vein_func(ci_int, plt)
%R2 = 0.48

nsamp = 1000;
age = 0:0.1:6;
wk = linspace(11,35,length(age));
fixef = [2.290266 -1.464885 ];
Sig = [0.07213484 -0.07368188; -0.07368188  0.07587030];
%fixef = [0.8273558 0.1707821  ];
 % Sig = [0.0005929464 -0.0001652968;-0.0001652968  0.0010579169];

pars = mvnrnd(fixef, Sig,nsamp);
%yvals = pars(:,1) + pars(:,2)./(1+exp((0.4-age)/-0.1)); 
%y = fixef(1) + fixef(2)./(1+exp((0.4-age)/-0.1)); 
yvals = pars(:,1) + pars(:,2)./(1+exp((-1-age)/0.5)); 
y = fixef(1) + fixef(2)./(1+exp((-1-age)/0.5)); 
lwr = zeros(size(age));
upr = zeros(size(age));

l = (100-ci_int)/2; u = 100-l;
for i = 1:length(age)
    lwr(i) = prctile(yvals(:,i),l);
    upr(i) = prctile(yvals(:,i),u);
end

ypred_ad = y;
ci_ad = [lwr' upr'];
if plt == 1
figure; hold on

a = plot(wk,y, 'r'); plot(wk,upr,'r'); plot(wk,lwr,'r')
xlabel('Age (WOA)')


box off
set(gca,'fontsize', 16)
xlabel('Age (WOA)')
end
%saveas(gcf, ['AD_mean_diam.fig'])
%saveas(gcf, ['AD_mean_diam.svg'])
%value for a is not sig 

%%


%R2 = 0.30

nsamp = 100;
%fixef = [8.466421 2.346631];
 fixef = [0.9997183 0.1697121 ];
Sig =[  0.0001408267 -0.0004135988; -0.0004135988  0.0155896030];


pars = mvnrnd(fixef, Sig,nsamp);
yvals = pars(:,1) + pars(:,2)./(1+exp((6-age)/0.7)); 
y = fixef(1) + fixef(2)./(1+exp((6-age)/0.7));
lwr = zeros(size(age));
upr = zeros(size(age));
l = (100-ci_int)/2; u = 100-l;

for i = 1:length(age)
    lwr(i) = prctile(yvals(:,i),l);
    upr(i) = prctile(yvals(:,i),u);
end

%figure; hold on
%plot(WT_diam, 'k')
ypred_wt = y;
ci_wt = [lwr' upr'];
if plt == 1
b = plot(wk,y, 'b'); plot(wk,upr,'b'); plot(wk,lwr,'b')


xlabel('Age (WOA)')

box off
set(gca,'fontsize', 16)
xlabel('Age (WOA)')
ylabel('Normalized diameter')
title('Venule diameter')
xlim([11 36])
ylim([0.5 1.5])

legend([b a], {'WT', 'AD'})
end
%%

wt1 = 0.9997183; std_wt1 =   0.01191386  ;
ad1 = 0.8273558 ; std_ad1 =  0.02443888  ;
 

t = (wt1-ad1)./sqrt(std_wt1^2/6 + std_ad1^2/7);
p = 1-tcdf(abs(t),6+7-4);
%p =  2.4445e-08;