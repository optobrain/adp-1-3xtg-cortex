disp('SECTION 32 RUNNING ...');
SetParPool(8);

%% V

nv = 19;
if ~exist('V','var')
    V = cell(nv,nd);  % V.r = [x y]'; V.a  V.d [px]  V.Ix = zeros(nxwin*2+1,1);  V.Ixfit = Ix;  V.R2 = 0;
    Vd = zeros(nv,nd);  VR2 = zeros(nv,nd);
end


%% UI

clr = lines(nv);
xx = (1+nxwin:nx-nxwin);  yy = (1+nxwin:ny-nxwin);

id = 1;  iv = 1;
while true
    figure(1);  clf;  colormap(gray);  
    v = V{iv,id};

    %     subplot(5,5,[1 2 6 7]);  cla;  hold on;
    subplot(6,6,[(1:4) ((1:4)+6) ((1:4)+12) ((1:4)+18)]);  cla;  hold on;
        sec32_plot1;
    
%     subplot(5,5,3);  cla;  hold on;
    subplot(6,6,5);  cla;  hold on;
        if ~isempty(v)
            PlotImage(D(v.r(1)+(-nxwin:nxwin),v.r(2)+(-nxwin:nxwin),id)',false,[.1 .9],true);
            line(nxwin+1+[-1 1]*nxwin*cos(v.a),nxwin+1+[-1 1]*nxwin*sin(-v.a),'color',clr(iv,:),'linewidth',2);
            PlotBox(1:(nxwin*2+1),1:(nxwin*2+1),clr(iv,:));
        end
        title(['Current: V' num2str(iv)]);            

    sec32_plot2;

    if waitforbuttonpress
        cc = get(gcf,'CurrentCharacter');
        if strcmp(cc,'q')
            break;
        elseif strcmp(cc,'g')
%             subplot(5,5,[1 2 6 7]);
            subplot(6,6,[(1:4) ((1:4)+6) ((1:4)+12) ((1:4)+18)]);
            r = round(ginput(1));
            if r(1) < xx(1) || r(1) > xx(end) || r(2) < yy(1) || r(2) > yy(end)
                uiwait(msgbox('Select a point within the black box.','Warning','warn'));
            else
                v.r = r';  
                vxx = v.r(1)+(-nxwin:nxwin);  vyy = v.r(2)+(-nxwin:nxwin);
                img0 = D(vxx,vyy,id);
                a = linspace(0,pi,na);  vd = zeros(na,1);  R2 = zeros(na,1);  
                if bDzero
                    fitC0 = [1 0 nxwin/4];  fitCmin = [0 -nxwin/2 1];  fitCmax = [10 nxwin/2 nxwin/SigToFWHM(1)];
                else
                    fitC0 = [1 0 nxwin/4 0];  fitCmin = [0 -nxwin/2 1 0];  fitCmax = [10 nxwin/2 nxwin/SigToFWHM(1) 1];
                end
                wb = waitbar(0,'Analyzing the selected vessel ...');
                parfor ia=1:na
                    img = RotateImage(img0,a(ia),[1 1]*(nxwin+1));  img(isnan(img)) = 0;
                    Ix = mean(img(:,nxwin+1+(-navg:navg)),2);  
%                         [~,~,c,~,R2,Ixfit] = FitGaussian(1:length(Ix),Ix/max(Ix),[1 nxwin+1 nxwin/4],[],[],true);
%                         Ixfit = Ixfit * max(Ix);
                    [a1,b1,c1,d1,R21,~] = FitGaussian(-nxwin/2:nxwin/2,Ix(nxwin/2+(1:nxwin+1))/max(Ix),fitC0,fitCmin,fitCmax,bDzero);
%                     Ixfit = (a1*exp(-((-nxwin:nxwin)-b1).^2/2/c1^2)+d1)*max(Ix);
                    vd(ia) = SigToFWHM(c1);  R2(ia) = R21;
%                         subplot(5,5,3);  cla;  hold on;
%                             PlotImage(img',false,[.1 .9],true);
%                         subplot(5,5,8);  cla;
%                             line(1:length(Ix),Ix,'color','k','marker','o','linestyle','none');
%                             line(1:length(Ix),Ixfit,'color','k');
%                         pause(.1);
                end
                [m,im] = min(vd);   
                img = RotateImage(img0,a(im),[1 1]*(nxwin+1));  img(isnan(img)) = 0;
                Ix = mean(img(:,nxwin+1+(-navg:navg)),2);  
                [a1,b1,c1,d1,R21,~] = FitGaussian(-nxwin/2:nxwin/2,Ix(nxwin/2+(1:nxwin+1))/max(Ix),fitC0,fitCmin,fitCmax,bDzero);
                Ixfit = (a1*exp(-((-nxwin:nxwin)-b1).^2/2/c1^2)+d1)*max(Ix);
                v.a = a(im);  v.d = SigToFWHM(c1);  v.Ix =  Ix;  v.Ixfit = Ixfit;  v.R2 = R21;
%                 subplot(5,5,8);  cla;  
                subplot(6,6,6);  cla;  
%                 ax = plotyy(a,vd,a,R2);  line(a(im),v.d,'marker','o');  
                yyaxis left;  line(a,vd);  line(a(im),v.d,'marker','o');  ylabel('diameter');
                yyaxis right;  line(a,R2);  ylabel('R^2');
                xlabel('angle');  % ylabel('diameter');  ylabel(ax(2),'R^2');
                V{iv,id} = v;
                Vd(iv,id) = v.d;  VR2(iv,id) = v.R2;
                close(wb);
                pause(1);
            end
        elseif strcmp(cc,'f')
            id = min(id+1,nd);
        elseif strcmp(cc,'s')
            id = max(id-1,1);
        elseif strcmp(cc,'e')
            iv = max(iv-1,1);
        elseif strcmp(cc,'d')
            iv = min(iv+1,nv);
        end
    end
end


%% fig

figure('position',[.1 .1 4/4 1/4*ceil(nd/4)]*640);  colormap(gray);
for id=1:nd
    subplot(ceil(nd/4),4,id);  hold on;
    PlotImage(log10(D(:,:,id))',false,log10(limD(:,id)));  % PlotBox(xx,yy,'w',2);  title([num2str(id) '/' num2str(nd)]);
    for iv1=1:nv
        v1 = V{iv1,id};
        if ~isempty(v1)
            line(v1.r(1)+[-1 1]*nxwin*cos(v1.a),v1.r(2)+[-1 1]*nxwin*sin(-v1.a),'color',clr(iv1,:));
        end
    end
end
savefig(gcf,[pathrepo ' # 32a.fig']); 
saveas(gcf,[pathrepo ' # 32a.png']);

ivv = [];  ii = 1;
for iv=1:nv
    if prod(Vd(iv,:)) > 0
        ivv(ii) = iv;
        ii = ii+1;
    end
end
figure('position',[.1 .1 2/4 1/4]*640);  
subplot(121);
    for iv1=ivv
        line(1:nd,Vd(iv1,:),'color',clr(iv1,:));
    end
    xlim([0 nd+1]);  set(gca,'xtick',1:nd);
    xlabel('Time points');  ylabel('Diameter (px)');  title('Traces');
subplot(122);
    for iv1=ivv
        line(1:nd,Vd(iv1,:),'color',[1 1 1]*.75);
    end
    x = (1:nd);  y = mean(Vd(ivv,:),1);  yd = SEtoCI(std(Vd(ivv,:),1),length(ivv),true);
    p = ones(1,nd);
    for id=1:nd
        [~,p(id)] = ttest(Vd(ivv,1),Vd(ivv,id));
    end
    errorbar(x,y,yd,'marker','o');
    MarkPvalue(gca,x,y,yd,p);
    xlim([0 nd+1]);  set(gca,'xtick',1:nd);
    xlabel('errorbar = 95% CI');
savefig(gcf,[pathrepo ' # 32b.fig']); 
saveas(gcf,[pathrepo ' # 32b.png']);

disp('SECTION 32 COMPLETED.');
    