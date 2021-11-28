disp('SECTION 11 RUNNING ...');
SetParPool(4,120);  % 6 uses 60 GB in FRGtoRR when using RR1 = FRGtoRR(FRG,0.24) after the for loop

% RR
    nk = 2048;  nz = nk/2;  nx = conf.nx;  apx = conf.apx;  ny = conf.ny;  bpy = conf.bpy;  iv = 1;
    FRG = zeros(nk,nx*apx,ny,bpy,'single');
    RR = complex(zeros(nz,nx*apx,ny,bpy,'single'));
    for iy=1:ny
        for ib=1:bpy
            fpath = [pathTemp did '_b' NumToStr((iy-1)*bpy+ib,5) 'v' NumToStr(iv,3) 'x' NumToStr(IX,3) 'y' NumToStr(IY,3) 'z' NumToStr(IZ,3) '.lld'];
            FRG(:,:,iy,ib) = ReadLLD_16ThorlabsSD(fpath,conf);
            RR(:,:,iy,ib) = FRGtoRR(FRG(:,:,iy,ib),0.24);
        end
        if mod(iy,200) == 0
            disp([datestr(now,'HH:MM') ' loaded ' num2str(iy) '/' num2str(ny)]);
        end
    end

% motion correction
    parfor iy=1:ny
        RR(:,:,iy,:) = CorrPhase(RR(:,:,iy,:),1,3);
        if mod(iy,200) == 0
            disp([datestr(now,'HH:MM') ' motion correction... ' num2str(iy) '/' num2str(ny)]);
        end
    end	
    
% II0 & DD0
    II0 = mean(abs(RR).^2,4);
    DD0 = mean(abs(diff(RR,1,4)).^2,4);  
    if apx > 1
        II0 = reshape(mean(reshape(II0,[nz apx nx ny]),2),[nz nx ny]);
        DD0 = reshape(mean(reshape(DD0,[nz apx nx ny]),2),[nz nx ny]);
    end
    
figure('position',[1 1 10 10/1.5]*85);  colormap(gray);
%     subplot(231);  cla;  PlotImage(log10(mean(II0,3)),false,[.1 .99],true);  xlabel('X');  ylabel('Z');  title('Mean intensity');
%     subplot(232);  cla;  PlotImage(log10(squeeze(mean(II0,2))),false,[.1 .99],true);  xlabel('Y');  ylabel('Z');  title('Mean intensity');
%     subplot(233);  cla;  hold on;  PlotImage(log10(squeeze(mean(II0,1)))',false,[.1 .95],true);  xlabel('X');  ylabel('Y');   title('Mean intensity');
    subplot(231);  cla;  PlotImage(log10(II0(:,:,end/2)),false,[.1 .99],true);  xlabel('X');  ylabel('Z');  title('Intensity: Center slice');
    subplot(232);  cla;  PlotImage(log10(squeeze(II0(:,end/2,:))),false,[.1 .99],true);  xlabel('Y');  ylabel('Z');  title('Center slice');
    subplot(233);  cla;  hold on;  PlotImage(log10(squeeze(max(II0,[],1)))',false,[.1 .95],true);  xlabel('X');  ylabel('Y');   title('MIP');
    subplot(234);  cla;  PlotImage(log10(DD0(:,:,end/2)),false,[.1 .99],true);  xlabel('X');  ylabel('Z');  title('Decorrelation: Center slice');
    subplot(235);  cla;  PlotImage(log10(squeeze(DD0(:,end/2,:))),false,[.1 .99],true);  xlabel('Y');  ylabel('Z');  title('Center slice');
    subplot(236);  cla;  hold on;  PlotImage(log10(squeeze(max(DD0,[],1)))',false,[.1 .95],true);  xlabel('X');  ylabel('Y');   title('MIP');

clear RR;

disp('SECTION 11 COMPLETED.');