function burstinfo = cosBurstHeader(fid, width)
%COSBURSTHEADER reads burst header for a COS file
%   BURSTINFO = COSBURSTHEADER(FID, WIDTH) reads a burst header in a
%   TerraSAR-X/TanDEM-X file whose file identifier is FID and whose width
%   in 32-bit samples is WIDTH. The file must be open at the start of the
%   burst annotation. On return the file is left open at the start of the
%   burst data.
% 
%   BURSTINFO is a struct whose fields contain the values described in the
%   TerraSAR-X level 1b product format specification, section 4.2. Azimuth
%   annotation is included with the burst annotation.

% Copyright 2014 David Young

% see note in cosFileHeader about reading big-endian vs swapbytes
[header, msg] = fread(fid, [width 4], '*uint32');
header = swapbytes(header);
if ~isequal(size(header), [width 4])
    error('DavidYoung:cosBurstHeader:readFailed', ...
        'Burst header read failed with message: %s', msg);
end

if ~all(all(header(1:2, 2:4) == hex2dec('7f7f7f7f')))
    error('DavidYoung:cosBurstHeader:badFiller', ...
        'Incorrect filler value found in burst header');
end    

burstinfo = struct( ...
    'bib', header(1,1), ...   % only valid for ScanSAR, apparently
    'rsri', header(2,1), ...
    'rs', header(3,1), ...
    'as', header(4,1), ...
    'bi', header(5,1), ...
    'overSamplingFactor', header(10), ...     % 1, 2 or 3
    'invSPECANrate', 'Not implemented', ...
    'asri', header(3:width, 2), ...
    'asfv', header(3:width, 3), ...
    'aslv', header(4:width, 4));

end


