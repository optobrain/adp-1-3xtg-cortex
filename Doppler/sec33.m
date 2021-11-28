% disp('SECTION 33 RUNNING ...');
% SetParPool(6);

%% V

if ~exist('rxx','var') % || ~exist('izf','var')
    [nz,nx,ny] = size(cVV{1});
    rxx = (1+ne:nx-ne);  ryy = (1+ne:ny-ne);  
%     izf = izv;
end


%% ROI

cmap = GetColorMap('doppler');

cmap = zeros(64,3);
nVen = 32-round(32*abs(vVen/limV(1)));  nArt = 32-round(32*abs(vArt/limV(2)));
cmap(1:nVen,3) = 1;  cmap((64-nArt+1):64,1) = 1;
sflow = {'Both' 'Arterioles only' 'Venules only'};  clrf = {'k' 'r' 'b'};

figure(1);  clf;  colormap(cmap);  
for id=1:nd
    subplot(3,3,id);  hold on;
        PlotImage(squeeze(mean(cVV{id}(ciz(id)+(-zavg:zavg),:,:),1))',true,limV);  colorbar;
%         title(num2str(id));
        if id == 1
            title('Adjust ROI here.'); 
            roi = images.roi.Rectangle(gca,'color','w','position',[rxx(1),ryy(1),numel(rxx),numel(ryy)]);
            addlistener(roi,'ROIMoved',@funROIcallback);
        else
            PlotBox(rxx,ryy,'w',2);
        end
end

% disp('SECTION 33 COMPLETED.');


%% functions

function funROIcallback(src,evt)  % no output
    evname = evt.EventName;
    switch(evname)
        case{'ROIMoved'}
            cp = evt.CurrentPosition;
            rxx = cp(1)+(1:cp(3));
            ryy = cp(2)+(1:cp(4));
            xlabel([mat2str(round(cp)) newline 'ROI size = ' mat2str([numel(rxx) numel(ryy)])]);            
    end     
end
