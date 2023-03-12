%% Gather and ROI IBA-1 and GFAP images

% function app1_gather(p1suff, id)

close all;  clc;  clear; 
comInit;

bFig = true;  % save fig file as well?

%% Load meta data

[tbMeta, nd] = comGetMeta();
tbMeta

% if id > nd
%     error("id=%d larger than nd=%d", id, nd);
% end


%% p1.opt

% p1suff = string(p1suff);
p1suff = "p1a";

opt = struct;
switch p1suff
    case "p1a"
        % default : include cortical surface in ROI
        opt.bIncSurf = true;
    
    case "p1b"
        opt.bIncSurf = false;
    
    otherwise
        error("unimplemented p1a");
end

% id = 5;  % best Iba1?
% id = 37;  % best gfap?
for id=1:nd

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
        img(:,:,p1.chImmu) = imadjust(imread(fpath, 2));
    else  % R=GFAP, G=none, B=DAPI
        img(:,:,3) = imadjust(imread(fpath, 1));
        % Leduc (mistakenly) took GFAP in the 3rd channel
        img(:,:,p1.chImmu) = imadjust(imread(fpath, 3));
    end

    fig = figure;  fid = "#11-channel";
    montage(cat(3, img, max(img,[],3)), BorderSize=1, BackgroundColor='w');
    xlabel("channels 1-3, MIP along channel");
    title(sprintf("%s %s", p1.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p1.pathrepo, fid));
    
    fig = figure;  fid = "#12-color";
    imshow(img)
%     ax = gca;
%     ax.XLim = [6790 9240];
%     ax.YLim = [830 2560];
    title(sprintf("%s %s", p1.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p1.pathrepo, fid));
    
    fig = figure;  fid = "#13-immu";
    imshow(img(:,:,p1.chImmu))
%     ax = gca;
%     ax.XLim = [6790 9240];
%     ax.YLim = [830 2560];
    title(sprintf("%s %s", p1.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p1.pathrepo, fid));
    
    
    %% ROI
    
    % don't run two roi's at once: the cursor misaligned.
%     close all  % need this 
%     pause(2)
    figL = figure;  fid = "#14-roiL";
    imshow(img);
    title(sprintf("%d/%d : %s %s : Draw LEFT hemisphere ROI, modify, and push space key.", id, nd, p1.id, fid));
    figL.WindowState = 'maximize';
    ax = gca;
    roiL = drawpolygon(ax);
    pause;
    roiPosL = roiL.Position;
    maskL = createMask(roiL);
%     roiL = drawassisted(ax);  % not different
%     SaveFig(figL, false, fid, sprintf("%s %s", p1.pathrepo, fid));
    
%     close all  % if I do this, roiL is lost
%     figR = figure;  fid = "#14-roiR";
%     imshow(img);
    title(sprintf("%d/%d : %s %s : Draw RIGHT hemisphere ROI, modify, and push space key.", id, nd, p1.id, fid));
%     figR.WindowState = 'maximize';
%     ax = gca;
    roiR = drawpolygon(ax);
    pause;
    roiPosR = roiR.Position;
    maskR = createMask(roiR);
%     SaveFig(figR, false, fid, sprintf("%s %s", p1.pathrepo, fid));

%     p1.roiL = roiL;
%     p1.roiR = roiR;
    p1.roiPosL = roiPosL;
    p1.roiPosR = roiPosR;
    p1.maskL = maskL;
    p1.maskR = maskR;

    
    %% adjust again based on ROI intensity histogram
    
    fig = figure;  fid = "#15-roi";
    imshow(img);
    roiPos = [roiPosL; roiPosL(1,:)];
    line(roiPos(:,1), roiPos(:,2), Color='y', LineWidth=2);
    roiPos = [roiPosR; roiPosR(1,:)];
%     line(roiPos(:,1), roiPos(:,2), Color='y', Marker='.', MarkerSize=15, LineWidth=2);
    line(roiPos(:,1), roiPos(:,2), Color='y', LineWidth=2);
%     imshow(maskL | maskR)
    title(sprintf("%s %s", p1.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p1.pathrepo, fid));
    
    imgImmu = img(:,:,p1.chImmu);
    imgImmuRoi = imgImmu(maskL | maskR);
    imgRoiAdj = imadjust(imgImmu, double(prctile(imgImmuRoi, [1 99]))/65535);
    fig = figure;  fid = "#16-roiAdj";
    montage({imgImmu, imgRoiAdj});
    title(sprintf("%s %s", p1.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p1.pathrepo, fid));
    p1.imgRoiAdj = imgRoiAdj;

    
    %% save
    
    close all
    fpath = sprintf("%s/%s.mat", p1.pathdata, p1.id);
    save(fpath, 'p1', 'img');
    fprintf("%s saved. \n", p1.id);

end
disp("ALL COMPLETED.");




%% stat

% 1. the min quality to include
% 
% find the best stat from the above combinations

