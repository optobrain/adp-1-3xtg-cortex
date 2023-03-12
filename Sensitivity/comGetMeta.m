function [tbMeta, nd] = comGetMeta()

tbMeta = readtable("meta.xlsx", Sheet="meta");
tbMeta.animal = string(tbMeta.animal);
tbMeta.dtype = string(tbMeta.dtype);
tbMeta.eid = string(tbMeta.eid);
tbMeta.did = string(tbMeta.did);
tbMeta.p1id = string(tbMeta.p1id);
tbMeta.p2id = string(tbMeta.p2id);

nd = size(tbMeta,1);
for id=2:nd
    if tbMeta(id,:).animal == ""
        tbMeta(id,:).animal = tbMeta(id-1,:).animal;
    end
end

