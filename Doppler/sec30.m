if ~isempty(dir([pathdata aid2 '.mat']))
    a1 = 'Oops, I will change aid2.';
    a2 = 'Yes, I want to load it and may re-analyze and overwrite it.';
    a = questdlg('The Analysis ID already exists. Do you want to load it?','',a1,a2,a1);
    switch a
        case a1
            error('Please change aid2 and re-run this session.');
        case a2
            load([pathdata aid2 '.mat']);
            disp('The existing analysis has been loaded.');
            ap2
    end
else
    if isempty(dir([pathdata aid '.mat']))
        error('The result of 2 Register Doppler.mlx cannot be found.  Check aid.');
    else
        load([pathdata aid '.mat'],'cVV','ap','ciz','cda','cIz');
        nd = length(cVV);  [~,nx,ny] = size(cVV{1});
        disp('Registered Doppler data loaded.  The data used the following analysis options:');
        ap
    end
end