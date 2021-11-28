disp('SECTION 22 RUNNING ...');

if ~(exist('ap','var') && isfield(ap,'fp'))
    ap.fp = zeros(2,2,nd);  %% [x,y; translation,rotation; nd]
end
figure(1);  clf;  colormap(gray);
for id=1:nd
    for id1=1:nd
        if id1 <= 2
            jj = 2+id1;
        else
            jj = 4+id1;
        end
        subplot(4,4,jj);  cla;  hold on;
            PlotImage(log10(D(:,:,id1))',false,[.1 .95],true);  title(cpid{id1});
            line(ap.fp(1,1,id1),ap.fp(2,1,id1),'marker','s','color','b');
            line(ap.fp(1,2,id1),ap.fp(2,2,id1),'marker','o','color','r');
    end
    
    subplot(4,4,[1 2 5 6]);  cla;  hold on; 
        PlotImage(log10(D(:,:,id))',false,[.1 .95],true);  title(cpid{id});
        line(ap.fp(1,1,id),ap.fp(2,1,id),'marker','s','color','b');
        line(ap.fp(1,2,id),ap.fp(2,2,id),'marker','o','color','r');
        xlabel('Select two feature points (e.g., clear branches).');
    ap.fp(:,:,id) = ginput(2)';
end

figure('position',[.1 .1 4/4 2/4]*640);  colormap(gray);
for id=1:nd
    subplot(2,5,id);  hold on;  
        PlotImage(log10(D(:,:,id))',false,limD,false);  
        line(ap.fp(1,1,id),ap.fp(2,1,id),'marker','s','color','b');
        line(ap.fp(1,2,id),ap.fp(2,2,id),'marker','o','color','r');
end

disp('SECTION 22 COMPLETED.');