function TD2TSall(d)
%TD2TSALL converts TanDEM-X COS files to TerraSAR-X COS files
%   TD2TSall(D) takes a string D specifying a directory and finds every
%   .cos file in it or in subdirectories. It renames each of these files by
%   appending .orig and creates a new .cos file with the original name but
%   with the half-precision data samples converted to int16.

% Copyright 2014 David Young

cosfiles = allfiles(d, 'cos');

for i = 1:length(cosfiles)
    cosfile = cosfiles{i};
    fprintf('\nProcessing %s\n', cosfile);
    origfile = [cosfile '.orig'];
    tempfile = [cosfile, '.temp'];
    
    if exist(origfile, 'file')
        warning('.orig file already exists - skipping this file');
        continue;
    end
    
    try
        TanDEM2TerraSAR(cosfile, tempfile);
    catch ME
        if ~isempty(strfind(ME.identifier, ':TanDEM2TerraSAR:'))
            warning(['Conversion failed with message:\n    %s\n' ...
                '    - skipping this file'], ME.message);
            continue;
        else
            rethrow(ME);
        end
    end
    
    % Conversion successful - do renames
    [moved, msg] = movefile(cosfile, origfile);
    if ~moved
        warning(['rename of original failed with message:\n    %s\n' ...
            '    - converted file in %s'], msg, tempfile);
        continue;
    end
    fprintf('    Original file renamed as .cos.orig\n');

    [moved, msg] = movefile(tempfile, cosfile);
    if ~moved
        warning(['rename of converted failed with message:\n    %s\n' ...
            '    - converted file in %s'], msg, tempfile);
    end
    
    fprintf('    Completed - .cos file has converted data\n');
end

end
    
