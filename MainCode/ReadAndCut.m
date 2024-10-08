function [Membership, LossSIC] = ReadAndCut(Membership, TimeAdvance, Time, ...
        In_TimeGap, LossSIC, In_SICFile, In_Lim, In_MapRange, In_FastIceFlag)

% get new data order
if isempty(Membership.i)
    Membership.i = size(Membership.Data, 3) : -1 : 1;
else
    Membership.i = Membership.i + TimeAdvance;
    Membership.i = mod(Membership.i - 0.5, length(Membership.i)) + 0.5;
end
% calculate
for j = TimeAdvance : -1 : 1
    [SIC, LossSIC] = ReadOneDay(Time, j, LossSIC, In_SICFile, In_TimeGap);
    
    % land fast ice mask
    if In_FastIceFlag
        SIC = MaskFastIce(SIC, Time(end - j + 1), TimeAdvance);
    end
    
    if LossSIC == 0
        SIC = CutOpenSea(SIC, In_Lim);
        if diff(In_MapRange) > 0
            temp = RemapMembership(SIC, In_MapRange);
        else
            temp = SIC <= In_MapRange(1);
        end
        Membership.Data(:, :, j == Membership.i) = temp;
    else
        temp = j - LossSIC;
        if temp <= 0
            temp = length(Membership.i) + temp;
        end
        Membership.Data(:, :, j == Membership.i) = ...
            Membership.Data(:, :, temp == Membership.i);
    end
end
end

%% Read Data
function [SIC, LossSIC] = ReadOneDay(TimeEnd, j, LossSIC, In_SICFile, In_TimeGap)
TimeEnd = TimeEnd(end - j + 1);
TimeStr = datestr(TimeEnd, 'yyyymmdd');
FileNameNo = 1;
if ~isempty(In_TimeGap)
    FileNameNo = sum(double(TimeEnd >= In_TimeGap)) + 1;
end
try
    switch In_SICFile.Name2{FileNameNo}(end - 2 : end)
        case 'hdf'
            SIC = ...
                hdfread( ...
                fullfile(In_SICFile.Dir, ...
                [In_SICFile.Name1{FileNameNo}, TimeStr, In_SICFile.Name2{FileNameNo}]), ...
                In_SICFile.VarName);
        case '.nc'
            SIC = ...
                ncread( ...
                fullfile(In_SICFile.Dir, ...
                [In_SICFile.Name1{FileNameNo}, TimeStr, In_SICFile.Name2{FileNameNo}]), ...
                In_SICFile.VarName);
        case 'mat'
            SIC = ...
                load( ...
                fullfile(In_SICFile.Dir, ...
                [In_SICFile.Name1{FileNameNo}, TimeStr, In_SICFile.Name2{FileNameNo}]), ...
                In_SICFile.VarName);
            SIC = SIC.Polynya;
        otherwise
            error(['Unknow Input File Format.', newlines, ...
                'The Exist formats are .nc, .hdf, .mat (variable name should be ''Polynya'').'])
    end
    LossSIC = 0;
catch
    LossSIC = LossSIC + 1;
    warning(['SIC File ''', ...
        fullfile(In_SICFile.Dir, ...
        [In_SICFile.Name1{FileNameNo}, TimeStr, In_SICFile.Name2{FileNameNo}]), ...
        ''' hasn''t be found.', newline, ...
        'The SIC file of ', datestr(TimeEnd), ' will be replaced by ', ...
        datestr(TimeEnd - days(LossSIC)), '.'])
    if LossSIC <= 5
        SIC = [];
        return
    else
        error('More than 5 consecutive SIC files were not found.')
    end
end
SIC(logical(In_SICFile.LandMask)) = NaN;
end

%% Cut Open Sea
function SIC = CutOpenSea(SIC, Lim)
% The largest open water must be open sea, and we use 100 to delete it and
% land
OpenWater = (SIC <= Lim);
OpenWater2 = imclearborder(OpenWater);
SIC(xor(OpenWater, OpenWater2)) = 100;
SIC(isnan(SIC)) = 100;
end

%% Remapping membership
function Membership = RemapMembership(SIC, MapRange)
Membership = SIC ./ abs(diff(MapRange)) - ...
    min(MapRange) ./ abs(diff(MapRange));
Membership(Membership > 1) = 1;
Membership(Membership < 0) = 0;
Membership = 1 - Membership;
% look at this. Now, SIC is NOT SIC, if it is 1 ,it means it is open water,
% and 0 means full ice
end
