disp('SECTION 21 RUNNING ...');
SetParPool(4);  % 6 uses 60 GB in FRGtoRR when using RR1 = FRGtoRR(FRG,0.24) after the for loop

nk = 2048;  nz = nk/2;  
for id=1:nd

    eid = ceid{id};
    did = cdid{id};
    eid_mang = ceid_mang{id};
    pid_mang = cpid_mang{id};
    pid = cpid{id};

    pathraw1 = [pathraw '/' eid];  % path of rawdata
    pathrepo1 = [pathrepo ' # ' eid ' # ' pid];  % path of report figures

    pathmang1 = [pathdata '/' eid_mang '/' pid_mang '.mat'];
%     load(pathmang1,'dk','DD','izc','zz','ax','ay');  DD_mang = DD;  clear DD;
    l = load(pathmang1,'dk','zz','pp');  % 2107a : new Angiogram / 1 Reconstruct code saves zz in pp
    if isfield(l,'pp')
        zz = l.pp.zz;
        dk = l.pp.dk;
    else
        zz = l.zz;
        dk = l.dk;
    end
    
    zend = min(zz(end)+100,nz);

    conf = cconf{id};
    nx = conf.nx;  ny = conf.ny;  nv = conf.nv;
    MX = conf.MX;  MY = conf.MY;
    if conf.apx > 1 || conf.bpy > 1 || conf.nv > 1
        error('apx and bpy and nv should be 1');
    end

    for IY=1:MY  % no need to merge over Y because they acquired in different time (no temporarily neighboring)
                 % when merged, RRR is 128 GB memory
                 
        pathdata1 = [pathdata '/' eid '/' pid '_y' NumToStr(IY,3) '.mat'];
        d = dir(pathdata1);
        if isempty(d)
            RR = complex(zeros(zend,nx*MX,1,ny,'single'));  % ny = nt 
            for IX=1:MX            
                FRG = zeros(nk,nx,ny,'single');
                for iy=1:ny
                    try
                        fpath = [pathraw1 '/' did '_b' NumToStr(iy,5) 'v001x' NumToStr(IX,3) 'y' NumToStr(IY,3) 'z' NumToStr(IZ,3) '.lld'];
                        FRG(:,:,iy) = ReadLLD_16ThorlabsSD(fpath,conf);
                    catch ME
                        warning(['error at [id IZ IY IX iy] = ' mat2str([id IZ IY IX iy])]);
                        disp('trying again 10 s later ...');
                        pause(10);
                        try
                            fpath = [pathraw1 '/' did '_b' NumToStr(iy,5) 'v001x' NumToStr(IX,3) 'y' NumToStr(IY,3) 'z' NumToStr(IZ,3) '.lld'];
                            FRG(:,:,iy) = ReadLLD_16ThorlabsSD(fpath,conf);
                        catch ME2
                            disp(['error again at [id IZ IY IX iy] = ' mat2str([id IZ IY IX iy])]);
                            warning('reading adjacent-y data instead ...');
                            if iy > 1
                                fpath = [pathraw1 '/' did '_b' NumToStr(iy-1,5) 'v001x' NumToStr(IX,3) 'y' NumToStr(IY,3) 'z' NumToStr(IZ,3) '.lld'];
                                FRG(:,:,iy) = ReadLLD_16ThorlabsSD(fpath,conf);
                            else
                                fpath = [pathraw1 '/' did '_b' NumToStr(iy+1,5) 'v001x' NumToStr(IX,3) 'y' NumToStr(IY,3) 'z' NumToStr(IZ,3) '.lld'];
                                FRG(:,:,iy) = ReadLLD_16ThorlabsSD(fpath,conf);
                            end                                
                        end
                    end
                end
                R = FRGtoRR(FRG,dk);
                RR(:,(IX-1)*nx+[1:nx],1,:) = reshape(R(1:zend,:,:),[zend nx 1 ny]);  % ny = nt
                disp([ datestr(now,'HH:MM') '  ' mat2str([id IY IX]) '/' mat2str([nd MY MX]) ]);
            end
            save('-v7.3',pathdata1,'RR');
        else
            disp(['Data file exists (' num2str(round(d.bytes/1e6)) ' MB), so we skipped ' mat2str([id IY]) '/' mat2str([nd MY]) ]);
        end
        
        %{    
        figure('position',[1 1 10 10/1.5]*85);  colormap(gray);
    %         subplot(231);  cla;  PlotImage(log10(mean(II0,3)),false,[.1 .99],true);  xlabel('X');  ylabel('Z');  title('Mean intensity');
    %         subplot(232);  cla;  PlotImage(log10(squeeze(mean(II0,2))),false,[.1 .99],true);  xlabel('Y');  ylabel('Z');  title('Mean intensity');
    %         subplot(233);  cla;  hold on;  PlotImage(log10(squeeze(mean(II0,1)))',false,[.1 .95],true);  xlabel('X');  ylabel('Y');   title('Mean intensity');
            subplot(231);  cla;  PlotImage(log10(II0(:,:,end/2)),false,[.1 .99],true);  xlabel('X');  ylabel('Z');  title('Intensity: Center slice');
            subplot(232);  cla;  PlotImage(log10(squeeze(II0(:,end/2,:))),false,[.1 .99],true);  xlabel('Y');  ylabel('Z');  title('Center slice');
            subplot(233);  cla;  hold on;  PlotImage(log10(squeeze(max(II0,[],1)))',false,[.1 .95],true);  xlabel('X');  ylabel('Y');   title('MIP');
            subplot(234);  cla;  PlotImage(log10(DD0(:,:,end/2)),false,[.1 .99],true);  xlabel('X');  ylabel('Z');  title('Decorrelation: Center slice');
            subplot(235);  cla;  PlotImage(log10(squeeze(DD0(:,end/2,:))),false,[.1 .99],true);  xlabel('Y');  ylabel('Z');  title('Center slice');
            subplot(236);  cla;  hold on;  PlotImage(log10(squeeze(max(DD0,[],1)))',false,[.1 .95],true);  xlabel('X');  ylabel('Y');   title('MIP');
        %}
        
    end
    
    disp([ datestr(now,'HH:MM') '  ... deleting raw data' ]);
    
    fpath = [pathraw1 '/' did '*.lld'];
    delete(fpath);
%     if length(dir(pathraw1)) <= 3  % including xml file
%         movefile pathraw1 [pathraw1 ' ## deleted'];  
%     end
    
    disp([ '[' did '] RR are saved and the raw data deleted.' ]);  

end

disp('SECTION 21 COMPLETED.');