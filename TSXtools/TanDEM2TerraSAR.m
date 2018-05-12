function TanDEM2TerraSAR(filein, fileout)
%TanDEM2TerraSAR converts TanDEM-X COSAR files to TerraSAR-X COSAR files
%   TANDEM2TERRASAR(FILEIN, FILEOUT) reads TanDEM-X data (COSAR version 2)
%   from FILEIN and writes it in TerraSAR-X format (COSAR version 1) to
%   FILEOUT.
%
%   The COSAR formats are almost identical, except that version 2 uses
%   half-precision floating-point for the data samples whereas version 1
%   uses 16-bit ints. This function uses James Tursa's halfprecision
%   function for sample conversion. There is inevitably some loss of
%   precision in rounding to integers.
% 
%   Some software, such as the Next ESA SAR Toolbox, cannot correctly read
%   version 2 files at the time of writing. The purpose of this function is
%   to allow such software to import the data from such files. For this
%   reason, the reverse function is not provided.
%
%   A whole burst is read before conversion, so you need plenty of
%   memory.
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

validateattributes(filein, {'char'}, {'row'});
validateattributes(fileout, {'char'}, {'row'});

% cosFileHeader checks that we are on a little-endian machine
[fid, width, height, ver] = cosFileHeader(filein);
if ver ~= 2
    error('DavidYoung:TanDEM2TerraSAR:version', ...
        'Not version 2 COSAR data, version was %d', ver);
end

% we write little-endian and use swapbytes so that we can treat the samples
% and annotations correctly. Also it may be faster.
fido = fopen(fileout, 'w', 'l');

unread = height;

% loop over bursts
burst = 0;
while unread > 0
    burst = burst + 1;
    
    % read burst header
    fpos = ftell(fid);      % save file position
    bursthdr = cosBurstHeader(fid, width);
    if bursthdr.bi ~= burst
        error('DavidYoung:TanDEM2TerraSAR:burstIndex', ...
            'Found burst index %d for burst %d', bursthdr.bi, burst);
    end
    nlines = bursthdr.as;
    nsampline = bursthdr.rs;
    
    % reread burst header to make sure nothing is lost
    fseek(fid, fpos, 'bof');    % back to start of burst
    % see note in cosFileHeader about big-endian read vs swapbytes
    bhdrRaw = swapbytes(fread(fid, [width, 4], '*uint32'));
    % fix version number and sample format details
    bhdrRaw([9 13 14 15], 1) = [1 1 0 15];
    
    % write burst header
    fwrite(fido, swapbytes(bhdrRaw), 'uint32');
    
    % read samples
    [samples, sampinfo] = cosSamples(fid, width, nlines, ver);
    samples = samples(:);    % samples are complex single precision
    if any(samples > intmax('int16')) || any(samples < intmin('int16'))
        warning('Data samples have out-of-range values - truncating');
    end
    % convert from single precision to int16, rounding and truncating - and
    % swapping bytes on 16-bit values, not on 32 bit
    samples = swapbytes(int16(samples));
    
    % make it look like a uint32 array and reassemble annotations - they
    % need swapbytes to be applied to the 32-bit values
    samples = reshape(typecast(samples, 'uint32'), nsampline, nlines);
    samples = [swapbytes([sampinfo.rsfv; sampinfo.rslv]); samples];
    
    % main write - byte swapping done
    fwrite(fido, samples, 'uint32');
    
    unread = unread - nlines - 4;
end

fclose(fid);
fclose(fido);

end
