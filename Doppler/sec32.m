disp('SECTION 32 RUNNING ...');
% SetParPool(6);

%% V

if ~exist('V','var')
    V = cell(nv,nd);  % V.r = [z x y]'; V.d [px]  V.f (over x=-2d:2d);  V.Vx = zeros(ne*2+1,1);  V.Vxfit = Vx;  V.R2 = 0;  
    Vf = zeros(nv,nd);  Vd = Vf;  VR2 = Vf;
%     izv = ciz;  % removed this, so the user cannot change the depth between vessels
end


%% UI
% V.r = [z x y]'; V.d [px]  V.f (over x=-2d:2d);  V.img = zeros(ne*2+1,ne*2+1);  V.imgfit = V.img;  V.Vx = zeros(ne*2+1,1);  V.Vxfit = Vx;  V.R2 = 0;  

ne = round(nxwin/2);
cmap = GetColorMap('doppler_white');
clr = lines(nv);
id = 1;  iv = 1;
[gy,gx] = meshgrid(-ne:ne,-ne:ne);
while true
    figure(1);  clf;  colormap(cmap);  
    VV = cVV{id};  [nz,nx,ny] = size(VV);  xx = (1+ne:nx-ne);  yy = (1+ne:ny-ne);  
%     iz = izv(id);
    iz = ciz(id);  
    da = cda(id);
    v = V{iv,id};
    subplot(5,5,[1 2 6 7]);  cla;  hold on;
        PlotImage(squeeze(mean(VV(iz+(-zavg:zavg),:,:),1))',false,limV2);  PlotBox(xx,yy,'k',2);  
%         title(['id=' num2str(id) '/' num2str(nd) '  iz=' num2str(iz) '/' num2str(nz)]);
        title(['id=' num2str(id) '/' num2str(nd)]);
        for iv1=1:nv
            v1 = V{iv1,id};
            lw = 1;  if iv1 == iv,  lw = 2;  end
            if ~isempty(v1)
                PlotCircle(v1.r(2:3),v1.d,clr(iv1,:),lw);  
            end
        end
    subplot(5,5,3);  cla;  hold on;
        if ~isempty(v)
            img = squeeze(mean(VV(v.r(1)+(-zavg:zavg),v.r(2)+(-ne:ne),v.r(3)+(-ne:ne)),1));
            PlotImage(img',false,limV2);
            PlotCircle([1 1]*ne+1,v.d,clr(iv,:),2);  PlotBox(1:(ne*2+1),1:(ne*2+1),clr(iv,:));
%             f = sum(sum(img((gy.^2+gx.^2<=v.d^2))))*60*cda(id)*1e-6;  % mm^3/min = uL/min 
%             title(['Current: V' num2str(iv) ' f=' num2str(f,2) ' z=' num2str(v.r(1))]);            
%             img = squeeze(mean(VV(iz+(-zavg:zavg),v.r(2)+(-ne:ne),v.r(3)+(-ne:ne)),1));
%             f = sum(sum(img((gy.^2+gx.^2<=v.d^2))))*60*cda(id)*1e-6;  % mm^3/min = uL/min 
%             xlabel(['f=' num2str(f,2) ' at z=' num2str(iz)]);
            title(['Current vessel: V' num2str(iv) newline '(R^2=' num2str(v.R2,2) ')']);            
        else
            title(['Current vessel: none']);
        end

    for iv1=1:nv
        v1 = V{iv1,id};
        if ~isempty(v1)
            lw = 1;  if iv1 == iv,  lw = 1;  end
            ii = 5+iv1;
            if iv1 <= 2,  ii = 3+iv1;  end
            subplot(5,5,ii);  cla;  
                line(-ne:ne,v1.Vx,'color',clr(iv1,:),'marker','.','linestyle','none','linewidth',lw);  
                line(-ne:ne,v1.Vxfit,'color',clr(iv1,:),'linewidth',lw);  ylim(limV2);
%                     title(['V1: ' mat2str([v1.d v1.R2 v1.a*180/pi],2)]);
%                 title(['V' num2str(iv1) ': f=' num2str(v1.f,2) newline ' iz=' num2str(v1.r(1)) ' R^2=' num2str(v1.R2,2)]);
                title(['V' num2str(iv1) ' (R^2=' num2str(v1.R2,2) ')']);
        end
%         for id1=1:nd
%             v1 = V{iv1,id1};
%             if ~isempty(v1)
%                 Vf(iv1,id1) = v1.f;  Vd(iv1,id1) = v1.d;  VR2(iv1,id1) = v1.R2;
%             end
%         end
    end

    if waitforbuttonpress
        cc = get(gcf,'CurrentCharacter');
        if strcmp(cc,'q')
            break;
        elseif strcmp(cc,'g')
            subplot(5,5,[1 2 6 7]);
            r = round(ginput(1));
            if r(1) < xx(1)+2 || r(1) > xx(end)-2 || r(2) < yy(1)+2 || r(2) > yy(end)-2
                uiwait(msgbox('Select a point within the black box.','Warning','warn'));
            else
                wb = waitbar(0,'Analyzing the selected vessel ...');
                % fit the ROI to 2D Gaussian
                vzz = iz+(-zavg:zavg);  vxx = r(1)+(-ne:ne);  vyy = r(2)+(-ne:ne);
                img = double(squeeze(mean(VV(vzz,vxx,vyy),1)));
                fitC0 = [img(ne+1,ne+1) 0 0 ne/SigToFWHM(1) 0];  
                [a1,b1,c1,d1,e1,R21,zfit1] = FitGaussian2D(gx, gy, img, fitC0, bEzero);
                if SigToFWHM(d1) > 2*ne || abs(b1) > ne || abs(c1) > ne || R21 < 0.1
                    uiwait(msgbox('Vessel identification failed. Select a different point.','Warning','warn'));
                else
                    % update r to the center of the Gaussian, and the ROI as well
                    r = r + round([b1 c1]);  v.r = [iz r]';  v.d = SigToFWHM(d1);  v.R2 = R21;
                    vzz = iz+(-zavg:zavg);  vxx = r(1)+(-ne:ne);  vyy = r(2)+(-ne:ne);
                    v.img = squeeze(mean(VV(vzz,vxx,vyy),1));  
                    v.imgfit = a1*exp(-(gx.^2+gy.^2)/2/d1^2)+e1;
                    v.f = sum(sum(v.img((gy.^2+gx.^2<=v.d^2))))*60*cda(id)*1e-6;  % mm^3/min = uL/min 
                    % plot the image
%                     subplot(5,5,3);  cla;  hold on;  PlotImage(v.img',false,limV2);  PlotCircle([1 1]*ne+1,v.d,clr(iv,:),2);
                    % 1D Gaussian (optional)
                    Vx = zeros(ne*2+1,3*2);  Vx(:,1:3) = v.img(ne+(0:2),:)';  Vx(:,4:6) = v.img(:,ne+(0:2));  Vx = mean(Vx,2);
                    fitC0 = [a1 0 d1];  fitCmin = [-40 -ne/2 1];  fitCmax = [40 ne/2 ne/2];
                    [a1,b1,c1,d1,R21,yfit1] = FitGaussian(-ne:ne, Vx, fitC0, fitCmin, fitCmax, true);
                    v.Vx = Vx;  v.Vxfit = yfit1;
                    V{iv,id} = v;
                    
                    Vf(iv,id) = v.f;  Vd(iv,id) = v.d*sqrt(cda(id));  VR2(iv,id) = v.R2;
                    close(wb);
                end
            end
        elseif strcmp(cc,'f')
            id = min(id+1,nd);
        elseif strcmp(cc,'s')
            id = max(id-1,1);
        elseif strcmp(cc,'d')
            iv = max(iv-1,1);
        elseif strcmp(cc,'e')
            iv = min(iv+1,nv);
%         elseif strcmp(cc,'e')
%             izv(id) = max(izv(id)-dz,1+zavg);
%         elseif strcmp(cc,'d')
%             izv(id) = min(izv(id)+dz,nz-zavg);
        end
    end
end


%% fig

nv1 = 1;
for id=1:nd
    for iv=1:nv
        if ~isempty(V{iv,id})
            nv1 = max(nv1,iv);
        end
    end
end

figure('position',[.1 .1 4/4 2/4]*640);  colormap(GetColorMap('doppler'));
for id=1:nd
    subplot(2,5,id);  hold on;  
        PlotImage(squeeze(mean(cVV{id}(ciz(id)+(-zavg:zavg),:,:),1))',false,limV);  
        title(num2str(id));
        for iv1=1:nv1
            v1 = V{iv1,id};
            if ~isempty(v1)
                PlotCircle(v1.r(2:3),v1.d,clr(iv1,:),1);  
            end
        end    
end
subplot(2,5,nd+1);  
    for iv1=1:nv1
        line(1:nd,abs(Vf(iv1,:)),'color',clr(iv1,:));
    end
    xlim([0 nd+1]);  title(['Flow (uL/min) (n=' num2str(nv1) ')']);
subplot(2,5,nd+2);  
    for iv1=1:nv1
        line(1:nd,Vd(iv1,:),'color',clr(iv1,:));
    end
    xlim([0 nd+1]);  title(['Diameter (um)']);
sgtitle([ 'Tracked blood flow. color = ' mat2str(limV) ' mm/s' ]);
savefig(gcf,[pathrepo ' #32.fig']); 
saveas(gcf,[pathrepo ' #32.png']);


disp('SECTION 32 COMPLETED.');