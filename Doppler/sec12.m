disp('SECTION 12 RUNNING ...');
% SetParPool(6);

% pp.izc, ax, ay
    if ~exist('pp','var') || ~isfield(pp,'izc')
        [~,pp.izc] = max(II0(:,end/2,end/2));  % iz at (nx/2,ny/2)
        pp.ax = 0;  pp.ay = 0;  % slopes in X and Y
    end

% UI
    % [gx,gz,gy] = meshgrid(1:nx,1:nz,1:ny);
    figure(1);  clf;  colormap(gray);  pause(.1);
    while true

%         tic; %% only 1-s faster (3.6 s)
%         M = sign(gz - ( ax*(gx-nx/2) + ay*(gy-ny/2) + izc ));
%         II = II0.*(M+1)/2;
%         toc;
% 
%         tic;  %% 1-s slower (4.7 s)
%         II = II0;  
%         DD = DD0;
%         wb = waitbar(0,'Removing artifacts ...');
%         for ix=1:nx
%             for iy=1:ny
%                 iza = ax*(ix-nx/2) + ay*(iy-ny/2) + izc;
%                 iza = max(round(iza),1);
%     %             II(1:iza,ix,iy) = 0;
%                 DD(1:iza,ix,iy) = 0;
%             end
%             waitbar(ix/nx,wb);
%         end
%         close(wb);
%         toc;

        DD = funRemove(DD0,pp.izc,pp.ax,pp.ay,waitbar(0,'Removing artifacts ...'));

        figure(1);  clf;
        sec12_plot;

        if waitforbuttonpress
            cc = get(gcf,'CurrentCharacter');
            if strcmp(cc,'q')        
                break;
            elseif strcmp(cc,'g')
                gi = round(ginput(4));
                pp.ax = (gi(1,2)-gi(2,2)) / (gi(1,1)-gi(2,1));
                pp.ay = (gi(3,2)-gi(4,2)) / (gi(3,1)-gi(4,1));
                izc1 = gi(1,2)+pp.ax*(nx/2-gi(1,1));
                izc2 = gi(3,2)+pp.ax*(ny/2-gi(3,1));
                pp.izc = round(mean([izc1 izc2]));
    %             izc = round(gi(2));
            elseif strcmp(cc,'e')
                pp.izc = max(pp.izc-dzc,1);
            elseif strcmp(cc,'d')
                pp.izc = min(pp.izc+dzc,nz);
            elseif strcmp(cc,'s')
                pp.ax = pp.ax - da;
            elseif strcmp(cc,'f')
                pp.ax = pp.ax + da;
            elseif strcmp(cc,'w')
                pp.ay = pp.ay - da;
            elseif strcmp(cc,'r')
                pp.ay = pp.ay + da;
            end
        end

    end 

    figure('position',[1 1 10 10/1.5]*85);  colormap(gray);
    sec12_plot;
    
disp('SECTION 12 COMPLETED.');
