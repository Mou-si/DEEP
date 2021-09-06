function Membership = ReadAndCut(TimeEnd, j, ...
    SICDir, SICFileName1, SICFileName2, Lim, MapRange)
%% -- Read Data
TimeEnd = TimeEnd(end - j + 1);
TimeStr = datestr(TimeEnd, 'yyyymmdd');
SIC = ...
    double(hdfread( ...
    fullfile(SICDir, [SICFileName1, TimeStr, SICFileName2]), ...
    'ASI Ice Concentration'));

%% -- Cut Open Sea
SIC = CutOpenSea(SIC, Lim);

%% -- Remapping membership
Membership = SIC ./ abs(diff(MapRange)) - ...
    min(MapRange) ./ abs(diff(MapRange));
Membership(Membership > 1) = 1;
Membership(Membership < 0) = 0;
Membership = 1 - Membership;
% look at this. Now, SIC is NOT SIC, if it is 1 ,it means it is open water,
% and 0 means full ice
end

function SIC = CutOpenSea(SIC, Lim)
% The largest open water must be open sea, and we use 100 to delete it and
% land
OpenWater = (SIC <= Lim);
OpenWater = bwlabel(OpenWater);
Areatemp = regionprops(OpenWater, 'Area');
Areatemp = cat(1, Areatemp.Area);
Areatemp = find(Areatemp == max(Areatemp), 1);
SIC(OpenWater == Areatemp) = 100;
SIC(isnan(SIC)) = 100;
end