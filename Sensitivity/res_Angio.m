%% Measure the sensitivity from Isoflurane recovery data: Angio

clear, clc, close all
comInit;

rid = "OCTA";  % dtype, OCTA or D-OCT

pathrepo = sprintf("%s/%s", pathrepo0, rid);


%% Load meta

tbMeta0 = comGetMeta();
tbMeta0 = tbMeta0(tbMeta0.dtype == rid,:)
nd0 = size(tbMeta0,1);

% only p2id
tbMeta = tbMeta0(tbMeta0.p2id ~= "",:)
nd = size(tbMeta,1);


%% Load p2 data to tb

tb = table;

% cp2 = cell(nd,1);  cD3 = cell(nd,1);
for id=1:nd
    tbMeta1 = tbMeta(id,:);
    
    % load p2
%     fpath = sprintf("%s/%s/%s.mat", pathraw0, tbMeta1.eid, tbMeta1.p2id);  % no p2 files
%     fpath = sprintf("%s/%s.mat", pathraw0, tbMeta1.p2id);  % p2 files have wrong 2 p1
    fpath = sprintf("%s/prev-files-for-project2/%s.mat", pathraw0, tbMeta1.p2id);
    l = load(fpath, 'p2');  % p2, D3
    
    % check p1
    p1id = string(cellfun(@(x) x.id, l.p2.cp1, UniformOutput=false));
    np1 = numel(p1id);
    ir = find(tbMeta0.p2id == tbMeta1.p2id);
    p1idMeta = tbMeta0.p1id(ir-1+(1:np1));
    if ~isequal(p1id, p1idMeta)
        error("p1id is different between meta and p2.");
    end
    
    % r2
    r2 = l.p2.res;  % V, Vd, VR2
    dx = cellfun(@(x) x.conf.Xstep, l.p2.cp1, UniformOutput=false);  % returns a cell array
    dx = mean([dx{:}]);  % [ {:}] change a cell array to a row array
    iv = all(r2.Vd>0,2);
    nv = sum(iv);

    for it=1:np1
        tb1 = table;
        tb1.animal = strings(nv,1);
        tb1.animal(:) = tbMeta1.animal;
        tb1.it = ones(nv,1) * it;
        tb1.iv = find(iv);
        tb1.Vd = r2.Vd(iv,it) * dx;
        tb1.R = r2.VR2(iv,it);        
        if min(tb1.Vd) == 0
            error
        end
        tb = [tb; tb1];
    end
end
disp("Loaded.");

head(tb)

figure; 
histogram(tb.R);


%% Filter by R
% we cannot do this because a single vessel can have different R at different time points.
%{
% minR = 0.8;  % did not change conclusion
minR = 0;  

if minR > 0
    tb = tb(tb.R1 >= minR & tb.R2 >= minR, :);
end
%}


%% Plot

tname = ["awake", "5 min after ON", "25 min after ON", ...
    "OFF", "7 min after OFF", "15 min after OFF", ...
    "30 min after OFF", "45 min after OFF", "60 min after OFF"];

ani = unique(tb.animal);  na = numel(ani);

clr = lines;
fig = NewFig2(1.75,2);
nvTot = 0;
for ia=1:na
    ani1 = ani(ia);
    tb1 = tb(tb.animal==ani1,:);
    iv = unique(tb1.iv);
    for ii=1:numel(iv)
        tb2 = tb1(tb1.iv==iv(ii),:);
%         line(tb2.it, tb2.Vd, Color=clr(ia,:));
        line(tb2.it, tb2.Vd, Color=[1 1 1]*0.75);
    end
    nvTot = nvTot + numel(iv);
end
nvTot
ax = gca;
ax.YLim = [0 60];
ax.XTick = (1:9);
ax.XTickLabel = tname;
ax.XGrid = 'on';
ax.YLabel.String = "Pial vessel diameter (\mum)";

