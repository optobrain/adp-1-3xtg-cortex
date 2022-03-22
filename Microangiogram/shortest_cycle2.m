function [L, E,Cs] = shortest_cycle2(S,ed,g)

it = 1;
cs = cellfun(@(x) size(x,1) ,S);
for j = 1:length(S)
s = S{j};
g2 = g;
c = cellfun(@(x) sum(ismember(x,j)),ed);
ind = find(c);
 
if length(ind)>1  && size(s,1) > 2
    
    x1 = ed{ind(1)};
    x1(x1==j) = [];
        for jj = 1:length(x1)
            if j < x1(jj)
                fi = (g.Edges.EndNodes(:,1) == j & g.Edges.EndNodes(:,2) == x1(jj) );
                g2.Edges.Weight(fi,:) = 1000;
            else
                 fi = (g.Edges.EndNodes(:,2) == j & g.Edges.EndNodes(:,1) == x1(jj) );
                 g2.Edges.Weight(fi,:) = 1000;
            end
        end

    
    
    x2 = ed{ind(2)};
    x2(x2==j) = [];
  

        for jj = 1:length(x2)
            if j < x2(jj)
                fi = (g.Edges.EndNodes(:,1) == j & g.Edges.EndNodes(:,2) == x2(jj) );
                g2.Edges.Weight(fi,:) = 1000;
            else
                fi = (g.Edges.EndNodes(:,2) == j & g.Edges.EndNodes(:,1) == x2(jj) );
                g2.Edges.Weight(fi,:) = 1000;
            end
        end

    
   
    Sp = 1000;
    for i1 = 1:length(x1)
        for j1 = 1:length(x2)
            [sp, d] = shortestpath(g2,x1(i1), x2(j1));
            if length(sp) < Sp && d >0
                Sp = d;
                Spv = sp;
            end
        end
    end
    E{it} = [j Spv];
    L(it) = Sp+1;
    Cs{it} = cs(E{it});
it = it+1;
end


end

        