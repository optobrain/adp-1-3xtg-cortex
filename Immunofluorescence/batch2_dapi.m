clear;

p1suff = "p1a";
p2suff = "p2a";

parfor id=1:59
    app2_dapi(p1suff, p2suff, id);
end
