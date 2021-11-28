disp('SECTION 21 RUNNING ...');

nd = length(cpid);
for id=1:nd
    if length(ceid) > 1
        load(['D:/' uid '/' ceid{id} '/' cpid{id} '.mat'], 'DD','conf');
    else
        load(['D:/' uid '/' ceid{1} '/' cpid{id} '.mat'], 'DD','conf');
    end
    D1 = squeeze(max(DD,[],1));
    if id == 1
        [nx,ny] = size(D1);  D = zeros(nx,ny,nd);  cconf = cell(nd,1);  % should have the same size for the common ROI (Section 7)
    end
    if size(D1,1) < nx  % for some of Jose's data
        [nx1,ny1] = size(D1);
%         cD((nx-nx1)/2+(1:nx1),(nx-ny1)/2+(1:ny1),id) = D;
        [mx,my] = meshgrid(linspace(1,nx1,nx),linspace(1,ny1,ny));
        D(:,:,id) = interp2(D1,mx,my);
    else
        D(:,:,id) = D1;  
    end
    cconf{id} = conf;
end
clear DD D1;

limD = log10([GetSorted(D(:),limC(1)) GetSorted(D(:),limC(2))]);
figure('position',[.1 .1 4/4 2/4]*640);  colormap(gray);
for id=1:nd
    subplot(2,5,id);  hold on;  PlotImage(log10(D(:,:,id))',false,limD,false);  
end
savefig(gcf,[pathrepo ' # 21.fig']); 
saveas(gcf,[pathrepo ' # 21.png']);

%{
% for some reason, the figure below was pixelized very badly.
figure('position',[.1 .1 4/4 2/4]*640*2);  colormap(gray);
cimg = cell(2,5);
for id=1:nd
    if (id < 6),  cimg{1,id} = log10(D(:,ny:-1:1,id))';  else,  cimg{2,id-5} = log10(D(:,ny:-1:1,id))';  end
end
PlotImageSeq(cimg,limD,10,'w');  axis image;  set(gca,'xtick',[]);  set(gca,'ytick',[]);
%}

disp('SECTION 21 COMPLETED.');
