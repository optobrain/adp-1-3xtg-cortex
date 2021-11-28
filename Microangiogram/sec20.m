if isempty(dir(pathdata)), mkdir(pathdata); end

if ~isempty(dir([pathdata aid '.mat']))
    a1 = 'Oops, I will change aid.';
    a2 = 'Yes, I want to load it and may re-analyze and overwrite it.';
    a = questdlg('The Analysis ID already exists. Do you want to load it?','',a1,a2,a1);
    switch a
        case a1
            error('Please change aid and re-run this session.');
        case a2
            load([pathdata aid '.mat']);
            disp('The existing analysis data has been loaded.');
    end
else
    load([pathdata pid '.mat'],'nvexc','medfsize','gaufsize','DD');
    disp([ 'nvexc = ' num2str(nvexc) ]);
    disp([ 'medfsize = ' mat2str(medfsize) ]);
    disp([ 'gaufsize = ' mat2str(gaufsize) ]);
%     ListVars([pathdata pid '.mat'],10,'bytes');
    disp('INIT COMPLETED.');
end