disp('SECTION 23 RUNNING ...');

Dc = D;  cxcr = zeros(1,nd);  cxcr0 = zeros(1,nd);  cr = zeros(1,nd);  ccor = zeros(2,nd);  ct = zeros(2,nd);

figure(1);  clf;  colormap(gray);
for id=1:nd
    if id ~= ap.id0
        [Dc(:,:,id),cxcr(id),cxcr0(id),cr(id),ccor(:,id),ct(:,id)] = Coregister2D(D(:,:,id), D(:,:,ap.id0), ap.fp(:,:,id), ap.fp(:,:,ap.id0), id);
        pause(.1);
    end
end
savefig(gcf,[pathrepo ' # 23-1.fig']); 
saveas(gcf,[pathrepo ' # 23-1.png']);

figure('position',[.1 .1 4/4 2/4]*640);  colormap(gray);
for id=1:nd
    subplot(2,5,id);  hold on;  PlotImage(log10(Dc(:,:,id))',false,limD,false);  
end
% cimg = cell(2,5);
% for id=1:nd
%     if (id < 6),  cimg{1,id} = log10(Dc(:,ny:-1:1,id))';  else,  cimg{2,id-5} = log10(Dc(:,ny:-1:1,id))';  end
% end
% PlotImageSeq(cimg,limD,10,'w');  axis image;  set(gca,'xtick',[]);  set(gca,'ytick',[]);
savefig(gcf,[pathrepo ' # 23.fig']); 
saveas(gcf,[pathrepo ' # 23.png']);

disp('SECTION 23 COMPLETED.');