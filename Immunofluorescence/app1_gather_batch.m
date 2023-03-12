%% Gather IBA-1 and GFAP images

function app1_gather(p1suff, id)

% close all;  clc;  clear; 
comInit;


%% Load meta data

[tbMeta, nd] = comGetMeta();
% tbMeta
if id > nd
    error("id=%d larger than nd=%d", id, nd);
end


%% p1.opt

p1suff = string(p1suff);
% p1suff = "p1a";

opt = struct;
switch p1suff
    case "p1a"
        % default : better for segmentation? Not necessaarily if we include the cortical
        % surface in ROI. Anyway it would be OK as Goldey 2014 also has strong
        % backgrounds. Maybe this is better, and then imadjust again within the ROI 
        opt.prcIba = [1 99];  
        opt.prcGfap = [1 99];
    
    case "p1b"
        opt.prcIba = [50 99];
        opt.prcGfap = [1 99];  % almost no background
    
    otherwise
        error("unimplemented p1a");
end

% id = 5;  % best Iba1?
% id = 37;  % best gfap?
% parfor id=1:nd

    %% Load TIFF file

    tbMeta1 = tbMeta(id,:);
    
    % p1
    p1 = struct;
    p1.id = sprintf("%s-%s", tbMeta1.did, p1suff);
    p1.meta = tbMeta1;
    p1.opt = opt;
    
    p1.uid = tbMeta1.uid;
    p1.eid = tbMeta1.eid;
    p1.did = tbMeta1.did;
    p1.pathraw = sprintf("%s/%s/%s", pathraw0, p1.uid, p1.eid);
    p1.pathdata = sprintf("%s/%s/%s", pathdata0, p1.uid, p1.eid);
    if isempty(dir(p1.pathdata)),  mkdir(p1.pathdata);  end
    p1.pathrepo = sprintf("%s/1Gather #%s #%s #%s", pathrepo0, p1.uid, p1.eid, p1.id);

    if contains(p1.eid, "iba1")
        p1.chImmu = 2;
    else
        p1.chImmu = 1;
    end
    
    % read
    fpath = sprintf("%s/%s.tif", p1.pathraw, p1.did);
    % dir(fpath)
    p1.imginfo = imfinfo(fpath);
    nch = numel(p1.imginfo);

    
    %% adjust contrast for each channel and merge
    
    % selected colors following https://www.abcam.com/ps/products/175/ab175477/Images/ab175477-216882-goat-anti-chicken-igy-hl-alexa-fluor-568-alexa-fluor.jpg
    img = zeros(p1.imginfo(1).Height, p1.imginfo(1).Width, 3, 'uint16');
    if contains(p1.eid, "iba1")  % R=none, G=Iba1, B=DAPI
        img(:,:,3) = imadjust(imread(fpath, 1));
        img0 = imread(fpath, 2);
        img(:,:,p1.chImmu) = imadjust(img0, double(prctile(img0, opt.prcIba, 'all'))/65535);
        
                % when tested with bottom [0 1 2 3 4 5]% was [658 1641 167 1701 1721 1738]
                % imadjust made [min max] = 
                %   [0 65535] with none (default)
                %   [658 65535] with [0 1]
                %   [3 65535] with [0.01 0.99]
%                 img0 = imread(fpath, 2);
%                 img1 = imadjust(img0);  % [1% 99%]p1
%                 img2 = imadjust(img0, [0.1 0.5]);
%                 img2 = imadjust(img0, double(prctile(img0, [10 50], 'all'))/65535);
%                 img1r = Rescale(img0, [0 65535], prctile(img0, [1 99],'all'));
%                 img2r = Rescale(img0, [0 65535], prctile(img0, [10 50],'all'));
%                 figure;
%                 clr = lines;
%                 [n, edg] = histcounts(img2(:));  line(edg(2:end), log(n));
%                 [n, edg] = histcounts(img2r(:));  line(edg(2:end), log(n), Color=clr(2,:));
%                 [min(img0,[],'all'), max(img0,[],'all')]
%                 img0p = zeros(6,1);
%                 for ip=0:5
%                     img0p(ip+1) = prctile(img0, ip, 'all');
%                 end
%                 img0p
                    
    else  % R=GFAP, G=none, B=DAPI
        img(:,:,3) = imadjust(imread(fpath, 1));
        % Leduc (mistakenly) took GFAP in the 3rd channel
        img0 = imread(fpath, 3);
        img(:,:,p1.chImmu) = imadjust(img0, double(prctile(img0, opt.prcGfap, 'all'))/65535);  
    end

    fig = figure;  fid = "#11-channel";
    montage(img, BorderSize=1, BackgroundColor='w');
    xlabel(sprintf("prcIba = %s, prcGfap = %s", ...
        mat2str(opt.prcIba), mat2str(opt.prcGfap)));
    title(sprintf("%s %s", p1.id, fid));
    SaveFig(fig, false, fid, sprintf("%s %s", p1.pathrepo, fid));
    
    fig = figure;  fid = "#12-color";
    imshow(img)
%     ax = gca;
%     ax.XLim = [6790 9240];
%     ax.YLim = [830 2560];
    xlabel(sprintf("prcIba = %s, prcGfap = %s", ...
        mat2str(opt.prcIba), mat2str(opt.prcGfap)));
    title(sprintf("%s %s", p1.id, fid));
    SaveFig(fig, false, fid, sprintf("%s %s", p1.pathrepo, fid));
    
    fig = figure;  fid = "#13-immu";
    imshow(img(:,:,p1.chImmu))
%     ax = gca;
%     ax.XLim = [6790 9240];
%     ax.YLim = [830 2560];
    xlabel(sprintf("prcIba = %s, prcGfap = %s", ...
        mat2str(opt.prcIba), mat2str(opt.prcGfap)));
    title(sprintf("%s %s", p1.id, fid));
    SaveFig(fig, false, fid, sprintf("%s %s", p1.pathrepo, fid));
    
    fpath = sprintf("%s/%s.mat", p1.pathdata, p1.id);
    save(fpath, 'img', 'p1');
    fprintf("%s saved. \n", p1.id);

% end
% disp("ALL COMPLETED.");




%% stat

% 1. the min quality to include
% 
% find the best stat from the above combinations

