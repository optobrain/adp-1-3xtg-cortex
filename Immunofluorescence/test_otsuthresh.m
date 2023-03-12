% https://www.mathworks.com/help/images/ref/otsuthresh.html

clear;

img = imread('coins.png');

[counts, x] = imhist(img, 16);
thrR = otsuthresh(counts)  % [0 1]

fig = NewFig(3,3);
subplot(221);
stem(x, counts, Color='k');

subplot(222);
bw = imbinarize(img, thrR);
imshow(bw)
title(sprintf("thrR=%.3f", thrR));

thr = prctile(img, thrR*100, 'all');
subplot(221);
line([1 1]*double(thr), get(gca,'ylim'), Color='b');
subplot(223);
imshow(img>thr)
title(sprintf("img>%d (thrR*100)%%", thr));

thr = prctile(img, (1-thrR)*100, 'all');
subplot(221);
line([1 1]*double(thr), get(gca,'ylim'), Color='r');
subplot(224);
imshow(img>thr)
title(sprintf("img>%d ((1-thrR)*100)%%", thr));

% copied from imbinarize()
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

subplot(221);
line([1 1]*double(thr), get(gca,'ylim'), Color='g');
subplot(224);
imshow(img>thr)
title(sprintf("img>%d (thrR*range)%%", thr));


