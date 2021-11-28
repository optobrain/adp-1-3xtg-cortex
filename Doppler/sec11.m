disp('SECTION 11 RUNNING ...');
SetParPool(4);  % 6 uses 60 GB in FRGtoRR when using RR1 = FRGtoRR(FRG,0.24) after the for loop

% constants for velocity calculation
    dt = 1/146e3;  % 1/(A-scan rate)
    lam0 = 1310e-9;  % center wavelength [nm]
    n = 1.35;  % refractive index
    q = 2*n*(2*pi/lam0);  % phase = q * Vz * t    

% FRG RR VV
    nk = 2048;  nz = diff(pp.zz)+1;  nx = conf.nx;  apx = conf.apx;  ny = conf.ny;  bpy = conf.bpy;  nv = conf.nv;
    RR = complex(zeros(nz,nx,ny*bpy,apx,'single'));
    VV = zeros(nz,nx,ny,'single');  II = VV;
    for iv=1:nv
        for iy=1:ny*bpy
            fpath = [pathraw '/' did '_b' NumToStr(iy,5) 'v' NumToStr(iv,3) 'x' NumToStr(IX,3) 'y' NumToStr(IY,3) 'z' NumToStr(IZ,3) '.lld'];
            RR1 = FRGtoRR(ReadLLD_16ThorlabsSD(fpath,conf),pp.dk);
            for ia=1:apx
                RR(:,:,iy,ia) = RR1(pp.zz(1):pp.zz(2),ia:apx:end);
            end
            if mod(iy,200) == 0
                disp([datestr(now,'HH:MM') ' loaded. ' num2str(iv) '/' num2str(nv) ' ' num2str(iy) '/' num2str(ny)]);
            end
        end
        I = mean(abs(RR).^2,4);
        
        % remove COR in the OCT signal
        if pp.oCOR == 1
            RR = RR - repmat(FindCOR(RR),[1 1 1 size(RR,4)]);
        end

        % autocorrelation
        if pp.rmaxlag == 0 % Kasai
            maxlag = 1;
        else
            maxlag = round(pp.rmaxlag*apx);
        end
        RR = GetAcr(RR,maxlag);

        % remove COR in the autocorrelation
        if pp.rmaxlag > 0
            if pp.oCOR == 2
                RR = RR - repmat(FindCOR(RR),[1 1 1 size(RR,4)]);
            elseif pp.oCOR == 3
                RR = RR - repmat(min(max(real(FindCOR(RR)),0),0.9),[1 1 1 size(RR,4)]);
            end
        end

        % phase unwrap
        tic;
        RR = angle(RR);
        if pp.rmaxlag > 0
            parfor iz=1:nz
                RR(iz,:,:,:) = unwrap(RR(iz,:,:,:),[],4);
            end
            disp([datestr(now,'HH:MM') '  Unwrap completed (' num2str(toc/60,2) ' min)']);
        end

        % slope & velocity
        if pp.rmaxlag == 0  % Kasai
            V = RR(:,:,:,2);
        else
            [V,~,~] = FitPolyn1(RR,1:maxlag+1,4,true);
        end
        V = V/q/dt * 1e3;  % mm/s

        % median filtering & average over bpy
        tic;
        if sum(pp.medfsize) > 0
            V = MedFilt3D(V,pp.medfsize,true);
            I = MedFilt3D(I,pp.medfsize,true);
        end
        if bpy > 1
            V = squeeze(mean( reshape(V,[nz nx bpy ny]) ,3));
            I = squeeze(mean( reshape(I,[nz nx bpy ny]) ,3));
        end      
        disp([datestr(now,'HH:MM') '  Median filtering completed (' num2str(toc/60,2) ' min)']);

                figure('position',[1 1 10 10/2.5]*85);  colormap(jet);
                for ii=1:3
                    iz = round(0.2*(ii+1)*nz);
                    subplot(2,4,ii);  cla;  hold on;  PlotImage(squeeze(V(iz,:,:))',false,[.1 .9],true);  set(gca,'CLim',[-1 1]*max(abs(get(gca,'CLim'))));  colorbar;  title(['iz=' num2str(iz)]);
                    if (ii == 1),  ylabel(['iv=' num2str(iv) ' Shift uncorrected']);  end
                end
                subplot(2,4,4);  cla;  hist(V(:),100);  xlabel('Velocity [mm/s]');  title('Histogram');

        % correct global shift (very simple here; we could improve this by obtaining Vm only for non-vessel voxels using angiogram data
        if pp.oShift > 0
            if pp.oShift == 1
                Vm = median(V(:));
                subplot(2,4,8);  cla;  ax = plotyy(1:nz,mean(I(:,:),2),1:nz,median(V(:,:),2));  xlabel('Z');  ylabel(ax(1),'Intensity');  set(ax(1),'yscale','log');  ylabel(ax(2),'Median velocity [mm/s]');  title(['Median = ' num2str(Vm,3) ' mm/s']);
            else
                Vm = mean(V(:));
                subplot(2,4,8);  cla;  ax = plotyy(1:nz,mean(I(:,:),2),1:nz,mean(V(:,:),2));  xlabel('Z');  ylabel(ax(1),'Intensity');  set(ax(1),'yscale','log');  ylabel(ax(2),'Mean velocity [mm/s]');  title(['Mean = ' num2str(Vm,3) ' mm/s']);
            end
            V = V - Vm;
                for ii=1:3
                    iz = round(0.2*(ii+1)*nz);
                    subplot(2,4,4+ii);  cla;  hold on;  PlotImage(squeeze(V(iz,:,:))',false,[.1 .9],true);  set(gca,'CLim',[-1 1]*max(abs(get(gca,'CLim'))));  colorbar;  
                    if (ii == 1),  ylabel('Shift corrected');  end
                end
        end    
        pause(.1);

        VV = VV + V;
        II = II + I;
        disp([datestr(now,'HH:MM') '  Done ' num2str(iv) '/' num2str(nv) ' meanI=' num2str(mean(I(:)))]);
        
    end
    
    VV = VV/nv;
    II = II/nv;
    if sum(pp.gaufsize) > 0
        VV = convn(VV,GaussKernel(pp.gaufsize),'same');
        II = convn(II,GaussKernel(pp.gaufsize),'same');
    end

clear RR V I;
    
disp('SECTION 11 COMPLETED.');