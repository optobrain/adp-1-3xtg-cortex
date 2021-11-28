disp('SECTION 21a RUNNING ...');

%% ap.nz1

if exist('ap','var') && isfield(ap,'nz1')
    nz1 = ap.nz1;
else
    Dz = mean(DD(:,:),2);
    if DR > 0
        thrD = max(Dz)/DR;
        idx = sign(Dz-thrD);  idx = find(diff(idx)==-2);  
        if ~isempty(idx)
            nz1 = idx(1);
        else
            nz1 = nz;
        end
    else
        [~,nz1] = max(Dz);
    end
end


%% UI

figure(1);  clf;  colormap(gray);
while true
    sec21a_plot;

    if waitforbuttonpress
        cc = get(gcf,'CurrentCharacter');
        if strcmp(cc,'q')        
            break;
        elseif strcmp(cc,'g')
            gi = ginput(1);
            nz1 = min(round(gi(1)),nz);
        elseif strcmp(cc,'s')
            nz1 = max(nz1-dnz1,1);
        elseif strcmp(cc,'f')
            nz1 = min(nz1+dnz1,nz);
        end
    end
end 
ap.nz1 = nz1;


%% fig

figure('position',[.1 .1 2/4 2/4]*640);  colormap(gray);  
sec21a_plot;
savefig(gcf,[pathrepo '21a.fig']);
saveas(gcf,[pathrepo '21a.png']);
    
disp('SECTION 21a COMPLETED.');