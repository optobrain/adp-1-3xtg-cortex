    subplot(5,1,1);  cla;
        plot(log10(Dz));  axis tight;  ylim([log10(Dz(end)) max(get(gca,'ylim'))]);  grid on;
        line([1 nz],[1 1]*log10(Dz(nz1)));  line([1 1]*nz1,get(gca,'ylim'));  title([ 'nz1 = ' num2str(nz1) ]);
    subplot(5,1,(2:5));  cla;  hold on;
        PlotImage(log10(squeeze(max(DD(1:nz1,:,:),[],1)))',false,log10(ap.limD));  colorbar;  title('MIP');
