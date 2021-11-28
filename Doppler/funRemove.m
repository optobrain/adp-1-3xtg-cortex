
function DD = funRemove(DD, izc, ax, ay, wb)

    [~,nx,ny] = size(DD);
    for ix=1:nx
        for iy=1:ny
            iza = ax*(ix-nx/2) + ay*(iy-ny/2) + izc;
            iza = max(round(iza),1);
            DD(1:iza,ix,iy) = 0;
        end
        waitbar(ix/nx,wb);
    end
    close(wb);
