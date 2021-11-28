disp('SECTION 33a RUNNING ...');
% SetParPool(6);

%% rxx

cp = round(roi.Position);
rxx = cp(1)+(1:cp(3));
ryy = cp(2)+(1:cp(4));


%% F A

F = zeros(nd,3);    % including both, only arterioles (red), only venules
A = zeros(nd,1);
for id=1:nd
    img = mean(cVV{id}(ciz(id)+(-zavg:zavg),rxx,ryy),1);  img = img(:);
    F(id,1) = sum(img);
    F(id,2) = sum(img(img>vArt));  
    F(id,3) = -sum(img(img<vVen));
    F(id,:) = F(id,:)*60*cda(id)*1e-6;  % mm/s*60*mm^2 = mm^3/min = uL/min
    A(id) = length(rxx)*length(ryy)*cda(id)*1e-6;  % mm^2
end


%% fig

figure('position',[.1 .1 3/4 1/4]*640);
for ii=1:3
    subplot(1,3,ii);
        plot(F(:,ii),'marker','o');
        xlim([0 nd+1]);  
        ylabel('Flow (uL/min)');  title(sflow{ii});
end
savefig(gcf,[pathrepo ' #33.fig']); 
saveas(gcf,[pathrepo ' #33.png']);


disp('SECTION 33a COMPLETED.');

