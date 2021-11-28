tic

E = [];
G = [];
clear ed

% find all vessel endpoints (forming nodes)
% for i = 1:length(S)
%     s = S{i};
%     e1 = s(1,:);
%     en = s(end,:);
%     
%    E = [E; [e1(1) e1(2) e1(3)]; [en(1) en(2) en(3)]];
% end
E = cellfun(@(x) [x(1,:); x(end,:)] ,S ,'UniformOutput' ,false);
E = cell2mat(E');
E = unique(E, 'rows');

ep = bwmorph3(skg, 'endpoints');
ep2 = rem_easy(skg);
ep = ep + ep2>0;
[m,n,v] = ind2sub(size(skg), find(ep(:)==1));
E_p = [m,n,v];

E(ismember(E,E_p, 'rows')==1,:) = [];

%find which vessel segments are connected to each endpoint

parfor i = 1:size(E,1)
    e = E(i,:);
    c = cellfun(@(x)sum((ismember(x,e, 'rows'))),S);
    ed{i} = find(c>0);
end

c_ed = cellfun(@(x)length(x),ed);
%S([ed{c_ed==1}]) = [];
%ed(c_ed==1) = [];

%% check to see if loops
cand = [ed{c_ed == 1}];
for l = 1:length(cand)
    s = S{cand(l)};
    [C,ia,ib]=unique(s,'rows','stable');
    i = true(size(s,1),1);
    i(ia)=false;
    u = s(i,:);
    for q = 1:size(u,1)
        if sum(find(ismember(s, u(q,:), 'rows')) > 2) >0
            l
        end
    end
end

G = [];

%find which vessels connect which endpoints:
%First two columns of G are endpoints, last column is vessel number 

% parfor i = 1:length(ed)
%     
%     n = ed{i};
%     for j = 1:length(n)
%         c = cellfun(@(x)sum((ismember(x,n(j)))),ed);
%         ind = find(c>0);
%         ind(ind==i) = [];
%         for k  =1:length(ind)
%             G = [G;[i ind(k) n(j)]];
%         end
%     end
% end
%         
% toc
%g = (graph(sparse(G(:,1),G(:,2),G(:,3))));
%plot(g, 'Edgelabel',g.Edges.Weight, 'Nodelabel', [], 'XData',E(:,1),'YData',E(:,2),'ZData',E(:,3))