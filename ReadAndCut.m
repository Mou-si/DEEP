function [Membership, LossSIC] = ReadAndCut(Membership, TimeAdvance, Time, ...
        LossSIC, SICDir, SICFileName1, SICFileName2, SICVarName, LandMask, ...
        Lim, CircumPolar, MapRange)

% TimeAdvance should less than the length of time dim of DataAll
Dim3DataAll = size(Membership.Data, 3);
if TimeAdvance > Dim3DataAll
    TimeAdvance = Dim3DataAll;
end
% get new data order
if isempty(Membership.i)
    Membership.i = size(Membership.Data, 3) : -1 : 1;
else
    Membership.i = Membership.i + TimeAdvance;
    Membership.i = mod(Membership.i - 0.5, length(Membership.i)) + 0.5;
end
% calculate
for j = TimeAdvance : -1 : 1
    [SIC, LossSIC] = ReadOneDay(Time, j, LossSIC, ...
        SICDir, SICFileName1, SICFileName2, SICVarName, LandMask);
    if LossSIC == 0
        SIC = CutOpenSea(SIC, Lim, CircumPolar);
        temp = RemapMembership(SIC, MapRange);
        Membership.Data(:, :, j == Membership.i) = temp;
    else
        temp = j - LossSIC;
        if temp <= 0
            temp = length(Membership.i) - temp;
        end
        Membership.Data(:, :, j == Membership.i) = ...
            Membership.Data(:, :, temp == Membership.i);
    end
end
end

%% Read Data
function [SIC, LossSIC] = ReadOneDay(TimeEnd, j, LossSIC, ...
    SICDir, SICFileName1, SICFileName2, SICVarName, LandMask)
TimeEnd = TimeEnd(end - j + 1);
TimeStr = datestr(TimeEnd, 'yyyymmdd');
try
    SIC = ...
        double(hdfread( ...
        fullfile(SICDir, [SICFileName1, TimeStr, SICFileName2]), ...
        SICVarName));
    LossSIC = 0;
catch
    LossSIC = LossSIC + 1;
    warning(['SIC File ''', ...
        fullfile(SICDir, [SICFileName1, TimeStr, SICFileName2]), ...
        ''' hasn''t be found.', newline, ...
        'The SIC file of ', datestr(TimeEnd), ' will be replaced by ', ...
        datestr(TimeEnd - days(LossSIC)), '.'])
    if LossSIC <= 3
        SIC = [];
        return
    else
        error('More than 3 consecutive SIC files were not found.')
    end
end
SIC(logical(LandMask)) = NaN;
end

%% Cut Open Sea
function SIC = CutOpenSea(SIC, Lim, CircumPolar)
% The largest open water must be open sea, and we use 100 to delete it and
% land
OpenWater = (SIC <= Lim);
OpenWater = bwlabel(OpenWater);
if CircumPolar
    Areatemp = 1;
else
    Areatemp = regionprops(OpenWater, 'Area');
    Areatemp = cat(1, Areatemp.Area);
    Areatemp = find(Areatemp == max(Areatemp), 1);
end
SIC(OpenWater == Areatemp) = 100;
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