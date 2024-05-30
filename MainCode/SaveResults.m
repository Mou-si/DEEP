function [PolynyaLoc, IDseries] = ...
    SaveResults(TimeYear, In, IDSeriesYear, AllIndexYear, CoastalPolynyas)
IDseries = zeros(size(IDSeriesYear, 2), 1);
PolynyaLoc = cell(size(IDSeriesYear, 2), 2);
for yeari = 1 : size(TimeYear, 2)
    if str2double(datestr(In.TimeTotal(TimeYear(2, yeari)), 'mmdd')) <= ...
            str2double(In.NewYear([1 : 2, 4 : 5]))
        disp(['[', datestr(now), ']   Saving ', ...
            num2str(year(In.TimeTotal(TimeYear(2, yeari)))-1), '...'])
        load([In.Cache, '\AAPSCacheforYear', ...
            num2str(year(In.TimeTotal(TimeYear(2, yeari)))-1), '.mat'])
    else
        disp(['[', datestr(now), ']   Saving ', ...
            num2str(year(In.TimeTotal(TimeYear(2, yeari)))), '...'])
        load([In.Cache, '\AAPSCacheforYear', ...
            num2str(year(In.TimeTotal(TimeYear(2, yeari)))), '.mat'])
    end
    
    PolynyaUsed = false(size(OpenWaterCurrent));
    DayBeforePolynya = [];
    OverwriteFlag = false;
    for dayi = 1 : size(OpenWaterCurrent, 1)
        Time = In.TimeTotal(TimeYear(1, yeari) + dayi - 1);
        PolynyaIDMap = zeros(size(In.SICFile.LandMask));
        PolynyaIDMap(logical(In.SICFile.LandMask)) = NaN;
        PolynyaIDOverlapLoc = [];
        CoastalPolynyasforDay = zeros(size(IDSeriesYear, 2), 2);
        for i = 1 : size(IDSeriesYear, 2)
            if isempty(IDSeriesYear{i})
                continue
            end
            MachineIDYear = IDSeriesYear{i}(yeari, :);
            MachineIDYear = unique(MachineIDYear);
            for j = 1 : length(MachineIDYear)
                if isnan(MachineIDYear(j))
                    continue
                end
                MachineID = LogIncludePhy.MachineID...
                    {LogIncludePhy.ManualID == IDYeartoCrossYear.Give...
                    (IDYeartoCrossYear.Get == MachineIDYear(j))};
                for k = 1 : length(MachineID)
                    if isempty(OpenWaterCurrent{dayi, MachineID(k)})
                        continue
                    end
                    if IDseries(i) == 0
                        IDTime = mod(str2double(datestr(Time, 'yyyy')), 100);
                        IDLon = round(In.SICLon(OpenWaterCurrent{dayi, MachineID(k)}(1)) .* 10);
                        IDLat = round(-In.SICLat(OpenWaterCurrent{dayi, MachineID(k)}(1)));
                        IDseriestemp = ...
                            double(IDTime * 1000000 + IDLon * 100 + IDLat);
                        if ismember(IDseriestemp, floor(IDseries ./ 10))
                            RepeatIDCount = ...
                                sum(ismember(floor(IDseries ./ 10), IDseriestemp));
                            IDseries(i) = IDseriestemp .* 10 + RepeatIDCount * 2;
                        else
                            IDseries(i) = IDseriestemp .* 10;
                        end
                        if ~ismember(i, CoastalPolynyas)
                            IDseries(i) = IDseries(i) + 1;
                        end
                        AllIndexYear(AllIndexYear == i) = IDseries(i);
                    end
                    if PolynyaUsed(dayi, MachineID(k))
                        IDs = ...
                            [unique(PolynyaIDMap(OpenWaterCurrent{dayi, MachineID(k)})); ...
                            IDseries(i)];
                    end
                    if PolynyaUsed(dayi, MachineID(k)) && any(diff(IDs) ~= 0)
                        PartedPolynyaID = VisualPartition ...
                            (DayBeforePolynya, AllIndexYear, ...
                            OpenWaterCurrent{dayi, MachineID(k)}, IDs);
                        PolynyaIDMap(PartedPolynyaID(1, :)) = ...
                            PartedPolynyaID(2, :);
                        if length(IDs) < size(PolynyaIDOverlapLoc, 2) && ...
                                ~isempty(PolynyaIDOverlapLoc)
                            IDs = ...
                                [IDs; nan(size(PolynyaIDOverlapLoc, 2) - length(IDs), 1)];
                        else
                            PolynyaIDOverlapLoc = ...
                                [PolynyaIDOverlapLoc, ...
                                nan(size(PolynyaIDOverlapLoc, 1), ...
                                length(IDs) - size(PolynyaIDOverlapLoc, 2))];
                        end
                        PolynyaIDOverlapLoc = ...
                            [PolynyaIDOverlapLoc; IDs'];
                    else
                        PolynyaUsed(dayi, MachineID(k)) = true;
                        PolynyaIDMap(OpenWaterCurrent{dayi, MachineID(k)}) = ...
                            IDseries(i);
                    end
                    if CoastalPolynyasforDay(i, 1) == 0
                        CoastalPolynyasforDay(i, 1) = IDseries(i);
                    end
                end
            end
        end
        
        % save polynya locations
        for i = 1 : size(IDseries, 1)
            if CoastalPolynyasforDay(i, 1) == 0
                continue
            end
            PolynyaLoc{i, 1} = ...
                [PolynyaLoc{i, 1}; find(PolynyaIDMap == IDseries(i))];
            PolynyaLoc{i, 2} = [PolynyaLoc{i, 2}, dayi];
        end
        
        CoastalPolynyasforDay(CoastalPolynyas, 2) = 1;
        CoastalPolynyasforDay(CoastalPolynyasforDay(:, 1) == 0, :) = [];
        if isempty(PolynyaIDOverlapLoc)
            PolynyaIDOverlapLoc = [NaN, NaN];
        else
            [~, tempLoc] = ismember(PolynyaIDOverlapLoc(:, 1), CoastalPolynyasforDay(:, 1));
            PolynyaIDOverlapLoc(:, 1) = tempLoc;
        end
        if isempty(CoastalPolynyasforDay)
            CoastalPolynyasforDay = [NaN, NaN];
        end
        OverwriteFlag = ...
            SaveResultstoNC(In, Time, PolynyaIDMap, ...
            CoastalPolynyasforDay, PolynyaIDOverlapLoc, OverwriteFlag);
        DayBeforePolynya = PolynyaIDMap;
    end
end

% lon-lat
SaveLonLat(In);

end

function OverwriteFlag = ...
    SaveResultstoNC(In, Time, PolynyaIDMap, ...
    CoastalPolynyasforDay, PolynyaIDOverlapLoc, OverwriteFlag)
FileFullName = [In.Save.Path, '/', ...
    In.Save.FileName1, datestr(Time, 'yyyymmdd'), In.Save.FileName2];
Descriptions = fileread('SaveDescription');
startIndex = regexp(Descriptions,'/%END_LINE%/');
Descriptions = {Descriptions(1 : startIndex(1) - 1); ...
    Descriptions(startIndex(1) + 14 : startIndex(2) - 1); ...
    Descriptions(startIndex(2) + 14 : startIndex(3) - 1); ...
    Descriptions(startIndex(3) + 14 : startIndex(4) - 1); ...
    Descriptions(startIndex(4) + 14 : startIndex(5) - 1); ...
    Descriptions(startIndex(5) + 14 : startIndex(6) - 1); ...
    Descriptions(startIndex(6) + 14 : end - 12)};
%% create var
% Schema.Name = '/';
% Schema.Format = 'classic';
% Schema.Dimensions(1).Name = 'x';
% Schema.Dimensions(1).Length = size(PolynyaIndex, 1);
% Schema.Dimensions(2).Name = 'y';
% Schema.Dimensions(2).Length = size(PolynyaIndex, 2);
% Schema.Dimensions(3).Name = 'time';
% Schema.Dimensions(3).Length = 1;
% Schema.Variables(1).Name = 'x';
% Schema.Variables(1).Length = 1;
try
    nccreate(FileFullName, 'time');
    catch NCCreateError
    if strcmp(NCCreateError.identifier, ...
            'MATLAB:imagesci:netcdf:unableToOpenforWrite')
        rethrow(NCCreateError)
    elseif strcmp(NCCreateError.identifier, ...
            'MATLAB:imagesci:netcdf:variableExists')
        if ~OverwriteFlag
            warning('The old data in the file will be <strong>OVERWRITTEN</strong>')
            OverwriteFlag = true;
        end
        delete(FileFullName)
        nccreate(FileFullName, 'time');
    else
        disp(['<strong>UNKNOW ERROR: </strong>', NCCreateError.message]);
        disp(NCCreateError.stack)
    end
end
try
    fileattrib(FileFullName, '+w')
    ncwriteatt(FileFullName, '/', ...
        'Introduction', Descriptions{1})
    ncwriteatt(FileFullName, '/', ...
        'Codes', Descriptions{2})
    ncwriteatt(FileFullName, '/', ...
        'Grids', Descriptions{3})
end
try
    nccreate(FileFullName, 'x', ...
        'Datatype', 'int16', ...
        'Dimensions', {'x', size(PolynyaIDMap, 1)});
end
try
    nccreate(FileFullName, 'y', ...
        'Datatype', 'int16', ...
        'Dimensions', {'y', size(PolynyaIDMap, 2)});
end
try
    nccreate(FileFullName, 'PolynyaIDMap', ...
        'Dimensions', {'x', size(PolynyaIDMap, 1), 'y', size(PolynyaIDMap, 2)}, ...
        'Datatype', 'int32', ...
        'FillValue', int32(-999), ...
        'DeflateLevel', 5);
    ncwriteatt(FileFullName, 'PolynyaIDMap', ...
        'LongName', 'Map of daily edge of each polynya')
    ncwriteatt(FileFullName, 'PolynyaIDMap', ...
        'Description', Descriptions{4})
end
try
    nccreate(FileFullName, 'PolynyaIDs', ...
        'Datatype', 'int32', ...
        'Dimensions', {'PolynyaIDs', size(CoastalPolynyasforDay, 1)});
    ncwriteatt(FileFullName, 'PolynyaIDs', ...
        'LongName', 'List of polynya IDs')
    ncwriteatt(FileFullName, 'PolynyaIDs', ...
        'Description', Descriptions{5})
end
try
    nccreate(FileFullName, 'CoastalPolynyaFlag', ...
        'Dimensions', {'PolynyaIDs', size(CoastalPolynyasforDay, 1)}, ...
        'Datatype', 'int8', ...
        'DeflateLevel', 5);
    ncwriteatt(FileFullName, 'CoastalPolynyaFlag', ...
        'LongName', 'Coastal/open-ocean polynyas flags')
    ncwriteatt(FileFullName, 'CoastalPolynyaFlag', ...
        'Description', Descriptions{6})
end
try
    nccreate(FileFullName, 'PolynyaTouch', ...
        'Dimensions', {'r', Inf, 'c', size(PolynyaIDOverlapLoc, 2)},...
        'Datatype', 'int32', ...
        'FillValue', int32(-999), ...
        'DeflateLevel', 5);
    ncwriteatt(FileFullName, 'PolynyaTouch', ...
        'LongName', 'Connected polynya IDs')
    ncwriteatt(FileFullName, 'PolynyaTouch', ...
        'Description', Descriptions{7})
end
%% write var
ncwrite(FileFullName, 'time', datenum(Time));
ncwrite(FileFullName, 'x', 1 : size(PolynyaIDMap, 1));
ncwrite(FileFullName, 'y', 1 : size(PolynyaIDMap, 2));
ncwrite(FileFullName, 'PolynyaIDMap', PolynyaIDMap);
ncwrite(FileFullName, 'PolynyaIDs', CoastalPolynyasforDay(:, 1));
ncwrite(FileFullName, 'CoastalPolynyaFlag', CoastalPolynyasforDay(:, 2));
ncwrite(FileFullName, 'PolynyaTouch', PolynyaIDOverlapLoc);
% disp(['[', datestr(now), ']   ', FileFullName, ' Done.'])
end

function PartedPolynyaID = ...
    VisualPartition(DayBeforePolynya, AllIndexYear, ToBePartedRegion, IDs)
persistent AllIndexYearSparse
if isempty(AllIndexYearSparse)
    AllIndexYearSparse = sparse(AllIndexYear);
end
AllIndexInsteadFlag = false;
% for the first day of year, use AllIndexYear instead of DayBeforePolynya
if isempty(DayBeforePolynya)
    DayBeforePolynya = AllIndexYear;
    AllIndexInsteadFlag = true;
end
%% mark (un)covered region
CoveredRegion = DayBeforePolynya(ToBePartedRegion);
[CoveredRegion, LocIDs] = ismember(CoveredRegion, IDs);
if max(LocIDs) < length(IDs)
    DayBeforePolynya = AllIndexYear;
    AllIndexInsteadFlag = true;
    CoveredRegion = DayBeforePolynya(ToBePartedRegion);
    CoveredRegion = ismember(CoveredRegion, IDs);
end
% PartedPolynyaID: 1st row: Location;
%                  2nd row: ID.
PartedPolynyaID = [(ToBePartedRegion(CoveredRegion))'; ...
    (DayBeforePolynya(ToBePartedRegion(CoveredRegion)))'];
UnCoveredRegion = ToBePartedRegion(~CoveredRegion);
if isempty(UnCoveredRegion)
    return
end
%% get the min box for uncovered region
% MinBoxLim of UnCoveredRegion: 
% [min rows NO., max rows NO., min columns NO., min columns NO.]
MinBoxLim = [min(mod(UnCoveredRegion - 0.5, size(DayBeforePolynya, 1))) + 0.5, ...
    max(mod(UnCoveredRegion - 0.5, size(DayBeforePolynya, 1))) + 0.5, ...
    min(ceil(UnCoveredRegion ./ size(DayBeforePolynya, 1))), ...
    max(ceil(UnCoveredRegion ./ size(DayBeforePolynya, 1)))];
if AllIndexInsteadFlag
    for i = 1 : length(IDs)
        [r, c] = find(AllIndexYear == IDs(i));
        MinBoxAllIndexLim(i, :) = [max(r), min(r), max(c), min(c)];
    end
    MinBoxLim = [MinBoxLim; MinBoxAllIndexLim];
    MinBoxLim = [min(MinBoxLim(:, 1)), max(MinBoxLim(:, 2)), ...
        min(MinBoxLim(:, 3)), max(MinBoxLim(:, 4))];
end
%% calculate the distance between uncover pixels and each covered region
DayBeforePolynya(UnCoveredRegion) = Inf;
for i = 1 : length(IDs)
    MinBoxtemp = DayBeforePolynya(MinBoxLim(1) : MinBoxLim(2), ...
        MinBoxLim(3) : MinBoxLim(4));
    MinBox = MinBoxtemp == IDs(i);
    Dist(:, :, i) = bwdist(MinBox, 'cityblock');
end
%% Nearest partition
[~, PartedID] = min(Dist, [], 3);
PartedID = PartedID(MinBoxtemp == Inf);
PartedID = IDs(PartedID);
PartedPolynyaID = [PartedPolynyaID, [UnCoveredRegion'; PartedID']];
end

function SaveLonLat(In)
FileFullName = [In.Save.Path, '/', 'LonLat.nc'];
try
    nccreate(FileFullName, 'x', ...
        'Datatype', 'int16', ...
        'Dimensions', {'x', size(In.SICLon, 1)});
    catch NCCreateError
    if strcmp(NCCreateError.identifier, ...
            'MATLAB:imagesci:netcdf:unableToOpenforWrite')
        rethrow(NCCreateError)
    elseif strcmp(NCCreateError.identifier, ...
            'MATLAB:imagesci:netcdf:variableExists')
        nccreate([In.Save.Path, '/', In.Save.FileName1, 'lon-lat.nc'], 'x', ...
        'Datatype', 'int16', ...
        'Dimensions', {'x', size(In.SICLon, 1)});
    else
        disp(['<strong>UNKNOW ERROR: </strong>', NCCreateError.message]);
        disp(NCCreateError.stack)
    end
end
try
    nccreate(FileFullName, 'y', ...
        'Datatype', 'int16', ...
        'Dimensions', {'y', size(In.SICLon, 1)});
end
try
    nccreate(FileFullName, 'Lon', ...
        'Datatype', 'single', ...
        'Dimensions', {'x', 'y'}, ...
        'DeflateLevel', 5);
    ncwriteatt(FileFullName, 'Lon', 'LongName', 'Longitudes')
end
try
    nccreate(FileFullName, 'Lat', ...
        'Datatype', 'single', ...
        'Dimensions', {'x', 'y'}, ...
        'DeflateLevel', 5);
    ncwriteatt(FileFullName, 'Lat', 'LongName', 'Latitudes')
end

ncwrite(FileFullName, 'x', 1 : size(In.SICLon, 1));
ncwrite(FileFullName, 'y', 1 : size(In.SICLon, 2));
ncwrite(FileFullName, 'Lon', In.SICLon);
ncwrite(FileFullName, 'Lat', In.SICLat);
end