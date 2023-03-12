%% Segment IBA-1 and GFAP images

function app3_segment(p1suff, p3suff, id)
% close all;  clc;  clear; 
comInit;

bFig = true;  % save fig as well?

%% Load meta data

[tbMeta, nd] = comGetMeta();
tbMeta
dx = 0.65;  % um/pix


%% Set p3suff

% p1suff = "p1a";
% p3suff = "p3d";
p1suff = string(p1suff);
p3suff = string(p3suff);

opt = struct;
switch p3suff
    case "p3a"
        % default : better for segmentation? Not necessaarily if we include the cortical
        % surface in ROI. Anyway it would be OK as Goldey 2014 also has strong
        % backgrounds. Maybe this is better, and then imadjust again within the ROI 
        opt.prcIba = [];  % images were already adjusted by [1 99] in app1
        opt.prcGfap = [];
        opt.seg = "globThres";
        opt.dia = [5 20];  % [um] equivalent diameter of immune cells in area

    case "p3b"
        opt.prcIba = [];  
        opt.prcGfap = [];
        opt.seg = "adapThres";
        opt.sens = 0.5;
        opt.dia = [5 20];  % iba1
        opt.dia = [10 30];  % iba1
        opt.diaGfap = [10 30];  % gfap?
       
    case "p3c"
        opt.prcIba = [50 99];
        opt.prcGfap = [];  % almost no background
        opt.seg = "globThres";
        opt.dia = [5 20];  
    
    case "p3d"
        opt.prcIba = [50 99];
        opt.prcGfap = [];  % almost no background
        opt.seg = "adapThres";
        opt.sens = 0.5;
        opt.dia = [5 20];  
    
    otherwise
        error("unimplemented p2suff");
end

% id = 5;  % best Iba1?


    %% Load p1 and further adjust contrast

    tbMeta1 = tbMeta(id,:);
    
    % p3
    p3 = struct;
    p3.id = sprintf("%s-%s-%s", tbMeta1.did, p1suff, p3suff);
    p3.dx = dx;
    p3.opt = opt;
    
    p3.uid = tbMeta1.uid;
    p3.eid = tbMeta1.eid;
    p3.did = tbMeta1.did;
    p3.pathdata = sprintf("%s/%s/%s", pathdata0, p3.uid, p3.eid);
    if isempty(dir(p3.pathdata)),  mkdir(p3.pathdata);  end
    p3.pathrepo = sprintf("%s/3segment #%s #%s #%s", pathrepo0, p3.uid, p3.eid, p3.id);

    % read
%     fpath = sprintf("%s/%s-%s-%s.mat", p3.pathdata, p3.did, p1suff, p2suff);
%     l = load(fpath);  % p2, r2, img, mask
    fpath = sprintf("%s/%s-%s.mat", p3.pathdata, p3.did, p1suff);
    l = load(fpath);  % p1, img
    p3.p1 = l.p1;
    
    % crop image
    [img, mask] = comCropImg(l.img, l.p1.maskL | l.p1.maskR);

    % take the immu channel
    img = img(:,:,p3.p1.chImmu);
    img(~mask) = 0;
    
    
    % further adjust contrast for immuno image
    if ~isempty(p3.opt.prcIba) && contains(p3.eid, "iba1")
        img = imadjust(img, double(prctile(img(mask), p3.opt.prcIba, 'all'))/65535);
    end
    if ~isempty(p3.opt.prcGfap) && contains(p3.eid, "gfap")
        img = imadjust(img, double(prctile(img(mask), p3.opt.prcGfap, 'all'))/65535);
    end
        
    % plot
    fig = figure;  fid = "#31-immu";
    imshow(img);
    title(sprintf("%s %s", p3.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p3.pathrepo, fid));

    
    %% segment
    
    switch p3.opt.seg
        case "globThres"
            % we want to exclude the pixels outside of ROI in determining threshold.  But
            % the code below did not work when tested with coins.png (see example of
            % otsuthresh).  The percentile of the image intensity using either the output 
            % of otsuthresh (value between 0 and 1) or 1-value did not produce the same
            % result as imbinarize(I, T)
            %{
            [counts, x] = histcounts(img(mask));
            thrR = otsuthresh(counts);  % [0 1]
            thr = prctile(img(mask), thrR*100);
            fig = NewFig2(1.5, 1.5);  fid = "#32-hist";
%             stem(x(2:end), counts);
            plot(x(2:end), counts);
            line([1 1]*double(thr), get(gca,'ylim'), Color='r');
            xlabel(
            title(sprintf("%s %s", p3.id, fid));
            SaveFig(fig, false, fid, sprintf("%s %s", p3.pathrepo, fid));
            bw = img > thr;
%             bw = imbinarize(img, thr);
%             img3 = img2;
%             img3(~(bwL | bwR)) = 0;
%             bw = imbinarize(img3);
            figure;  imshow(bw);
            %}

            % I found what the output of otsuthresh means: thr = output * classrange
            % see test_otsuthresh.m
            [counts, x] = histcounts(img(mask));
            thrR = otsuthresh(counts);  % [0 1]
            classrange = getrangefromclass(img);
            switch class(img)
                case {'uint8','uint16','uint32'}
                    thr = thrR * classrange(2);
                case {'int8','int16','int32'}
                    thr = classrange(1) + (classrange(2)-classrange(1))*thrR;
                case {'single','double'}
                    thr = thrR;
            end
            bw = img > thr;

            fig = NewFig2(1.5, 1.5);  fid = "#32-hist";
            plot(x(2:end), counts);
            line([1 1]*double(thr), get(gca,'ylim'), Color='r');
            xlabel(sprintf("%.0f%% of ROI foreground", sum(bw(:))/sum(mask(:))*100));
            title(sprintf("%s %s", p3.id, fid));
            SaveFig(fig, false, fid, sprintf("%s %s", p3.pathrepo, fid));
            
        case "adapThres"
            
            bw = imbinarize(img, 'adaptive', Sensitivity=p3.opt.sens);
            
        otherwise
            error("unsupported p3.opt.seg.");
            
    end
    
    fig = figure;  fid = "#33-seg";
    imshow(bw);
    title(sprintf("%s %s", p3.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p3.pathrepo, fid));

    
    %% filter objects

    dia = p3.opt.dia;
    if contains(p3.eid, "gfap")
        dia = p3.opt.diaGfap;
    end
    
    if ~isempty(dia)
        bw = bwpropfilt(bw, "EquivDiameter", dia/p3.dx);
    
        fig = figure;  fid = "#34-filt";
        imshow(bw);
        title(sprintf("%s %s", p3.id, fid));
        SaveFig(fig, bFig, fid, sprintf("%s %s", p3.pathrepo, fid));
    end
    
    
    %% find objects
    
    cc = bwconncomp(bw);
    lb = labelmatrix(cc);
    fig = figure;  fid = "#35-cell";
%     lbc = label2rgb(lb, @lines, "k");
%     imshow(lbc);
%     imshow(img);
%     hold on;
%     imagesc(lbc, AlphaData=lb>0);
%     nc = cc.NumObjects;
    imshow(labeloverlay(img, lb));
    title(sprintf("%s %s", p3.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p3.pathrepo, fid));

    
    %% save
    
    r3 = struct;
    r3.img = img;
    r3.bw = bw;
    r3.cc = cc;
    r3.lb = lb;
    fpath = sprintf("%s/%s.mat", p3.pathdata, p3.id);
    save(fpath, 'p3', 'r3');
    fprintf("%s saved. \n", p3.id);
    
