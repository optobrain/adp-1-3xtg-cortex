disp('SECTION 15 RUNNING ...');
SetParPool(4);

% DDD
    clear II0 DD DD0;
    nv = conf.nv;
    nz1 = pp.zz(2)-pp.zz(1)+1;
    K = ones(nz,nx,ny,'single');
    K = funRemove(K,pp.izc,pp.ax,pp.ay,waitbar(0,'Preparing a mask ...'));
    K = K(pp.zz(1):pp.zz(2),:,:);
    
    RR = complex(zeros(nz1,nx*apx,ny,bpy,'single'));
    II = zeros(nz1,nx,ny,'single');
    DDD = zeros(nz1,nx,ny,nv,'single');
    DD2 = zeros(nz1,nx,ny,'single');  % without the tilted cropping plane
    
    for iv=1:nv
        if iv == 1  % already have FRG
            for iy=1:ny
                for ib=1:bpy
                    rr = FRGtoRR(FRG(:,:,iy,ib),pp.dk);
                    RR(:,:,iy,ib) = rr(pp.zz(1):pp.zz(2),:);
                end
                if mod(iy,500) == 0
                    disp([datestr(now,'HH:MM') ' reconstructing... ' num2str(iv) '/' num2str(nv) ' ' num2str(iy) '/' num2str(ny)]);
                end
            end
        else
            for iy=1:ny
                for ib=1:bpy
                    fpath = [pathraw '/' did '_b' NumToStr((iy-1)*bpy+ib,5) 'v' NumToStr(iv,3) 'x' NumToStr(IX,3) 'y' NumToStr(IY,3) 'z' NumToStr(IZ,3) '.lld'];
                    FRG = ReadLLD_16ThorlabsSD(fpath,conf);
                    rr = FRGtoRR(FRG,pp.dk);
                    RR(:,:,iy,ib) = rr(pp.zz(1):pp.zz(2),:);
                end
                if mod(iy,500) == 0
                    disp([datestr(now,'HH:MM') ' reconstructing... ' num2str(iv) '/' num2str(nv) ' ' num2str(iy) '/' num2str(ny)]);
                end
            end
        end
        
        % remove glasses :: this will make RR have zeros, causing an error in CorrPhase.
%         RR = funRemove(RR,pp.izc,pp.ax,pp.ay,waitbar(0,'Removing artifacts ...'));
        
        % motion correction
        parfor iy=1:ny
            RR(:,:,iy,:) = CorrPhase(RR(:,:,iy,:),1,3,1:nz1,K(:,:,iy));
            if mod(iy,500) == 0
                disp([datestr(now,'HH:MM') ' motion correction... ' num2str(iv) '/' num2str(nv) ' ' num2str(iy) '/' num2str(ny)]);
            end
        end	
        
        II1 = mean(abs(RR).^2,4);
        II = II + funRemove(II1,pp.izc-pp.zz(1)+1,pp.ax,pp.ay,waitbar(0,'Removing artifacts from the intensity image ...'));
        DD1 = mean(abs(diff(RR,1,4)).^2,4);
        DDD(:,:,:,iv) = funRemove(DD1,pp.izc-pp.zz(1)+1,pp.ax,pp.ay,waitbar(0,'Removing artifacts from the intensity image ...'));
        DD2 = DD2 + DD1;
        
    end
    DD2 = DD2/nv;
    clear FRG RR II1 DD1 K rr;
    
% sort B scans by contrast (high to low)
    if pp.nvexc > 0
%         DD = AverageWithContrastMaskAuto(DDD,pp.nvexc,bFig);
        D = squeeze(max(DDD,[],1));  % MIP [nx ny nv]
        C = squeeze(std(D,1,1) ./ mean(D,1));  % [ny nv]
        [minC,ivC] = min(C,[],2);
                if bFig
                    figure(1);  clf;
                    subplot(411);  cla;  plot(C);  ylim([0 2]);  xlabel('Y');  title('Contrast over different volumes');
                    subplot(412);  cla;  plot(minC);  ylim([0 2]);  xlabel('Y');  title('Min contrast');
                    subplot(413);  cla;  plot(ivC);  ylim([0 nv+1]);  xlabel('Y');  title('Volume # with min contrast');
                    subplot(414);  cla;  histogram(ivC);  xlabel('Volume #');  title('Histogram');
                end
        for iy=1:ny
            [~,is] = sort(C(iy,:),'descend');
            DDD(:,:,iy,:) = DDD(:,:,iy,is);
        end
    end

% median filtering, averaging, gaussian filtering

    if sum(pp.medfsize) > 0
        for iv=1:nv
            tic;
            DDD(:,:,:,iv) = MedFilt3D(DDD(:,:,:,iv),pp.medfsize,true);
            disp([datestr(now,'HH:MM') '  Median filtering ... ' num2str(iv) '/' num2str(nv)]);
        end
        DD2 = MedFilt3D(DD2,pp.medfsize,true);
    end
    
    DD = mean(DDD(:,:,:,1:nv-pp.nvexc),4);
    if pp.nvexc > 0
        DD0 = mean(DDD,4);  % for comparison
    end
    clear DDD;
    
    if sum(pp.gaufsize) > 0
        DD = convn(DD,GaussKernel(pp.gaufsize),'same');
        if pp.nvexc > 0
            DD0 = convn(DD0,GaussKernel(pp.gaufsize),'same');
        end
        DD2 = convn(DD2,GaussKernel(pp.gaufsize),'same');
    end
        
% figure
    
    figure('position',[1 1 10 10/3]*85);  colormap(gray);
    subplot(141);  cla;  hold on;  PlotImage(squeeze(log10(max(DD2,[],1)))',false,[.1 .95],true);  title('Decorrelation: Old cropping');
    if pp.nvexc > 0
        subplot(142);  cla;  hold on;  PlotImage(squeeze(log10(max(DD0,[],1)))',false,[.1 .95],true);  title('Decorrelation: Normal averaging');
        subplot(143);  cla;  hold on;  PlotImage(squeeze(log10(max(DD,[],1)))',false,[.1 .95],true);  title('Decorrelation: Contrast-masked averaging');
    else
        subplot(142);  cla;  hold on;  PlotImage(squeeze(log10(max(DD,[],1)))',false,[.1 .95],true);  title('Decorrelation: Normal averaging');
    end
    subplot(144);  cla;  hold on;  PlotImage(squeeze(log10(max(II,[],1)))',false,[.1 .95],true);  title('Intensity image');
	
clear DD2 DD0;

disp('SECTION 15 COMPLETED.');
