disp('SECTION 11 RUNNING ...');


%% robocopy [2106b]
    
    if isempty(dir(pathTemp))
        mkdir(pathTemp);
    end
    disp([datestr(now,'HH:MM') '  copying raw data to a temp folder ...']);
    disp(pathTemp);
    Robocopy([pathraw '/'],pathTemp,[did '*.lld']);
    disp([datestr(now,'HH:MM') '  copied.']);


disp('SECTION 11 COMPLETED.');