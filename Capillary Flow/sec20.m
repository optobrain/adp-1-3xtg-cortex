nd = length(ceid);
if length(cdid) ~= nd
    error('The length of cdid is different from ceid.');
end
if length(ceid_mang) ~= nd
    error('The length of ceid_mang is different from ceid.');
end
if length(cpid_mang) ~= nd
    error('The length of cpid_mang is different from ceid.');
end
if length(cpid) ~= nd
    error('The length of cpid is different from ceid.');
end

cconf = cell(nd,1);
for id=1:nd
    p = [pathraw '/' ceid{id} '/' cdid{id} '_.xml'];
    if isempty(dir(p))
        error(['No conf xml exists in ' p]);
    else
        cconf{id} = ReadConf_16ThorlabsSD(p);
    end
    
    p = [pathdata '/' ceid{id}];
    if isempty(dir(p))
        mkdir(p);
    end
    
    p = [pathdata '/' ceid{id} '/' cpid{id} '.mat'];
    if ~isempty(dir(p))
        error(['A file with the same pid already exists: ' p]);
    end
end

disp('INITIATION COMPLETED.');

    
    