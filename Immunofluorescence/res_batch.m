
function res_batch(ibatch)

p1suff = "p1a";
p2suff = ["p2a", "p2b", "p2c"];
p3suff = ["p3a", "p3b", "p3c", "p3d"];

i2 = ceil(ibatch/numel(p3suff))
i3 = ibatch - (i2-1)*numel(p3suff)

p2suff(i2)
p3suff(i3)

rid = sprintf("%s%s%s", extractAfter(p1suff,2), extractAfter(p2suff(i2),2), extractAfter(p3suff(i3),2))

res(rid, "p1a", p2suff(i2), p3suff(i3));  


%% without job submission
%{
clear;

% p2a resulted in too low DAPI cell numbers (ratio >> 1, which makes little sense)
% res("aaa", "p1a", "p2a", "p3a");  close all;
% res("aab", "p1a", "p2a", "p3b");  close all;
% res("aac", "p1a", "p2a", "p3c");  close all;
% res("aad", "p1a", "p2a", "p3d");  close all;

res("aba", "p1a", "p2b", "p3a");  close all;
res("abb", "p1a", "p2b", "p3b");  close all;
res("abc", "p1a", "p2b", "p3c");  close all;
res("abd", "p1a", "p2b", "p3d");  close all;

res("aca", "p1a", "p2c", "p3a");  close all;
res("acb", "p1a", "p2c", "p3b");  close all;
res("acc", "p1a", "p2c", "p3c");  close all;
res("acd", "p1a", "p2c", "p3d");  close all;
%}