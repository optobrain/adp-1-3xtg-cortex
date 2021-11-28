disp('SECTION 29 RUNNING ...');

fpath = ['D:/' uid '/' aid '.mat'];
if ~isempty(dir(fpath))
    disp('Overwriting Data ...');
else 
    disp('Saving Data ...');
end
clear DD Bp B xx yy; % Dc is needed when user wants to change the ROI later.
save(fpath);
disp(['Coregistered MIPs saved to ' fpath]);

disp('SECTION 29 COMPLETED.');
