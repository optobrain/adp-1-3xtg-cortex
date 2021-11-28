nd = length(cpid);
if nd ~= length(ceid)
    error('The number of IDs is different between ceid and cpid');
end

if isempty(dir(pathdata))
    mkdir(pathdata);
end
if ~isempty(dir([pathdata aid '.mat']))
    a1 = 'Oops, I will change aid.';
    a2 = 'Yes, I want to load it and may re-analyze and overwrite it.';
    a = questdlg('The Analysis ID already exists. Do you want to load it?','',a1,a2,a1);
    switch a
        case a1
            error('Please change aid and re-run this session.');
        case a2
            load([pathdata aid '.mat']);
            disp('The existing analysis has been loaded.');
            ap
    end
else
    if isempty(dir([pathdata aidA '.mat']))
        error('No corresponding angio registration data. Check uidA and aidA.');
    else
        load([pathdata aidA '.mat'],'cr','ccor','ct','ap');
        if exist('ap','var')
            ap.bAngRegister = true;
            apA = ap;  clear ap;
        else
            ap.bAngRegister = false;
            warning('You skipped the registration of angiograms.');
        end
        disp('INIT COMPLETED.');
    end
end