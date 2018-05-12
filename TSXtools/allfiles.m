function f = allfiles(d, ext)
%ALLFILES returns all files below a directory with given extensions
%   LIST = ALLFILES(DIR, EXT) finds all the files in the directory DIR or
%   one of its subdirectories (defined recursively) with an extension in
%   the list EXT. DIR must be a string. EXT may be a string to specify a
%   single extension, or a cell array of strings. The leading '.' in the
%   extension is omitted. The result is a cell array of strings.
%
%   Example:
%       filenames = allfiles('.', {'m' 'asv'});
%   finds all the .m and .asv files in or below the current directory.
%
% Copyright David Young 2011

% concatenate array of extensions into regular expression
if ischar(ext)
    expr = regexptranslate('escape', ext);
else
    expr = regexptranslate('escape', ext{1});
    for i = 2:length(ext)
        expr = [expr '|' regexptranslate('escape', ext{i})];   %#ok<*AGROW>
    end
end
expr = ['\.(?:' expr ')$'];

f = allfiles_recurse(d, expr);

    function f = allfiles_recurse(d, expr)
        fs = dir(d);
        names = {fs.name};
        
        % find matching files
        fnames = names(~[fs.isdir]);
        found = regexpi(fnames, expr, 'once');
        ff = ~cellfun(@isempty, found);
        f = fnames(ff);
        f = cellfun(@(fname) fullfile(d, fname), f, ...
            'UniformOutput', false);
        
        % recurse into subdirectories
        subdirs = names([fs.isdir]);
        for s = 1:length(subdirs)
            subdir = subdirs{s};
            if ~strcmp(subdir, '.') && ~strcmp(subdir, '..')
                f = [f allfiles_recurse(fullfile(d, subdir), expr)];
            end
        end
    end

end
