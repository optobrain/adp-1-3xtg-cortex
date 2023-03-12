%% Measure Isoflurane effects: Doppler

close all;  clc;  clear; 
comInit;

rid = "Doppler";  % dtype
status = ["Awake", "Anesth"];  % cp1{1} and cp1{2}

pathrepo = sprintf("%s/%s", pathrepo0, rid);


%% Load meta

tbMeta = comGetMeta();
tbMeta = tbMeta(tbMeta.dtype == rid,:)
nd = size(tbMeta,1);


%% Load data to tb

vesDia = [10 50];  % [um], for imfindcircle()

tb = table;
tbDens = table;

DispProg(0, nd, "Loading and calculating vessel density ...");
for id=1:nd
    tbMeta1 = tbMeta(id,:);
    if tbMeta1.eid == ""
        fpath = sprintf("%s/%s.mat", pathraw0, tbMeta1.did);
    else
        fpath = sprintf("%s/%s/%s.mat", pathraw0, tbMeta1.eid, tbMeta1.did);
    end
    
    l = load(fpath);  % p2, cVV3
%     l = load(fpath, 'p2');  % p2, cVV3
    r2 = l.p2.res;  % V, Vf, Vd, VR2, F, A
    nv = sum(prod(r2.Vd>0,2));
    
    % dx is already multiplied in measuring diameter from Doppler
%     dx1 = l.p2.cp1{1}.conf.Xstep;  % um/pix
%     dx2 = l.p2.cp1{2}.conf.Xstep;
    dx1 = 1;  dx2 = 1;
    
    tb1 = table;
    tb1.grp = strings(nv,1);
    tb1.grp(:) = tbMeta1.grp;
    tb1.animal = strings(nv,1);
    tb1.animal(:) = comGetAnimal(tbMeta1.dtype, tbMeta1.did);
    tb1.Vd1 = r2.Vd(1:nv,1) * dx1;
    tb1.Vd2 = r2.Vd(1:nv,2) * dx2;
    tb1.Vf1 = r2.Vf(1:nv,1);
    tb1.Vf2 = r2.Vf(1:nv,2);
    tb1.R1 = r2.VR2(1:nv,1);
    tb1.R2 = r2.VR2(1:nv,2);
    tb = [tb; tb1];

    % vessel density
            % dev
            %{
            figure;
            for it=1:2
                subplot(1,2,it);  
                img = squeeze(mean(l.cVV3{it}(l.p2.izRef(it)+(-1:1),:,:).^2, 1));
%                 image(img, CDataMapping='scaled');
                img = imresize(img, 2);  % since 10 um diameter or 5 um radius is only 3 px
                img = imadjust(mat2gray(img));
                imshow(img);
                [cent, radi] = imfindcircles(img, round(vesDia/2*2/l.p2.cp1{it}.conf.Xstep));
                viscircles(cent, radi, Color='r');
            end
            %}

    tb1 = table;
    tb1.grp = tbMeta1.grp;
    tb1.animal = comGetAnimal(tbMeta1.dtype, tbMeta1.did);
    for it=1:2
        dx = l.p2.cp1{it}.conf.Xstep;  % um/pix
        img = squeeze(mean(l.cVV3{it}(l.p2.izRef(it)+(-1:1),:,:).^2, 1));
        [nx,ny] = size(img);
        img = imresize(img, 2);  % since 10 um diameter or 5 um radius is only 3 px
        img = imadjust(mat2gray(img));
        [cent, radi] = imfindcircles(img, round(vesDia/2*2/dx));
        tb1.(sprintf("dens%d",it)) = numel(radi) / (dx^2*nx*ny*1e-6);  % #/mm2
    end
    tbDens = [tbDens; tb1];
    
    DispProg(id, nd);
end
disp("Loaded.");

% vein
if sum(tb.Vf1 .* tb.Vf2 < 0)
    error("Flow direction changed by anesthesia");
end
tb.vein = tb.Vf1 < 0;

tb.grp = categorical(tb.grp, ["Young", "Old"]);
head(tb)

figure; 
histogram(tb.R1);
hold on;
histogram(tb.R2);

fprintf("Young arteriole n = %d \n", sum(tb.grp=="Young" & ~tb.vein));
fprintf("Young venule n = %d \n", sum(tb.grp=="Young" & tb.vein));
fprintf("Old arteriole n = %d \n", sum(tb.grp=="Old" & ~tb.vein));
fprintf("Old venule n = %d \n", sum(tb.grp=="Old" & tb.vein));

tbDens.grp = categorical(tbDens.grp, ["Young", "Old"]);
tbDens


%% Filter by R

