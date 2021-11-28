disp('SECTION 21b RUNNING ...');

%% ap.xx, ap.yy

ap.xx = round(nx/2-nx1/2) - 1 + (1:nx1);
ap.yy = round(ny/2-nx1/2) - 1 + (1:nx1);


%% replace zeros with non-zero min.

DD1 = DD(1:nz1,ap.xx,ap.yy);
DD1 = DD1(:);
% idx = find(DD1 == 0);
% Dmin = min(DD1(DD1>0));
DD1(DD1==0) = min(DD1(DD1>0));
DD1 = reshape(DD1,[nz1 nx1 nx1]);


%% fig

figure('position',[.1 .1 2/4 2/4]*640);  colormap(gray);  hold on;
PlotImage(squeeze(log(max(DD1,[],1)))',false,log(limD));  title('MIP after cropping');
savefig(gcf,[pathrepo '21b.fig']);
saveas(gcf,[pathrepo '21b.png']);
    

disp('SECTION 21b COMPLETED.');