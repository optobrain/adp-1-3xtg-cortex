        PlotImage(log10(D(:,:,id))',false,log10(limD(:,id)));  PlotBox(xx,yy,'w',2);  title([num2str(id) '/' num2str(nd)]);
        for iv1=1:nv
            v1 = V{iv1,id};
            lw = 2;  if iv1 == iv,  lw = 4;  end
            if ~isempty(v1)
                line(v1.r(1)+[-1 1]*nxwin*cos(v1.a),v1.r(2)+[-1 1]*nxwin*sin(-v1.a),'color',clr(iv1,:),'linewidth',lw);
            end
        end
