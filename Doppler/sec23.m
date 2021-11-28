disp('SECTION 23 RUNNING ...');
SetParPool(6);

%% register

[nz,nx,ny] = size(cVV0{1});  Vc = zeros(nx,ny,nd);
for id=1:nd
    if ~ap.bSkip && ap.bAngRegister && id ~= apA.id0
        VV = cVV0{id};
        cr1 = cr(id);  ccor1 = ccor(:,id);  ct1 = ct(:,id);  % for parfor
        parfor iz=1:size(VV,1)
            VV(iz,:,:) = RotateImage(squeeze(VV(iz,:,:)), cr1, ccor1-[nx ny]'/2, ct1);
            % cor: 512 => 256, 256 => 0  750 => 512
        end
        cVV{id} = VV;
        disp([datestr(now,'HH:MM') ' registered ' num2str(id) '/' num2str(nd)]);
    end
    Vc(:,:,id) = squeeze(mean(cVV{id}(ciz(id)+(-zavg:zavg),:,:),1));
end


%% fig

figure('position',[.1 .1 4/4 2/4]*640);  colormap(cmap);
for id=1:min(nd,8)
    subplot(2,4,id);  hold on;
    PlotImage(Vc(:,:,id)',false,limV);
end
sgtitle([ 'After registration. color = ' mat2str(limV) ' mm/s' ]);
savefig(gcf,[pathrepo ' #23.fig']); 
saveas(gcf,[pathrepo ' #23.png']);


disp('SECTION 23 COMPLETED.');