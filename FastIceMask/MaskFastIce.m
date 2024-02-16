function SIC = MaskFastIce(SIC, Time, TimeAdvance, varargin)
% This function can only applied to Fraser's land fast ice mask.

global FastIce
persistent FastIceMask FastIceMaskDays

NoMaskDisp = true;
for i = 1 : length(varargin)
    switch varargin{i}
        case 'NoMaskDisp'
            NoMaskDisp = varargin{i + 1};
    end
end

if datenum(Time) > FastIce.TimeCover(2) || ...
        datenum(Time) < FastIce.TimeCover(1)
    % if there is at that time no fast ice mask, donot mask
    if NoMaskDisp
        disp(['No land fast ice mask  ', datestr(Time), ...
            '  (fast ice mask cannot cover this time)'])
    end
elseif isempty(FastIceMaskDays) || ...
        FastIceMaskDays > 16 || ...
        str2double(datestr(Time, 'dd')) == 1 || ...
        str2double(datestr(Time, 'dd')) == 16
    % mask should be changed evey 1st/16th pre month or if it is used too
    % long, it also should be changed
    if str2double(datestr(Time, 'dd')) < 16
        FastIceFileName = ...
            [FastIce.Dir, FastIce.Name1, datestr(Time, 'yyyymm'), '_1', FastIce.Name2];
    else
        FastIceFileName = ...
            [FastIce.Dir, FastIce.Name1, datestr(Time, 'yyyymm'), '_2', FastIce.Name2];
    end
    try
        FastIceMask = ncread(FastIceFileName, FastIce.VarName);
    catch
        % if cannot read FastIceMask, donot mask
        FastIceMask = false(size(SIC));
        if NoMaskDisp
            warning(['Cannot find land fast ice mask unexpectedly', newline, ...
                'Fast ice file: ', FastIceFileName, newline, ...
                'Fast ice Varible Name: ', FastIce.VarName])
        end
    end
    CheckParameters_FastIce
    FastIceMaskDays = 1;
    FastIceMask = FastIceMask == 1;
    SIC(FastIceMask) = NaN;
else
    FastIceMaskDays = FastIceMaskDays + TimeAdvance;
    SIC(FastIceMask) = NaN;
end

function CheckParameters_FastIce
InputFilesSize = [size(SIC, 1), size(SIC, 2); ...
    size(FastIceMask, 1), size(FastIceMask, 2)];
if any(~[diff(InputFilesSize(:, 1)) == 0, diff(InputFilesSize(:, 2)) == 0])
    FilesName = ["Input SIC/PSSM files"; "Fast ice mask"];
    InputFilesSizeTable = table(FilesName, InputFilesSize);
    warning('Sizes of input Fast ice Files are not consist.')
    disp(InputFilesSizeTable)
    pause(3)
end
end

end