% minR = 0.8;  % did not change conclusion
% minR = 0;  % min R2 is -1.5
minR = -Inf;

tb = tb(tb.R1 >= minR & tb.R2 >= minR, :);


%% Plot: old
%{
tb.diffVd = (tb.Vd2 ./ tb.Vd1 - 1) * 100;  % [%]
tb.diffVf = (tb.Vf2 ./ tb.Vf1 - 1) * 100;
grp = unique(tb.grp);

clr = lines;
fig = NewFig2(2,2);
for ig=1:2
    subplot(2,2,ig);
    tb1 = tb(tb.grp==grp(ig),:);
    uani = unique(tb1.animal);
    for ia=1:numel(uani)
        tb2 = tb1(tb1.animal==uani(ia),:);
        for iv=1:size(tb2,1)
            line([1 2], [tb2.Vd1(iv), tb2.Vd2(iv)], Color=clr(ia,:), Marker='.');
        end
    end
    ax = gca;
    ax.XLim = [0.5 2.5];
    ax.YLim = [0 120];
    ax.XTickLabel = status;
    ax.YLabel.String = "Pen. ves. diameter (\mum)";
    ax.Title.String = grp(ig);
    
    subplot(2,2,2+ig);
    histogram(tb1.diffVd, FaceColor='k');
    ax = gca;
    ax.YLim = [0 25];
    ax.XLabel.String = "Pen. ves. diameter change (%%)";
    ax.YLabel.String = "Frequency";
end
SaveFig(fig, true, "dia", sprintf("%s #dia", pathrepo));    

clr = lines;
fig = NewFig2(2,2);
for ig=1:2
    subplot(2,2,ig);
    tb1 = tb(tb.grp==grp(ig),:);
    uani = unique(tb1.animal);
    for ia=1:numel(uani)
        tb2 = tb1(tb1.animal==uani(ia),:);
        for iv=1:size(tb2,1)
            line([1 2], [tb2.Vf1(iv), tb2.Vf2(iv)], Color=clr(ia,:), Marker='.');
        end
    end
    ax = gca;
    ax.XLim = [0.5 2.5];
    ax.YLim = [-1 1]*2.5;
    ax.XTickLabel = status;
    ax.YLabel.String = "Flow";
    ax.Title.String = grp(ig);
    
    subplot(2,2,2+ig);
    histogram(tb1.diffVf, FaceColor='k');
    ax = gca;
    ax.YLim = [0 12];
    ax.XLabel.String = "Flow change (%%)";
    ax.YLabel.String = "Frequency";
end
SaveFig(fig, true, "flow", sprintf("%s #flow", pathrepo));
%}    

%% Plot: swarm + hist
%{
tb.diffVd = (tb.Vd2 ./ tb.Vd1 - 1) * 100;  % [%]
tb.diffVf = (tb.Vf2 ./ tb.Vf1 - 1) * 100;
grp = unique(tb.grp);
met = ["diffVd", "diffVf"];
vtype = ["Arteriole", "Venule"];

clr = lines;
fig = NewFig2(2,4);  
for im=1:2
    for iv=0:1
        tb1 = tb(tb.vein==iv,:);
        subplot(2,4,(im-1)*4+iv*2+1);
%         swarmchart(tb.grp, tb.diff, [], [1 1 1]*0.7, Marker='.');
        tb1.grpId = ones(size(tb1,1),1);
        tb1.grpId(tb1.grp==grp(2)) = 2;
        swarmchart(tb1.grpId, tb1.(met(im)), [], [1 1 1]*0.7, Marker='o');
        PlotStatBox(tb1.(met(im)), tb1.grpId, [], [], 'k');
        ax = gca;
        ax.XLim = [1 2] + [-1 1]*0.6;
%         line(ax.XLim, [0 0], Color='k');
        ax.XTick = [1 2];
        ax.XTickLabel = grp;
        if im == 1
            ax.Title.String = vtype(iv+1);
        end
        if iv == 0
            ax.YLabel.String = met(im);
        end
        
        subplot(2,4,(im-1)*4+iv*2+2);
        for ig=1:2
            tb2 = tb1(tb1.grp==grp(ig),:);
            histogram(tb2.(met(im)));
            hold on;
        end
%         legend(grp, Location='northeast');
    end
end
% SaveFig(fig, true, "swarm", sprintf("%s #swarm", pathrepo));
%}

%% Plot and stat: swarm (no hist)

tb.diffVd = (tb.Vd2 ./ tb.Vd1 - 1) * 100;  % [%]
tb.diffVf = (tb.Vf2 ./ tb.Vf1 - 1) * 100;
grp = unique(tb.grp);
met = ["diffVd", "diffVf"];
metName = ["Diameter change (%)", "Flow change (%)"];
vtype = ["Arteriole", "Venule"];

