function [samples, sampinfo] = cosSamples(fid, width, as, ver)
%COSSAMPLES reads data samples from a COS file
%   [SAMPLES, SAMPINFO] = COSSAMPLES(FID, WIDTH, AS, VER) reads a burst of
%   data samples from a TerraSAR-X/TanDEM-X file whose file identifier is
%   FID and whose width in 32-bit samples is WIDTH. The file must be open
%   at the start of the data samples. On return the file is left open at
%   the start of the next burst. AS is the number of azimuth samples in the
%   burst and VER is the version number for the COSAR file.
%
%   SAMPLES is an array of class int16 if VER is 1 and of class
%   single if VER is 2. Repacking as a complex array can use too much
%   memory, so the real parts are in SAMPLES(1,:,:) and the imaginary parts
%   are in SAMPLES(2,:,:).
%
%   SAMPINFO is a struct whose fields contain the range annotations
%   described in the TerraSAR-X level 1b product format specification,
%   section 4.2.

% Copyright 2014 David Young

% see note in cosFileHeader about reading big-endian vs swapbytes
samples = fread(fid, [width as], '*uint32');
if ~isequal(size(samples), [width as])
    error('DavidYoung:cosSamples:readFailed', ...
        'Samples read failed after %d samples', numel(samples));
end

% swapbytes applied to uint32 here - reverse order within each 32-bit value
sampinfo = struct( ...
    'rsfv', swapbytes(samples(1, :)), ...
    'rslv', swapbytes(samples(2, :)));

samples = samples(3:width, :);
samples = samples(:);    % needed for typecast
w = width - 2;

% convert samples
% swapbytes applied to int16 here - reverse order within each 16-bit value
% since NEST takes first value to be real and second to be imag
switch ver
    case 1       % samples are int16
        samples = swapbytes(typecast(samples, 'int16'));
    case 2
        samples = halfprecision( ...
            swapbytes(typecast(samples, 'uint16')), ...
            'single');
    otherwise
        error('DavidYoung:cosSamples:badVersion', ...
            'VER must be 1 or 2, was %d', ver);
end

% store as complex and reshape
samples = reshape(samples, 2, w, as);

end