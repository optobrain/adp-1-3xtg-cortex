if ~isempty(dir([pathdata '/' aid2 '.mat']))
    a1 = 'Oops, I will change aid2.';
    a2 = 'Yes, I want to load it and may re-analyze and overwrite it.';
    a = questdlg('The Analysis ID to save already exists. Do you want to load it?','',a1,a2,a1);
    switch a
        case a1
            error('Please change aid2 and re-run this session.');
        case a2
            load([pathdata '/' aid2 '.mat']);
            disp('The existing analysis data has been loaded.');
            ap2
    end
else
    if isempty(dir([pathdata '/' aid '.mat']))
        error('The result of 2 Coregister MIP.mlx cannot be found. Check aid.');
    else
%         ListVars([pathdata '/' aid '.mat'],10);
        load([pathdata '/' aid '.mat'],'D','ap','cconf');
        disp('Coregistration data loaded.  The data used the following analysis options:');
        if exist('ap','var')  % ap is not used in process 3 [2006a]
            ap
        else
            warning('The MIPs were not registered.');
        end
    end
end		
