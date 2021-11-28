disp('SECTION 22 RUNNING ...');
% SetParPool(6);

%% ciz

if ~exist('ciz','var')
    ciz = zeros(nd,1);
    for id=1:nd
        [~,im] = max(cIz{id}(50:end));  
        ciz(id) = im-1 + 50;
        ciz(id) = ciz(id) + 50;  % 50 voxel beneath the surface
    end
end


%% UI
cmap = GetColorMap('doppler');
id = 1; 
figure(1);  clf;  colormap(cmap);
while true
    nz = size(cVV{id},1);
    iz = ciz(id);
    subplot(3,1,1:2);  cla;  hold on;
        PlotImage(squeeze(mean(cVV{id}(iz+(-zavg:zavg),:,:),1))',false,limV);
        title([cpid{id} '  iz=' num2str(iz) '/' num2str(nz)]);
    subplot(3,1,3);  cla;
        plot(cIz{id});  set(gca,'yscale','log');  line(iz*[1 1],get(gca,'ylim'));  
        title('Depth profile of intensity');
        xlabel('Select the depth here when you push G key.');
        
    if waitforbuttonpress
        cc = get(gcf,'CurrentCharacter');
        if strcmp(cc,'q')
            break;
        elseif strcmp(cc,'g')
%             subplot(3,1,3);
            g = round(ginput(1));
            ciz(id) = min(max(g(1),1+zavg),nz-zavg);
        elseif strcmp(cc,'f')
            id = min(id+1,nd);
        elseif strcmp(cc,'s')
            id = max(id-1,1);
        elseif strcmp(cc,'d')
            ciz(id) = min(iz+dz,nz-zavg);
        elseif strcmp(cc,'e')
            ciz(id) = max(iz-dz,1+zavg);
        end
    end
end


%% fig

figure('position',[.1 .1 4/4 2/4]*640);  colormap(cmap);
for id=1:min(nd,8)
    subplot(2,4,id);  hold on;
    PlotImage(squeeze(mean(cVV{id}(ciz(id)+(-zavg:zavg),:,:),1))',false,limV);
end
sgtitle([ 'Doppler en face. color = ' mat2str(limV) ' mm/s' ]);
savefig(gcf,[pathrepo ' #22.fig']); 
saveas(gcf,[pathrepo ' #22.png']);


disp('SECTION 22 COMPLETED.');