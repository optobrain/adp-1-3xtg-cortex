disp('SECTION 39 RUNNING ...');

ap2.limC = limC;
ap2.nxwin = nxwin;
ap2.bDzero = bDzero;
ap2.na = na;
ap2.navg = navg;

fpath = ['D:/' uid '/' aid2 '.mat'];
if ~isempty(dir(fpath))
    disp('Overwriting Analysis ...');
else 
    disp('Saving Analysis ...');
end
clear D; % D was loaded from MIP and not manipulated here.
save(fpath);
disp(['All vessel information saved to ' fpath]);

disp('SECTION 39 COMPLETED.');
