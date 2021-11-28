disp('SECTION 24a RUNNING ...');


%% UI

cm = zeros(128,3);  cm(1:64,:) = cmap;  cm(65:128,2) = linspace(0,1,64);
B = ~isnan(Vc);
Bp = prod(B,3);
while true
    figure(1);  clf;  colormap(cm);  hold on;  
        PlotImage(Rescale(Vc(:,:,apA.id0),[0 0.9],limV)',false,[0 2],false);
        PlotImage((1-Bp')+1,false,[0 2],false,[],1-Bp');
        set(gca,'CLim',[0 2]);
        PlotBox(xx,yy,'w');
        if prod(prod(Bp(xx,yy))) == 0
            title('WARNING: ROI includes NaN pixels. Select ROI again');
        else
            title(['ROI has ' num2str(sum(sum(Bp(xx,yy)))) ' pixels']);
        end

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


%% fig

figure('position',[.1 .1 4/4 2/4]*640);  colormap(gray);
for id=1:min(nd,9)
    subplot(2,5,id);  hold on;  PlotImage(B(:,:,id)',0,[0 1]); 
end
subplot(2,5,nd+1);  hold on;  PlotImage(Bp',0,[0 1]);  PlotBox(xx,yy,'r');
sgtitle(['ROI has ' num2str(sum(sum(Bp(xx,yy)))) ' pixels']);
savefig(gcf,[pathrepo ' #24a.fig']); 
saveas(gcf,[pathrepo ' #24a.png']);


disp('SECTION 24a COMPLETED.');
