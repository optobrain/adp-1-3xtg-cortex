disp('SECTION 25 RUNNING ...');

V = Vc(xx,yy,:);
figure('position',[.1 .1 4/4 2/4]*640);  colormap(cmap);
for id=1:min(nd,8)
    subplot(2,4,id);  hold on;  PlotImage(V(:,:,id)',false,limV);
end
savefig(gcf,[pathrepo ' #25.fig']); 
saveas(gcf,[pathrepo ' #25.png']);

disp('SECTION 25 COMPLETED.');