yMean = zeros(9,1);
yCi = zeros(9,1);
for it=1:9
    tb1 = tb(tb.it==it,:);
    yMean(it) = mean(tb1.Vd);
    yCi(it) = SEtoCI(std(tb1.Vd), numel(tb1.Vd), true);
end
line(1:9, yMean, Marker='.');
% PlotShade(1:9, yMean-yCi, yMean+yCi);
SaveFig(fig, true, "all", sprintf("%s #all", pathrepo));


%% stat

% stat: max diff: nested LME between 25 min after ON vs 7 min after OFF
tcomp = [3 5];
[lme, fig] = CompareTwo(tb, tcomp, tname);
SaveFig(fig, true, "maxDiff", sprintf("%s #maxDiff", pathrepo));

%% stat: robustness over 90 min: nested LME between awake vs 60 min after OFF
tcomp = [1 9];
[lme, fig] = CompareTwo(tb, tcomp, tname);
SaveFig(fig, true, "robust", sprintf("%s #robust", pathrepo));

%% stat: sensitivity
% tcomp = [8 9];  [lme, fig] = CompareTwo(tb, tcomp, tname);  p = lme.Coefficients.pValue(2)  % 0.634
% tcomp = [7 9];  [lme, fig] = CompareTwo(tb, tcomp, tname);  p = lme.Coefficients.pValue(2)  % 0.553
% tcomp = [6 9];  [lme, fig] = CompareTwo(tb, tcomp, tname);  p = lme.Coefficients.pValue(2)  % 0.167
% tcomp = [5 9];  [lme, fig] = CompareTwo(tb, tcomp, tname);  p = lme.Coefficients.pValue(2)  % 0.182
tcomp = [1 2];  [lme, fig] = CompareTwo(tb, tcomp, tname);  p = lme.Coefficients.pValue(2)  % 0.026
% tcomp = [2 3];  [lme, fig] = CompareTwo(tb, tcomp, tname);  p = lme.Coefficients.pValue(2)  % 0.182
SaveFig(fig, true, "sens", sprintf("%s #sens", pathrepo));



%% FUNCTIONS

function [lme, fig] = CompareTwo(tb, tcomp, tname)

    tb1 = tb(tb.it==tcomp(1) | tb.it==tcomp(2),:);
    tb1.it(tb1.it==tcomp(1)) = 0;
    tb1.it(tb1.it==tcomp(2)) = 1;

    % md = "Vd ~ it + (1|animal/iv)";  % chatGPT, wrong
    md = "Vd ~ it + (1|iv:animal)";
    md = "Vd ~ it + (1|animal:iv)";  % same result as above
    md = "Vd ~ it + (1|animal) + (1|iv:animal)";  
    % almost same result with higher AIC, but we must use this as the first model
    lme = fitlme(tb1, md)
    lme.Coefficients.Upper - lme.Coefficients.Lower

    % plot
    ani = unique(tb1.animal);  na = numel(ani);
    fig = NewFig2(1.5,1);
    for ia=1:na
        ani1 = ani(ia);
        tb2 = tb1(tb1.animal==ani1,:);
        nv = max(tb2.iv);
        for iv=1:nv
            tb3 = tb2(tb2.iv==iv,:);
    %         line(tb2.it, tb2.Vd, Color=clr(ia,:));
            line(tb3.it, tb3.Vd, Color=[1 1 1]*0.75);
        end
    end
    ax = gca;
    ax.YLim = [0 60];
    ax.XLim = [-0.5 1.5];
    ax.XTick = (0:1);
    ax.XTickLabel = tname(tcomp);
    ax.YLabel.String = "Pial vessel diameter (\mum)";

    tb2 = tb1(1:2,:);
    tb2.it = [0 1]';
    tb2.animal(:) = "temp1";
    tb2.iv(:) = 100;
    [pmu, pci] = lme.predict(tb2);
    line([0 1], pmu, LineWidth=2);
    PlotShade([0 1], pci(:,1), pci(:,2));
    
end
