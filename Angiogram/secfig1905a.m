est = lme.Coefficients.Estimate;
se = lme.Coefficients.SE;
covr = lme.CoefficientCovariance;
vdfitmean = est(1) + est(2) .* ti;
vdfitse = sqrt( se(1)^2 + ( se(2) .* ti ).^2 + 2*covr(1,2).*ti );

it0 = find(ti-t(1)==0);
p = zeros(size(vdfitmean));
for it=1:length(p)
    p(it) = GetP_studentT([vdfitmean(it), vdfitse(it)*sqrt(size(vd,1)), size(vd,1)], [vdfitmean(it0), vdfitse(it0)*sqrt(size(vd,1)), size(vd,1)]);
end
idx = find(diff(p<0.05) == 1);

figure('position',[.1 .1 1/4 1/4]*650);  hold on;
if (id == 1),  vd = vdWT;  else,  vd = vdAD;  end
for iv=1:size(vd,1)
    line(t,vd(iv,:), 'color',clrbg);
end
for io=1:length(iol)
    line(tbVDsub(iol(io),:).Week,tbVDsub(iol(io),:).Diameter, 'color',clrbg, 'marker','o', 'markersize',3);
end
% errorbar(ti, vdfitmean, tinv(0.95,size(vd,1)-1)*vdfitse, 'color',clr(id,:), 'linewidth',1.2, 'marker','o', 'markersize',4);
line(ti,vdfitmean, 'color',clr(id,:), 'linewidth',1.2);
line(ti,vdfitmean+tinv(0.95,size(vd,1)-1)*vdfitse, 'color',clr(id,:));
line(ti,vdfitmean-tinv(0.95,size(vd,1)-1)*vdfitse, 'color',clr(id,:));
xlim([t(1)-2 t(end)+2]);  ylim([10 65]);
if ~isempty(idx)
%     line(ti(idx+1)*[1 1],get(gca,'ylim'),'color','r','linestyle',':');
    line(ti(idx+1),max(get(gca,'ylim')),'color','r','marker','+');
    disp(['Became significantly different from week ' num2str(t(1)) ' at week ' num2str(ti(idx+1))]);
else
    disp(['No significant difference from week ' num2str(t(1)) ', p(t1,tend)=' num2str(p(find(ti==t(end))),3)]);
end
set(gca,'xtick',t);  set(gca,'xticklabel',compose('%d',t));
% xlabel('Age (wks)');  

