figure('position',[.1 .1 1/4 1/3]*640);  hold on;
if (ivt == 1),  fWT = faWT;  fAaD = faAD;  else,  fWT = fvWT;  fAD = fvAD;  end
if (id == 1),  val = fWT;  else,  val = fAD;  end
for iv=1:size(val,1)
    line(t,val(iv,:), 'color',clrbg);
end
for io=1:length(iol)
    line(tbFsub(iol(io),:).Week,tbFsub(iol(io),:).Flow, 'color',clrbg, 'marker','o', 'markersize',3);
end
% errorbar(ti, vdfitmean, tinv(0.95,size(vd,1)-1)*vdfitse, 'color',clr(id,:), 'linewidth',1.2, 'marker','o', 'markersize',4);
line(ti,fitmean, 'color',clr(id,:), 'linewidth',1.2);
line(ti,fitmean+tinv(0.95,size(val,1)-1)*fitse, 'color',clr(id,:));
line(ti,fitmean-tinv(0.95,size(val,1)-1)*fitse, 'color',clr(id,:));
xlim([t(1)-2 t(end)+2]);  ylim(limY);

it0 = find(ti==t(1));
p = zeros(size(fitmean));
for it=1:length(p)
    p(it) = GetP_studentT([fitmean(it), fitse(it)*sqrt(size(val,1)), size(val,1)], [fitmean(it0), fitse(it0)*sqrt(size(val,1)), size(val,1)]);
end
idx = find(diff(p<0.05) == 1);
if ~isempty(idx)
%     line(ti(idx+1)*[1 1],get(gca,'ylim'),'color','r','linestyle',':');
    line(ti(idx+1),max(get(gca,'ylim')),'color','r','marker','+');
    disp(['Became significantly different from ' num2str(t(1)) ' woa at ' num2str(ti(idx+1)) ' woa.']);
else
    disp(['No significant difference from ' num2str(t(1)) ' woa, p(t1,tend)=' num2str(p(ti==t(end)),3)]);
end
set(gca,'xtick',t);  set(gca,'xticklabel',compose('%d',t));
% xlabel('Age (wks)');  

