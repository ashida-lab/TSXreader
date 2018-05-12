function result=SAR_registration(slc_dat1,tform1_linepixel2latlon,slc_dat2,tform2_latlon2linepixel)
block_size=2000;

Nx=size(slc_dat1,2);
Ny=size(slc_dat1,1);

xcnt_max=int16(Nx/block_size)+1;
ycnt_max=int16(Ny/block_size)+1;

block_size_x=int16(Nx/xcnt_max);
block_size_y=int16(Ny/ycnt_max);

for xcnt=1:xcnt_max
    for ycnt=1:ycnt_max
        master=slc_dat1((ycnt-1)*block_size_y+1:ycnt*block_size_y,(xcnt-1)*block_size_x+1:xcnt*block_size_x);
        
        min_range=tform2_latlon2linepixel.T.'*tform1_linepixel2latlon.T.'*single([(xcnt-1)*block_size_x+1 (ycnt-1)*block_size_y+1 1].');
        max_range=tform2_latlon2linepixel.T.'*tform1_linepixel2latlon.T.'*single([(xcnt)*block_size_x+1 (ycnt)*block_size_y+1 1].');
        
        min_range=minmax_check(min_range,size(slc_dat2,2),size(slc_dat2,1));
        max_range=minmax_check(max_range,size(slc_dat2,2),size(slc_dat2,1));
        
        slave=slc_dat2(min_range(2):max_range(2),min_range(1):max_range(1));
        
        figure;imagesc(log10(abs(master)));
        colormap('gray');
        figure;imagesc(log10(abs(slave)));
        colormap('gray');
    end
end

end