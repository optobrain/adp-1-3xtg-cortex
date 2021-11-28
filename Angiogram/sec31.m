disp('SECTION 31 RUNNING ...');

[nx,ny,nd] = size(D);
limD = zeros(2,nd);
for id=1:nd
    limD(:,id) = [GetSorted(D(:,:,id),limC(1)) GetSorted(D(:,:,id),limC(2))]';
end

id = 1;
while true
    figure(1);  clf;  colormap(gray);  hold on;
    PlotImage(log10(D(:,:,id))',false,log10(limD(:,id)));  colorbar;
    title([num2str(id) '/' num2str(nd)]);
    
    if waitforbuttonpress
        cc = get(gcf,'CurrentCharacter');
        if strcmp(cc,'q')
            break;
        elseif strcmp(cc,'f')
            id = min(id+1,nd);
        elseif strcmp(cc,'s')
            id = max(id-1,1);
        end
    end
end

disp('SECTION 31 COMPLETED.');
