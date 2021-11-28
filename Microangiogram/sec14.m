disp('SECTION 14 RUNNING ...');
% SetParPool(6);

% remove artifact, DD1 (normalized)
    DD = funRemove(DD0,pp.izc,pp.ax,pp.ay,waitbar(0,'Removing artifacts ...'));
    Dz = mean(DD(:,:),2);
        
% pp.zz
    if ~isfield(pp,'zz')
        pp.zz = zeros(1,2);
        idx = find(Dz==0);  pp.zz(1) = max(idx);
        thrD = max(Dz)/DR;
        idx = sign(Dz-thrD);  idx = find(diff(idx)==-2);  
        if length(idx) >= 1
            pp.zz(2) = idx(1);
        else
            pp.zz(2) = size(DD,1);
        end
    end
    
% UI
    figure(1);  clf;  colormap(gray);  pause(.1);
    while true
        
        sec14_plot;
    
        if waitforbuttonpress
            cc = get(gcf,'CurrentCharacter');
            if strcmp(cc,'q')        
                break;
            elseif strcmp(cc,'g')
                gi = ginput(1);
                pp.zz(2) = max(round(gi(1)),pp.zz(1)+1);
            elseif strcmp(cc,'s')
                pp.zz(2) = max(pp.zz(2)-dz,pp.zz(1)+1);
            elseif strcmp(cc,'f')
                pp.zz(2) = pp.zz(2)+dz;
            end
        end

    end 

    figure('position',[1 1 10 10]*85);  colormap(gray);
    sec14_plot;
    
disp('SECTION 14 COMPLETED.');