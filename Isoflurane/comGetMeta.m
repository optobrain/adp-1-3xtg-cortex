function [tbMeta, nd] = comGetMeta()

tbMeta = readtable("meta.xlsx", Sheet="meta");
tbMeta.grp = string(tbMeta.grp);
tbMeta.dtype = string(tbMeta.dtype);
tbMeta.eid = string(tbMeta.eid);
tbMeta.did = string(tbMeta.did);
tbMeta.pathdata = [];

nd = size(tbMeta,1);
% for id=2:nd
%     if tbMeta(id,:).uid == ""
%         tbMeta(id,:).uid = tbMeta(id-1,:).uid;
%     end
%     if tbMeta(id,:).eid == ""
%         tbMeta(id,:).eid = tbMeta(id-1,:).eid;
%     end
% end
% 
