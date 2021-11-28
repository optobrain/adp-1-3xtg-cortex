if isempty(dir(pathdata))
    mkdir(pathdata);
end
if ~isempty(dir([pathdata '/' pid '.mat']))
    a1 = 'Oops, I will change pid.';
    a2 = 'Yes, I want to load it and may re-process and overwrite it.';
    a = questdlg('The Process ID already exist. Do you want to load it?','',a1,a2,a1);
    switch a
        case a1
            error('Please change pid and re-run this session.');
        case a2
            load([pathdata '/' pid '.mat']);
            disp('The existing processed data has been loaded.');
            pp
    end
else
    if isempty(dir([pathdataA '/' pidA '.mat']))
        error('No corresponding angio data. Check uidA, eidA, and pidA.');
    else
        load([pathdataA '/' pidA '.mat'],'pp');
        ppA = pp;  clear pp;
        conf = ReadConf_16ThorlabsSD([pathraw '/' did '_.xml'])    
    end
end