clr = lines;
fig = NewFig2(2,2);  
for im=1:2
    for iv=0:1
        tb1 = tb(tb.vein==iv,:);
        subplot(2,2,(im-1)*2+iv+1);
%         swarmchart(tb.grp, tb.diff, [], [1 1 1]*0.7, Marker='.');
        tb1.grpId = ones(size(tb1,1),1);
        tb1.grpId(tb1.grp==grp(2)) = 2;
        swarmchart(tb1.grpId, tb1.(met(im)), [], [1 1 1]*0.7, Marker='.');
        PlotStatBox(tb1.(met(im)), tb1.grpId, [], [], 'k');
        ax = gca;
        ax.XLim = [1 2] + [-1 1]*0.6;
        ax.YLim = ax.YLim + [-1 1]*5;
%         line(ax.XLim, [0 0], Color='k');
        ax.XTick = [1 2];
        ax.XTickLabel = grp;
%         if im == 1
            ax.Title.String = vtype(iv+1);
%         end
%         if iv == 0
            ax.YLabel.String = metName(im);
%         end
        
        % stat
        md = sprintf("%s ~ grp + (1|animal)", met(im));
        lme = fitlme(tb1, md);
        [~, bOut] = rmoutliers(lme.residuals);
        if sum(bOut) > 0
            lme1 = fitlme(tb1, md, Exclude=find(bOut));
        else
            lme1 = lme;
        end

        fprintf("## %s : %s \n", met(im), vtype(iv+1));
        if IsNormDist(lme1.residuals)
            lme1
            xl = sprintf("p=%.3f, n=%d", lme1.Coefficients.pValue(2), size(tb1,1));
        else
            % Boot LME
            nBoot = 2000;  % for p value resolution of 0.001
            varNames = [met(im), "grp", "animal"];  % y, group, cluster/subject
            % use oResamp=obsGrp as the input variable is not fixed but random recruitment. 
            [blme, ~, fig1] = BootLME(nBoot, tb1, md, varNames, ...  % required inputs
                oResamp='obsGrp', bFig=true);  % options for bootstrap
%             blme
            blme.b
            blme.ci
            xl = sprintf("%.1f to %.1f %%, n=%d", blme.ci(2,1), blme.ci(2,2), size(tb1,1));
            SaveFig(fig1, true, "boot", sprintf("%s #%s #%s #boot", pathrepo, met(im), vtype(iv+1)));
        end
%         ax.XLabel.String = xl;
        ax.YLim = ax.YLim + [0 1] * diff(ax.YLim)*0.15;
        text(mean(ax.XLim), ax.YLim(2) - diff(ax.YLim)*0.05, ...
            sprintf("p=%.3f", lme1.Coefficients.pValue(2)), ...
            FontSize = 9, HorizontalAlignment='center');
        
    end
end
SaveFig(fig, true, "swarm", sprintf("%s #swarm", pathrepo));
    

%% Plot density: swarm (no hist)

tbDens.diff = (tbDens.dens2 ./ tbDens.dens1 - 1) * 100;
grp = unique(tbDens.grp);

met1 = "Pen. vessel density";

% stat: young against zero
tb1 = tbDens;
for ig=1:2
    ci = bootci(1000, @mean, tb1.diff(tb1.grp==grp(ig)));
    if ig == 1
        fprintf("%s in %s CI: %.1f to %.1f %% \n", met1, grp(ig), ci(1), ci(2));
    end
end

% stat: intragroup
y1 = tb1.diff(tb1.grp==grp(1));  y2 = tb1.diff(tb1.grp==grp(2));
[p, t, tBoot, effectSize] = BootCompareTwo(y1, y2);
fprintf("effectSize: %.0f to %.0f \n", effectSize.ci(1), effectSize.ci(2));

clr = lines;
fig = NewFig2(1,1);
tb1.grpId = ones(size(tb1,1),1);
tb1.grpId(tb1.grp==grp(2)) = 2;
%         swarmchart(tb1.grpId, tb1.diff, [], [1 1 1]*0.7, Marker='o');
%         swarmchart(tb1.grpId, tb1.diff, [], clr(1:2,:), Marker='o');
sw = swarmchart(repmat([1 2],[numel(y1) 1]), [y1, y2], [], clr(1:2,:), Marker='o', XJitterWidth=0.5);
ax = gca;
ax.XLim = [1 2] + [-1 1]*0.7;
%         ax.YLim = ax.YLim + [-1 1]*10;
ax.YLim = [min([y1, y2], [], 'all') max([y1, y2], [], 'all')] + [-1 1]*diff(ax.YLim)*0.25;
ax.YLim = ax.YLim + [0 1] * diff(ax.YLim) * 0.1;
ax.XTick = [1 2];
ax.XTickLabel = grp;
%         ax.XLabel.String = xl;
ax.YLabel.String = "Relative change (%)";
ax.Title.String = met1;
text(mean(ax.XLim), ax.YLim(2)-diff(ax.YLim)*0.05, ...
    sprintf("p=%.3f", p), FontSize = 9, HorizontalAlignment='center');
