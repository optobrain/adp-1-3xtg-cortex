%% Detect cells from DAPI channel

function app2_dapi(p1suff, p2suff, id)

% close all;  clc;  clear; 
comInit;


%% Load meta data

[tbMeta, nd] = comGetMeta();
tbMeta
dx = 0.65;  % um/pix
bFig = true;  % save fig files too?


%% Set p2suff

% p1suff = "p1a";
% p2suff = "p2a";

p1suff = string(p1suff);
p2suff = string(p2suff);

opt = struct;
switch p2suff
    case "p2a"
        opt.dia = [5 15];  % [um] in diameter: 8-23 px
        opt.sen = 0.85;  % sensitivity of findcircle

    case "p2b"
        opt.dia = [5 15];  % [um] in diameter: 8-23 px
        opt.sen = 0.90;  % sensitivity of findcircle
        
    case "p2c"
        opt.dia = [5 15];  % [um] in diameter: 8-23 px
        opt.sen = 0.95;  % sensitivity of findcircle
        
    otherwise
        error("unimplemented p2suff");
end

% id = 5;  % best Iba1?

    %% Load p1

    tbMeta1 = tbMeta(id,:);
    
    % p2
    p2 = struct;
    p2.id = sprintf("%s-%s-%s", tbMeta1.did, p1suff, p2suff);
    p2.dx = dx;
    p2.opt = opt;
    
    p2.uid = tbMeta1.uid;
    p2.eid = tbMeta1.eid;
    p2.did = tbMeta1.did;
    p2.pathdata = sprintf("%s/%s/%s", pathdata0, p2.uid, p2.eid);
    if isempty(dir(p2.pathdata)),  mkdir(p2.pathdata);  end
    p2.pathrepo = sprintf("%s/2dapi #%s #%s #%s", pathrepo0, p2.uid, p2.eid, p2.id);

    % read
    fpath = sprintf("%s/%s-%s.mat", p2.pathdata, p2.did, p1suff);
    l = load(fpath);  % p1, img
    p2.p1 = l.p1;

    % crop image
    [img, mask] = comCropImg(l.img, p2.p1.maskL | p2.p1.maskR);

    % take the DAPI channel
    imgN = img(:,:,3);
    imgN(~mask) = 0;
    
    fig = figure;  fid = "#21-crop";
    imshow(imgN);
    title(sprintf("%s %s", p2.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p2.pathrepo, fid));
    
    
    %% detect circles
    % algorithm accuracy is limited for radius values less than or equal to 5.
    
    [cent, rad, metr] = imfindcircles(imgN, max(round(p2.opt.dia/2/p2.dx),6), Sensitivity=p2.opt.sen);
    
    % plot
    figure(fig.Number);  fid = "#22-cell";
%     viscircles(cent, rad, EdgeColor='r');
    line(cent(:,1), cent(:,2), Marker='.', LineStyle='none', Color='r');
    xlabel(sprintf("%d cells detected.", numel(rad)));
    title(sprintf("%s %s", p2.id, fid));
    SaveFig(fig, bFig, fid, sprintf("%s %s", p2.pathrepo, fid));
    
    
    %% save
    
    r2 = struct;
    r2.cent = cent;
    r2.rad = rad;
    r2.metr = metr;
    fpath = sprintf("%s/%s.mat", p2.pathdata, p2.id);
    save(fpath, 'p2', 'r2', 'img', 'mask');
    fprintf("%s saved. \n", p2.id);
    
    
