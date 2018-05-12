function [fid, width, height, ver] = cosFileHeader(fname)
%COSFILEHEADER reads file header for a COS file
%   [FID, WIDTH, HEIGHT, VER] = COSFILEHEADER(FID) reads the
%   TerraSAR-X/TanDEM-X file whose filename is FNAME.
%
%   FID returns the file identifier for the open file, with the file
%   pointer at the start. WIDTH is the width of the file in 32-bit samples
%   (i.e. the number of complex samples per range line plus 2). HEIGHT is
%   the number of lines in the file including annotation lines. VER is 1
%   for 16-bit integer TerraSAR-X data or 2 for half-precision TanDEM-X
%   data.

% Copyright 2014 David Young

% check we are on a little-endian computer. Would need modification if ever
% had to run on big-endian.
[~, ~, endianness] = computer;
if ~strcmp(endianness, 'L')
    error('DavidYoung:SARtools:bigendianMachine', ...
        'Unable to run on big-endian machine');
end

% check existence and get file size
fdata = dir(fname);
if isempty(fdata)
    error('DavidYoung:cosFileHeader:notFound', ...
        'Could not find %s', fname);
end
if ~isscalar(fdata) || fdata.isdir
    error('DavidYoung:cosFileHeader:ambiguous', ...
        '%s is a folder or matches several files', fname);
end
fsize = fdata.bytes;

% open file. Opening with 'b' option for big-endian reading ought to be
% best, but it actually seems quicker to read little-endian and swap bytes,
% at least in 64-bit Windows R2013b.
[fid, msg] = fopen(fname, 'r', 'l');
if fid < 0
    error('DavidYoung:cosFileHeader:notOpened', ...
        'Could not open %s; error was %s', fname, msg);
end

% first 15 entries are all we need for now
hsize = 15;
% see note above about swapbytes
header = swapbytes(fread(fid, [1 hsize], '*uint32'));
if length(header) ~= 15
    error('DavidYoung:cosFileHeader:readFailed', ...
        'Read failed for %s', fname);
end
% restore file pointer before we forget
frewind(fid);

% basic parameters
id = dec2hex(header(8));
if ~strcmp(id, '43534152')
    error('DavidYoung:cosFileHeader:idNotCSAR', ...
        '''CSAR'' identifier not in header for %s', fname);
end
width = header(3) + 2;
rtnb = header(6);
if 4*width ~= rtnb
    error('DavidYoung:cosFileHeader:widthInconsistent', ...
        'Width in samples (%d) and bytes(%d) inconsistent for %s', ...
        width, rtnb, fname);
end
height = header(7);
if rtnb * height ~= fsize
    error('DavidYoung:cosFileHeader:sizeInconsistent', ...
        ['File size (%d) inconsistent with width (%d) and height ' ...
        '(%d) for %s'], ...
        fsize, width, height, fname);
end

% distinguishing TanDEM and TerraSAR
ver = header(9);     % version
if ~ismember(ver, [1 2])
    error('DavidYoung:cosFileHeader:version', ...
        'Version number not 1 or 2, was %d for %s', header(9), fname);
end
if ver == 2 && ~isequal(header([13 14 15]), [1 5 10])
    error('DavidYoung:cosFileHeader:dataFormat', ...
        ['Expecting 1 5 10 for format parameters, found ' ...
        '%d %d %d for %s'], ...
        header([13 14 15]), fname);
end

end


