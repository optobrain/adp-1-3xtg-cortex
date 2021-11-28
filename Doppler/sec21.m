disp('SECTION 21 RUNNING ...');

cVV = cell(nd,1);  cIz = cell(nd,1);  cda = zeros(nd,1);
for id=1:nd
    load([pathdata ceid{id} '\' cpid{id} '.mat'],'VV','II','conf');
    cVV{id} = VV;
    cIz{id} = mean(II(:,:),2);    
    cda(id) = conf.dx * conf.dy;  % um^2 
    disp([datestr(now,'HH:MM') ' data loaded ' num2str(id) '/' num2str(nd)]);
end
clear VV II;
cVV0 = cVV;  % 2 GB

disp('SECTION 21 COMPLETED.');