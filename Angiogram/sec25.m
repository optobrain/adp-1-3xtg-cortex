disp('SECTION 25 RUNNING ...');

D = Dc(xx,yy,:);
figure('position',[.1 .1 4/4 2/4]*640);  colormap(gray);
for id=1:nd
    subplot(2,5,id);  hold on;  PlotImage(log10(D(:,:,id))',false,limC,true);  title(cpid{id});
end
savefig(gcf,[pathrepo ' # 25.fig']); 
saveas(gcf,[pathrepo ' # 25.png']);

disp('SECTION 25 COMPLETED.');