SaveFig(fig, true, "dens", sprintf("%s #dens", pathrepo));


%% (old) Stat: absolute values
%{
for is=1:2
    tb1 = tb;
    tb1.Vd = tb.(sprintf("Vd%d", is));
    md = "Vd ~ grp*vein + (1|animal)";
    fprintf("## %s: \n", status(is));
    lme = fitlme(tb1, md)
    IsNormDist(lme.residuals)
end

for is=1:2
    tb1 = tb;
    tb1.Vf2 = tb.(sprintf("Vf%d", is)).^2;
    md = "Vf2 ~ grp*vein + (1|animal)";
    fprintf("## %s: \n", status(is));
    lme = fitlme(tb1, md)
    IsNormDist(lme.residuals)
end
%}

%% Stat: difference in diameter
%{
md = "diffVd ~ grp + (1|animal)";
md = "diffVd ~ grp*vein + (1|animal)";
lme = fitlme(tb, md)

% remove outliers. fitlme does not provide Diagnostics property
[~, bOut] = rmoutliers(lme.residuals);
ioOut = find(bOut);  % indices of observation of outliers
NewFig2(2,2);
line(lme.fitted, lme.residuals, Marker='x', LineStyle='none');
if sum(bOut) > 0
    x = lme.fitted;  y = lme.residuals;
    line(x(bOut), y(bOut), Marker='o', Color='r', LineStyle='none')
end
ax = gca;
ax.YLim = [-1 1]*max(abs(ax.YLim));
line(ax.XLim, [0 0], Color='k');
ax.XLabel.String = "fitted";
ax.YLabel.String = "residuals";
ax.Title.String = sprintf("%d outliers detected", sum(bOut));
if sum(bOut) > 0
    lme1 = fitlme(tb, md, Exclude=ioOut)
else
    lme1 = lme;
end

if IsNormDist(lme.residuals)
    disp("LME residuals were normally distributed.");
else
    % Boot LME
    nBoot = 2000;  % for p value resolution of 0.001
    varNames = ["diffVd", "grp", "animal"];  % y, group, cluster/subject

    % use oResamp=obsGrp as the input variable is not fixed but random recruitment. 
    [blme, ~, fig] = BootLME(nBoot, tb, md, varNames, ...  % required inputs
        oResamp='obsGrp', bFig=true);  % options for bootstrap
    blme
    blme.b
    blme.ci
    SaveFig(fig, true, "boot", sprintf("%s #dia #boot", pathrepo));
end
%}

%% Stat: difference in flow
%{
md = "diffVf ~ grp + (1|animal)";
md = "diffVf ~ grp*vein + (1|animal)";
lme = fitlme(tb, md)

% remove outliers. fitlme does not provide Diagnostics property
[~, bOut] = rmoutliers(lme.residuals);
ioOut = find(bOut);  % indices of observation of outliers
NewFig2(2,2);
line(lme.fitted, lme.residuals, Marker='x', LineStyle='none');
if sum(bOut) > 0
    x = lme.fitted;  y = lme.residuals;
    line(x(bOut), y(bOut), Marker='o', Color='r', LineStyle='none')
end
ax = gca;
ax.YLim = [-1 1]*max(abs(ax.YLim));
line(ax.XLim, [0 0], Color='k');
ax.XLabel.String = "fitted";
ax.YLabel.String = "residuals";
ax.Title.String = sprintf("%d outliers detected", sum(bOut));
if sum(bOut) > 0
    lme1 = fitlme(tb, md, Exclude=ioOut)
else
    lme1 = lme;
end

if IsNormDist(lme.residuals)
    disp("LME residuals were normally distributed.");
else
    % Boot LME
    nBoot = 2000;  % for p value resolution of 0.001
    varNames = ["diffVf", "grp", "animal"];  % y, group, cluster/subject

    % use oResamp=obsGrp as the input variable is not fixed but random recruitment. 
    [blme, ~, fig] = BootLME(nBoot, tb, md, varNames, ...  % required inputs
        oResamp='obsGrp', bFig=true);  % options for bootstrap
    blme
    blme.b
    blme.ci
    SaveFig(fig, true, "boot", sprintf("%s #flow #boot", pathrepo));
end
%}



