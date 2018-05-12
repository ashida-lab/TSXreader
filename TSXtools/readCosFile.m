function [data, info] = readCosFile(fname, burst)
%READCOSFILE reads data from a TerraSAR-X/TanDEM-X COS file
%   [DATA, INFO] = READCOSFILE(FNAME) reads the first burst from the file
%   FNAME. DATA is an array of data samples; DATA(1,:,:) is the real part
%   and DATA(2,:,:) is the imaginary part, using NEST's convention for
%   which is which. These are not packed into a complex array because of
%   the memory demands of the operation. The second index is the range
%   index and the third is the azimuth index. If the file is a version 1
%   COSAR file, as for TerraSAR-X, DATA has class int16. If the file is
%   version 2, as for TanDEM-X, DATA has class single.
% 
%   INFO returns burst information in a struct whose fields correspond to
%   the annotations described in the TerraSAR-X level 1b product format
%   specification, section 4.2. The data validity fields are included as
%   vectors with the appropriate length and orientation.
% 
%   [DATA, INFO] = READCOSFILE(FNAME, BURST) where BURST is a positive
%   integer reads the burst with the given number from the file.
% 
%   The function has not been tested on multi-burst files.
% 
%   The function will not run on big-endian machines. At the time of
%   writing this is not a limitation.
%
%   References
%   ----------
%
%   http://www2.astrium-geo.com/files/pmedia/public/r460_9_030201_level-1b-product-format-specification_1.3.pdf
%   and
%   https://tandemx-science.dlr.de/pdfs/TD-GS-PS-3028_TanDEM-X-Experimental-Product-Description_1.2.pdf
%
% See also: halfprecision

% Copyright 2014 David Young

narginchk(1, 2);
validateattributes(fname, {'char'}, {'row'});
if nargin < 2
    burst = 1;
else
    validateattributes(burst, {'numeric'}, ...
        {'positive' 'scalar' 'integer'});
end

% cosFileHeader checks we're on a little-endian machine
[fid, width, height, ver] = cosFileHeader(fname);

unread = height;

% loop past unwanted bursts
for b = 1:burst-1
    
    % read burst header
    info = cosBurstHeader(fid, width);
    nlines = info.as;
    if info.bi ~= b
        error('DavidYoung:readCosFile:badBurstIndex', ...
            'Burst %d had index %d', b, info.bi);
    end
    
    % skip samples
    fseek(fid, 4*width*nlines, 'cof');
    
    unread = unread - nlines - 4;
    if unread <= 0
        error('DavidYoung:readCosFile:noBurst', ...
            'File has only %d bursts, requested burst %d', b, burst);
    end
end

% read the required burst
info = cosBurstHeader(fid, width);
nlines = info.as;
if info.bi ~= burst
    error('DavidYoung:readCosFile:badBurstIndex', ...
        'Burst %d had index %d', burst, info.bi);
end

[data, rinfo] = cosSamples(fid, width, nlines, ver);

% combine info
info.rsfv = rinfo.rsfv;
info.rslv = rinfo.rslv;

fclose(fid);

end
