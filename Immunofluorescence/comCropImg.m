function [img, mask] = comCropImg(img, mask)

% make grids gx and gy
[gx, gy] = meshgrid(1:size(mask,2), 1:size(mask,1));

% set gx and gy values zero outside the mask
gx(~mask) = 0;  gy(~mask) = 0;

% find the range xx and yy for the non-zero mask values
yy = min(gy(gy>0)):max(gy(:));
xx = min(gx(gx>0)):max(gx(:));

% crop both img and mask
img = img(yy,xx,:);
mask = mask(yy,xx);
    
    
