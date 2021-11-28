disp('SECTION 13 RUNNING ...');
SetParPool(4);

% I
    frg = FRG(:,:,iydk);
    I = zeros(nz/2,nx,length(dkr));  
    
    wb = waitbar(0,'Reconstructing with different dk ...');
    for ik=1:length(dkr)
        RR1 = FRGtoRR(frg,dkr(ik));
        if apx > 1
            RR1 = reshape(RR1,[nz apx nx]);
            I(:,:,ik) = squeeze(mean(abs(RR1(1:nz/2,:,:)).^2,2));
        else
            I(:,:,ik) = abs(RR1(1:nz/2,:)).^2;
        end

        iy = ny/2;
        for ix=1:nx
            iza = pp.ax*(ix-nx/2) + pp.ay*(iy-ny/2) + pp.izc;
            iza = max(round(iza),1);
            I(1:iza,ix,ik) = 0;
        end
        waitbar(ik/length(dkr),wb);
    end
    close(wb);

% shp
    shp = zeros(1,length(dkr));
    parfor ik=1:length(dkr)
        shp(ik) = GetSharpness(I(:,:,ik));
    end
    
    figure('position',[1 1 10 10/2.5]*85);  colormap(gray);
        for ik=1:min(length(dkr),9)
            subplot(2,5,ik);
                PlotImage(I(:,:,ik),false,[.1 .95],true,[2 1 1]);
                title([num2str(dkr(ik)) ' (' num2str(shp(ik)) ')']);								
        end
        subplot(2,5,10);  plot(dkr,shp,'Marker','.');  axis tight;  grid on;  xlabel('dk');  ylabel('Sharpness');
        
% dk
    [~,ik] = max(shp);
    pp.dk = dkr(ik)

disp('SECTION 13 COMPLETED.');