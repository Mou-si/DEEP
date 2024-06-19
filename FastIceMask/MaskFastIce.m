function SIC = MaskFastIce(SIC, Time, TimeAdvance, varargin)
% This function can only applied to Fraser's land fast ice mask.

global FastIce
persistent FastIceMask FastIceMaskDays NICFastIceFiles

NoMaskDisp = true;
for i = 1 : length(varargin)
    switch varargin{i}
        case 'NoMaskDisp'
            NoMaskDisp = varargin{i + 1};
    end
end

% now is belong to which landfast ice mask?
FastIceFileNo = (datenum(Time) <= FastIce.TimeCover(:, end)) & ...
    datenum(Time) >= FastIce.TimeCover(:, 1);
FastIceFileNo = find(FastIceFileNo, 1, 'first');
if isempty(FastIceFileNo) % not belongs to any landfast ice mask
    FastIceFileNo = 0;
end
    
switch FastIceFileNo
    % if there is at that time no fast ice mask, donot mask
    case 0
        if NoMaskDisp
            disp(['No land fast ice mask  ', datestr(Time), ...
                '  (fast ice mask cannot cover this time)'])
        end
        
        % read fast ice mask
    case 1 % Frase
        FastIceMaskDays = FastIceMaskDays + TimeAdvance;
        if isempty(FastIceMaskDays) || ...
                FastIceMaskDays > 16 || ...
                str2double(datestr(Time, 'dd')) == 1 || ...
                str2double(datestr(Time, 'dd')) == 16
            % mask should be changed evey 1st/16th pre month or if it
            % is used too long, it also should be changed
            if str2double(datestr(Time, 'dd')) < 16
                FastIceFileName = ...
                    [FastIce.Dir{1}, FastIce.Name1{1}, datestr(Time, 'yyyymm'), ...
                    '_1', FastIce.Name2{1}];
            else
                FastIceFileName = ...
                    [FastIce.Dir{1}, FastIce.Name1{1}, datestr(Time, 'yyyymm'), ...
                    '_2', FastIce.Name2{1}];
            end
            try
                FastIceMask = ncread(FastIceFileName, FastIce.VarName{1});
            catch
                % if cannot read FastIceMask, donot mask
                FastIceMask = false(size(SIC));
                if NoMaskDisp
                    warning(['Cannot find land fast ice mask unexpectedly', newline, ...
                        'Fast ice file: ', FastIceFileName, newline, ...
                        'Fast ice Varible Name: ', FastIce.VarName{1}])
                end
            end
            CheckParameters_FastIce
            FastIceMaskDays = 1;
            FastIceMask = FastIceMask == 1;
            SIC(FastIceMask) = NaN;
        else
            % if don't need to updat mask, use the old one
            SIC(FastIceMask) = NaN;
        end
    case 2 % NIC
        FastIceMaskDays = FastIceMaskDays + TimeAdvance;
        if isempty(FastIceMaskDays) || ...
                FastIceMaskDays > 7
            % The landfast ice mask should be changed every 7 days
            % Start to search fast ice file at FastIceFileSearchStart days ago
            FastIceFileSearchStart = 0; 
            % if the fastice mask is one week ago, read derictly
            if FastIceMaskDays == 8
                FastIceFileName = ...
                    [FastIce.Dir{2}, FastIce.Name1{2}, datestr(Time, 'yyyymm'), ...
                    FastIce.Name2{2}];
                try
                    FastIceMask = ncread(FastIceFileName, FastIce.VarName{2});
                    % negative FastIceFileSearchStart means don't need to seach anymore
                    FastIceFileSearchStart = -1; 
                catch
                    % if file to read the mask, search 1 day ago
                    FastIceFileSearchStart = 1;
                end
            end
            % if the fastice mask is more than one week ago or cannot
            % be found at today
            if FastIceFileSearchStart >= 0 || ...
                    FastIceMaskDays > 8 || ...
                    isempty(FastIceMaskDays)
                if isempty(NICFastIceFiles)
                    NICFastIceFiles = dir([FastIce.Dir{2}, FastIce.Name1{2}, ...
                            '*', FastIce.Name2{2}]);
                    NICFastIceFiles = cat(1, NICFastIceFiles.name);
                    NICFastIceFiles = str2double(string(NICFastIceFiles(:, 4 : end - 3)));
                end
                for i = FastIceFileSearchStart : 14
                    if ismember(str2double(datestr(Time - days(i), 'yyyymmdd')), ...
                            NICFastIceFiles)
                        FastIceFileName = ...
                            [FastIce.Dir{2}, FastIce.Name1{2}, ...
                            datestr(Time - days(i), 'yyyymmdd'), ...
                            FastIce.Name2{2}];
                        try
                            FastIceMask = ncread(FastIceFileName, FastIce.VarName{2});
                            FastIceFileSearchStart = -1;
                        end
                        continue
                    end
                end
            end
            % if cannot read FastIceMask and the last mask is more than 14d ago , donot mask
            if FastIceFileSearchStart > 15 && NoMaskDisp
                FastIceFileName = ...
                    [FastIce.Dir{2}, FastIce.Name1{2}, ...
                    datestr(Time - days(i), 'yyyymmdd'), ...
                    FastIce.Name2{2}];
                warning(['Cannot find land fast ice mask unexpectedly', newline, ...
                    'Fast ice file: ', FastIceFileName, newline, ...
                    'Fast ice Varible Name: ', FastIce.VarName{1}])
                FastIceMask = false(size(SIC));
            end
            CheckParameters_FastIce
            if FastIceFileSearchStart < 0
                FastIceMaskDays = 1;
            end
            FastIceMask = FastIceMask == 1;
            SIC(FastIceMask) = NaN;
        else
            % if don't need to updat mask, use the old one
            SIC(FastIceMask) = NaN;
        end
    otherwise
        warning('Unexpected landfast ice mask files. Update MaskFastIce.m to fit the files.')
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