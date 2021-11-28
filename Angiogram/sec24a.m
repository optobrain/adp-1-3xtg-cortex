disp('SECTION 24a RUNNING ...');

cm = zeros(128,3);  cm(1:64,:) = gray(64);  cm(65:128,3) = linspace(0,1,64);
B = ~isnan(Dc);
Bp = prod(B,3);
while true
    figure(1);  clf;  colormap(cm);  hold on;  
        PlotImage(Rescale(Dc(:,:,ap.id0),[0 0.9],10.^limD)',false,[0 2],false);
        PlotImage((1-Bp')+1,false,[0 2],false,[],1-Bp');
        set(gca,'CLim',[0 2]);
        PlotBox(xx,yy,'r');
        if prod(prod(Bp(xx,yy))) == 0
            title('WARNING: ROI includes NaN pixels. Select ROI again');
        else
            title(['ROI has ' num2str(sum(sum(Bp(xx,yy)))) ' pixels']);
        end
        xlabel(['G: select ROI, Q: quit']);

    if waitforbuttonpress
        cc = get(gcf,'CurrentCharacter');
        if strcmp(cc,'q')
            break;
        elseif strcmp(cc,'g')
            h = imrect;
            roi = round(wait(h));
            delete(h);
            xx = roi(1)+[1:roi(3)];
            yy = roi(2)+[1:roi(4)];
        end
    end
end

ap.xx = xx;
ap.yy = yy;

figure('position',[.1 .1 2/4 2/4]*640);  colormap(gray);  hold on;  
PlotImage(Bp',0,[0 1]);  PlotBox(xx,yy,'r');
title(['ROI has ' num2str(sum(sum(Bp(xx,yy)))) ' pixels']);
savefig(gcf,[pathrepo ' # 24a.fig']); 
saveas(gcf,[pathrepo ' # 24a.png']);

disp('SECTION 24a COMPLETED.');
