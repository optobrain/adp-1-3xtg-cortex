disp('SECTION 21 RUNNING ...');  

%% remove the depths of all zero?  NO: we need to keep zz for future comparison with original DD?
%{
Dz = mean(DD(:,:),2);
idx = find(Dz==0)
if length(idx) > 0
    DD = DD(max(idx):size(DD,1),:,:);
end
%}


%% ap.iz,  ap.limD
[nz,nx,ny] = size(DD);
if exist('ap','var') && isfield(ap,'iz')
    iz = ap.iz;
else
    iz = round(nz*.25);
end
% Dz = mean(DD(:,:),2);
Dz = max(DD(:,:),[],2);
limD = [GetSorted(Dz,limDr(1)) GetSorted(Dz,limDr(2))];  % we need to this every time because the user may have changed limDr.


%% UI

while true
    figure(1);  clf;  colormap(gray);  hold on;
    PlotImage(squeeze(log(DD(iz,:,:)))',false,log(limD));
    title([ 'iz = ' num2str(iz) '/' num2str(nz) ]);

    if waitforbuttonpress
        cc = get(gcf,'CurrentCharacter');
        if strcmp(cc,'q')
            break;
        elseif strcmp(cc,'d')
            iz = min(iz+diz,nz);
        elseif strcmp(cc,'e')
            iz = max(iz-diz,1);
        end
    end
end
ap.iz = iz;
ap.limD = limD;


%% fig

figure('position',[.1 .1 2/4 2/4]*640);  colormap(gray);  hold on;
PlotImage(squeeze(log(DD(iz,:,:)))',false,log(limD));
title([ 'iz = ' num2str(iz) '/' num2str(nz) ]);
xlabel([ 'limDr = ' mat2str(limDr) ]);
savefig(gcf,[pathrepo '21.fig']);
saveas(gcf,[pathrepo '21.png']);


disp('SECTION 21 COMPLETED.');