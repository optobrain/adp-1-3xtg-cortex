function [tbMeta, nd] = comGetMeta()

tbMeta = readtable("meta-if.xlsx", Sheet="meta-IF");
tbMeta.uid = string(tbMeta.uid);
tbMeta.eid = string(tbMeta.eid);
tbMeta.did = string(tbMeta.did);
tbMeta.animal = string(tbMeta.animal);
tbMeta.note = string(tbMeta.note);

nd = size(tbMeta,1);
for id=2:nd
    if tbMeta(id,:).uid == ""
        tbMeta(id,:).uid = tbMeta(id-1,:).uid;
    end
    if tbMeta(id,:).eid == ""
        tbMeta(id,:).eid = tbMeta(id-1,:).eid;
    end
end

