    for iv1=1:nv
        v1 = V{iv1,id};
        if ~isempty(v1)
            lw = 1;  if iv1 == iv,  lw = 1;  end
%             ii = 5+iv1;
%             if iv1 <= 2,  ii = 3+iv1;  end
%             subplot(5,5,ii);  cla;  
            if iv1 == 1
                ii = 6;
            elseif iv1 <= 3
                ii = 6+4+(iv1-1);
            elseif iv1 <= 5
                ii = 12+4+(iv1-3);
            elseif iv1 <= 7
                ii = 18+4+(iv1-5);
            else
                ii = 24+(iv1-7);
            end
            subplot(6,6,ii);  cla;  
                line(-nxwin:nxwin,v1.Ix,'color',clr(iv1,:),'marker','o','linestyle','none','linewidth',lw);  
                line(-nxwin:nxwin,v1.Ixfit,'color',clr(iv1,:),'linewidth',lw);  set(gca,'ytick',[]);
%                     title(['V1: ' mat2str([v1.d v1.R2 v1.a*180/pi],2)]);
                title(['V' num2str(iv1) ': d=' num2str(v1.d,2) ' R^2=' num2str(v1.R2,2)]);
        end
%         for iid=1:nd
%             v1 = V{iv1,iid};
%             if ~isempty(v1)
%                 Vd(iv1,iid) = v1.d;  VR2(iv1,iid) = v1.R2;
%             end
%         end
    end

%     subplot(5,5,25);  cla;
%         for iv1=1:nv
%             lw = 1;  if (iv1 == iv)  lw = 2;  end;  
%             line(1:nd,Vd(iv1,:),'color',clr(iv1,:),'linewidth',lw);
%         end
%         xlabel('did');  ylabel('Diameter (px)');  title('Traces');
