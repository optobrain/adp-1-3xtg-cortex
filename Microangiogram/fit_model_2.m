function [lme_art, eq, ex] = fit_model_2(v, tab) %v is the variable name and tab is the table

if sum(strcmp( tab.Properties.VariableNames, 'Vesselnum')) ==1
    mod_eq1 = [v ' ~ 1 + age*group + (1|id:Vesselnum)'];
    mod_eq2 = [v ' ~ 1 + age*group + (age-1|id:Vesselnum)'];
    mod_eq3 = [v ' ~ 1 + age*group + (age|id:Vesselnum)'];
else
    mod_eq1 = [v ' ~ 1 + age*group + (1|id)'];
    mod_eq2 = [v ' ~ 1 + age*group + (age-1|id)'];
    mod_eq3 = [v ' ~ 1 + age*group + (age|id)'];
end

ind = cellfun(@(x) strcmp(x, v), tab.Properties.VariableNames);
ind = find(ind);

lme1 = fitlme(tab,mod_eq1);
lme2 = fitlme(tab,mod_eq2);
lme3 = fitlme(tab,mod_eq3);

if lme1.Rsquared.Adjusted > lme2.Rsquared.Adjusted
    eq = mod_eq1;
    g = lme1;
else
    eq = mod_eq2;
    g = lme2;
end
c = compare(g,lme3);

if sum(randomEffects(g)) < 1e-20
    %m1 = lme3;
    eq = mod_eq3;
elseif c.pValue < 0.05
    %m1 = lme3;
    eq = mod_eq3;
end

m1 =  fitlme(tab, eq);
f = fitted(m1);
N1 = tab;

Cook = zeros(size(N1,1),1);
for i = 1:size(N1,1) 
  m2 =  fitlme(tab, eq, 'exclude', i);
  f1 = fitted(m2);
  Cook(i) = nansum(f - f1)^2;
end

N2 = N1;
thresh = 3*nanmean(Cook);
N2{Cook>thresh,ind} = NaN(sum(Cook>thresh),1);
ex = find(Cook>thresh);
lme_art =  fitlme(N2, eq);
