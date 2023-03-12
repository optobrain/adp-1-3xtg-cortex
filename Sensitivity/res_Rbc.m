%% Measure Isoflurane effects: Doppler

close all;  clc;  clear; 
comInit;

rid = "RBC";  % dtype
status = ["Awake", "Anesth"];  % cp1{1} and cp1{2}

pathrepo = sprintf("%s/%s", pathrepo0, rid);


%% Load meta

tbMeta = comGetMeta();
tbMeta = tbMeta(tbMeta.dtype == rid,:)
nd = size(tbMeta,1);


%% Load data to tb

tb = table;  

for id=1:nd
    tbMeta1 = tbMeta(id,:);
    if tbMeta1.eid == ""
        fpath = sprintf("%s/%s.mat", pathraw0, tbMeta1.did);
    else
        fpath = sprintf("%s/%s/%s.mat", pathraw0, tbMeta1.eid, tbMeta1.did);
    end
    
    l = load(fpath);  % D, btwness, clsness, frac, full_l, tort
    error
    tb1 = table;
    tb1.grp = tbMeta1.grp;
    tb1.animal = comGetAnimal(tbMeta1.dtype, tbMeta1.did, tbMeta1.eid);
    tb1.anes = contains(tbMeta1.eid, "_anes");
    tb1.diaMean = mean(l.D);
    tb1.diaCov = std(l.D)/mean(l.D);
    tb1.lenMean = mean(l.full_l);
    tb1.lenCov = std(l.full_l)/mean(l.full_l);
    tb1.torMean = mean(l.tort);
    tb1.torCov = std(l.tort)/mean(l.tort);
    tb1.btwMean = mean(l.btwness);
    tb1.btwCov = std(l.btwness)/mean(l.btwness);
    tb1.clsMean = mean(l.clsness);
    tb1.clsCov = std(l.clsness)/mean(l.clsness);
    tb1.frc = l.frac;

    tb = [tb; tb1];
end
disp("Loaded.");

grp = ["Young", "Old"];
tb.grp = categorical(tb.grp, grp);
head(tb)


%% Plot

met = ["dia", "len", "tor", "btw", "cls", "frc"];
mtype = ["Mean", "Cov"];
nm = numel(met);
ani = unique(tb.animal);  na = numel(ani);

clr = lines;
fig = NewFig2(2,nm);
for im=1:nm
    for it=1:2  % mean, Cov
        met1 = sprintf("%s%s", met(im), mtype(it));
        if ~ismember(met1, tb.Properties.VariableNames)
            met1 = met(im);
        end
        tb1 = table;
        tb1.animal = ani;
        tb1.grp = strings(na,1);
        tb1.diff = zeros(na,1);
        for ia=1:na
            tb1.grp(ia) = unique(tb(tb.animal==tb1.animal(ia),:).grp);
            tb1.diff(ia) = ( tb(tb.animal==tb1.animal(ia) & tb.anes,:).(met1) ./ ...
                tb(tb.animal==tb1.animal(ia) & ~tb.anes,:).(met1) - 1)*100;
        end
        tb1.grp = categorical(tb1.grp, grp);
        
        % stat: against zero
%         for ig=1:2
%             ci = bootci(1000, @mean, tb1.diff(tb1.grp==grp(ig)));
%             if prod(ci) > 0
%                 warning("%s in %s CI: %.1f to %.1f %%", met1, grp(ig), ci(1), ci(2));
%             end
%         end
        
        % stat: against zero including both young and old
        ci = bootci(1000, @mean, tb1.diff);
        if prod(ci) > 0
            warning("%s CI: %.1f to %.1f %%", met1, ci(1), ci(2));
        end
        
        % stat: intragroup
        y1 = tb1.diff(tb1.grp==grp(1));  y2 = tb1.diff(tb1.grp==grp(2));
%         if IsNormDist(y1) && IsNormDist(y2)
%             [~, p] = ttest2(y1, y2);
%             xl = sprintf("p=%.3f", p);
%         else
            [p, t, tBoot, effectSize] = BootCompareTwo(y1, y2);
            xl = sprintf("pBoot=%.3f", p);
%         end
        
        subplot(2,nm,im+(it-1)*nm);
        tb1.grpId = ones(size(tb1,1),1);
        tb1.grpId(tb1.grp==grp(2)) = 2;
%         swarmchart(tb1.grpId, tb1.diff, [], [1 1 1]*0.7, Marker='o');
%         swarmchart(tb1.grpId, tb1.diff, [], clr(1:2,:), Marker='o');
        sw = swarmchart(repmat([1 2],[numel(y1) 1]), [y1, y2], [], clr(1:2,:), Marker='o', XJitterWidth=0.5);
        ax = gca;
        ax.XLim = [1 2] + [-1 1]*0.7;
%         ax.YLim = ax.YLim + [-1 1]*10;
        ax.YLim = [min([y1, y2], [], 'all') max([y1, y2], [], 'all')] + [-1 1]*diff(ax.YLim)*0.25;
        ax.XTick = [1 2];
        ax.XTickLabel = grp;
%         ax.XLabel.String = xl;
        text(mean(ax.XLim), ax.YLim(2), sprintf("p=%.3f", p), HorizontalAlignment='center');
    end
end
sgtitle(sprintf("%s : mean (top), cov (bottom)", strjoin(met)))
SaveFig(fig, true, "cap", sprintf("%s #all", pathrepo));
