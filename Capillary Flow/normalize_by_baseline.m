%tab is the table of the variables of interest
tab(tab.group == 'ad',:).group = repmat(categorical(cellstr('AD')), length(tab(tab.group == 'ad',:).group),1);
tab(tab.group == 'wt',:).group = repmat(categorical(cellstr('WT')), length(tab(tab.group == 'wt',:).group),1);

if min(tab.age) == 1
    tab.age = tab.age -1 ;
end

v = tab.Properties.VariableNames;
c = cellfun(@(x) strcmp(x,'id') | strcmp(x,'group') | strcmp(x,'age') | strcmp(x, 'Vesselnum'),v);
v(c) = [];


tab2 = tab;
for i = 1:length(v)
    
    ind = cellfun(@(x) strcmp(x, v{i}), tab.Properties.VariableNames);
    ind = find(ind);
    [lme, eq, ex] = fit_model_2(v{i}, tab);

    [c1, n] = fixedEffects(lme);
    i1 = strcmp(n.Name, '(Intercept)');
    i2 = strcmp(n.Name, 'group_WT');
    int_ad = (c1(i1));
    int_wt = (c1(i1)+c1(i2));


    n1 = tab{tab.group == 'AD', ind};
    n2 = tab{tab.group == 'WT', ind};

    tab2{tab2.group == 'AD', ind} = n1/int_ad;
    tab2{tab2.group == 'WT', ind} = n2/int_wt;

    i1 = strfind( eq, '(');
    i2 = strfind( eq, ')');
    lme_norm =  fitlme(tab2, [v{i} ' ~ -group + age*group + ' eq(i1:i2)], 'exclude', ex);
    mod{i} = lme_norm;
    [g, var] = get_var(tab2, ind);
    n = length(unique(tab2.age));
    pop_tab_ad = table(repmat([unique(tab2.age)],1,1), categorical(zeros(n,1)),categorical(zeros(n,1)),repmat(categorical(cellstr('AD')),n,1), 'variablenames', {'age', 'id', 'Vesselnum', 'group'});
    pop_tab_wt = table(repmat([unique(tab2.age)],1,1), categorical(zeros(n,1)),categorical(zeros(n,1)),repmat(categorical(cellstr('WT')),n,1), 'variablenames', {'age', 'id', 'Vesselnum', 'group'});
    wk = unique(tab2.age)*4 + 11;
  
    
    [ypred_ad, ci_ad] = (predict(lme_norm , pop_tab_ad));
    [ypred_wt, ci_wt] = (predict(lme_norm , pop_tab_wt));

    figure
    plot(wk,ypred_ad,  'color', 'r'); hold on; plot(wk,ci_ad, 'color', 'r');
    plot(wk,ypred_wt, 'color', 'b'); plot(wk,ci_wt, 'color', 'b');
    title(v{i}, 'Interpreter', 'none'); box off
    set(gca,'fontsize', 16); xlabel('Age (weeks)')
    %xlim([10 36]); 
    
    figure
    plot(wk,(var(g=='WT',:))', 'k'); hold on;   plot(wk,ypred_wt, 'color', 'b'); plot(wk,ci_wt, 'color', 'b');
    title(['WT ' v{i}], 'Interpreter', 'none'); box off
    set(gca,'fontsize', 16); xlabel('Age (weeks)')
    %xlim([10 36]); 
    
    figure
    plot(wk,(var(g=='AD',:))', 'k'); hold on; plot(wk,ypred_ad,  'color', 'r'); hold on; plot(wk,ci_ad, 'color', 'r');
    title(['AD ' v{i}], 'Interpreter', 'none'); box off
    set(gca,'fontsize', 16);  xlabel('Age (weeks)')
    %xlim([10 36]);
end


function [g, var] = get_var(tab2, ind)

if sum(strcmp( tab2.Properties.VariableNames, 'Vesselnum')) ==1
    
    uniq_id = unique(tab2.id);
    it = 1;
    for i = 1:length(uniq_id)
            tab_id = tab2(tab2.id==uniq_id(i),:);
            uniq_v = unique(tab_id.Vesselnum);
            for j = 1:length(uniq_v)
                tab_id_v = tab_id(tab_id.Vesselnum == uniq_v(j),:);
                age = tab_id_v.age;
                var(it,:) = tab_id_v{:, ind};
                g(it) = tab_id_v.group(1);
                g_av(it) = tab_id_v.ArteryVein(1);
                it = it+1;
            end
    end

else
    uniq_id = unique(tab2.id);
    var = NaN(length(uniq_id),length(unique(tab2.age)));
    for i = 1:length(uniq_id)
       t_id =  tab2(tab2.id == uniq_id(i),:);
       t_age = t_id.age + 1;
       var(i,t_age) = t_id{:,ind};
       g(i) = t_id.group(1);
    end
end
end








