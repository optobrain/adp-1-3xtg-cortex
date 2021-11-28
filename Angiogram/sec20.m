if ~isempty(dir([pathdata '/' aid '.mat']))
    a1 = 'Oops, I will change aid.';
    a2 = 'Yes, I want to load it and may re-analyze and overwrite it.';
    a = questdlg('The Analysis ID already exist. Do you want to load it?','',a1,a2,a1);
    switch a
        case a1
            error('Please change aid and re-run this session.');
        case a2
            load([pathdata '/' aid '.mat']);
            disp('The existing analysis data has been loaded.');
            ap
    end
else
    disp('INITIATION COMPLETED.');
end		
