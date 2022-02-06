function Membership = ReadAndCut(Membership, TimeAdvance, Time, ...
        SICDir, SICFileName1, SICFileName2, LandMask, Lim, CircumPolar, MapRange)

% TimeAdvance should less than the length of time dim of DataAll
Dim3DataAll = size(Membership.Data, 3);
if TimeAdvance > Dim3DataAll
    TimeAdvance = Dim3DataAll;
end
% get new data order
if isempty(Membership.i)
    Membership.i = size(Membership.Data, 3) : -1 : 1;
else
    Membership.i = Membership.i + 1;
    Membership.i(Membership.i > length(Membership.i)) = 1;
end
% calculate
for j = TimeAdvance : -1 : 1
     SIC = ReadOneDay(Time, j, SICDir, SICFileName1, SICFileName2, LandMask);
     SIC = CutOpenSea(SIC, Lim, CircumPolar);
     temp = RemapMembership(SIC, MapRange);
     Membership.Data(:, :, j == Membership.i) = temp;
end
end

%% Read Data
function SIC = ReadOneDay(TimeEnd, j, ...
    SICDir, SICFileName1, SICFileName2, LandMask)
TimeEnd = TimeEnd(end - j + 1);
TimeStr = datestr(TimeEnd, 'yyyymmdd');
SIC = ...
    double(hdfread( ...
    fullfile(SICDir, [SICFileName1, TimeStr, SICFileName2]), ...
    'ASI Ice Concentration'));
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