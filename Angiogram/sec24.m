disp('SECTION 24 RUNNING ...');

B = ~isnan(Dc);
Bp = prod(B,3);
figure(1);  clf;  colormap(gray);
for id=1:nd
    subplot(4,4,id);  cla;  hold on;  PlotImage(B(:,:,id)',0,[0 1]);  title(cpid{id});
end
subplot(4,4,nd+1);  cla;  hold on;  PlotImage(Bp',0,[0 1]);

p = FindMaxRect(Bp,ap.oini,nd);
xx = p(1,1):p(1,2);
yy = p(2,1):p(2,2);

if prod(prod(Bp(xx,yy))) == 0
    error(['ROI exceeds the common area.' newline 'Try different ap.oini.']);
else
    figure('position',[.1 .1 4/4 2/4]*640);  colormap(gray);
    for id=1:nd
        subplot(2,5,id);  cla;  hold on;  PlotImage(B(:,:,id)',0,[0 1]); 
    end
    subplot(2,5,nd+1);  cla;  hold on;  PlotImage(Bp',0,[0 1]);  PlotBox(xx,yy,'r');
    savefig(gcf,[pathrepo ' # 24.fig']); 
    saveas(gcf,[pathrepo ' # 24.png']);
    
    ap.xx = xx;
    ap.yy = yy;

    disp(['SECTION 24 COMPLETED.' newline 'If the result is satisfactory, skip Sec 24a.']);
end

