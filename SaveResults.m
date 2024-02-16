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
                        if ~CoastalPolynyas
                            IDseries(i) = IDseries(i) + 1;
                        end
                        AllIndexYear(AllIndexYear == i) = IDseries(i);
                    end
                    if PolynyaUsed(dayi, MachineID(k))
                        IDs = ...
                            [unique(PolynyaIDMap(OpenWaterCurrent{dayi, MachineID(k)})); ...
                            IDseries(i)];
                        PartedPolynyaID = VisualPartition ...
                            (DayBeforePolynya, AllIndexYear, ...
                            OpenWaterCurrent{dayi, MachineID(k)}, IDs);
                        PolynyaIDMap(PartedPolynyaID(1, :)) = ...
                            PartedPolynyaID(2, :);
                        [PolynyaIDLocRow, PolynyaIDLocCol] = ...
                            ind2sub(size(PolynyaIDMap), ...
                            OpenWaterCurrent{dayi, MachineID(k)});
                        PolynyaIDLoctemp = ...
                            [repmat(IDseries(i), length(PolynyaIDLocRow), 1), ...
                            PolynyaIDLocRow, PolynyaIDLocCol];
                        PolynyaIDOverlapLoc = ...
                            [PolynyaIDOverlapLoc; PolynyaIDLoctemp];
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
            PolynyaIDOverlapLoc = [NaN, NaN, NaN];
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

end

function OverwriteFlag = ...
    SaveResultstoNC(In, Time, PolynyaIDMap, ...
    CoastalPolynyasforDay, PolynyaIDOverlapLoc, OverwriteFlag)
FileFullName = [In.Save.Path, '/', ...
    In.Save.FileName1, datestr(Time, 'yyyymmdd'), In.Save.FileName2];
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
end
try
    nccreate(FileFullName, 'PolynyaIDs', ...
        'Datatype', 'int32', ...
        'Dimensions', {'PolynyaIDs', size(CoastalPolynyasforDay, 1)});
end
try
    nccreate(FileFullName, 'CoastalPolynyaFlag', ...
        'Dimensions', {'PolynyaIDs', size(CoastalPolynyasforDay, 1)}, ...
        'Datatype', 'int8', ...
        'DeflateLevel', 5);
end
try
    nccreate(FileFullName, 'PolynyaIDOverlapLoc', ...
        'Dimensions', {'r', Inf, 'c', 3},...
        'Datatype', 'int16', ...
        'FillValue', int16(-999), ...
        'DeflateLevel', 5);
end
%% write var
ncwrite(FileFullName, 'time', datenum(Time));
ncwrite(FileFullName, 'x', 1 : size(PolynyaIDMap, 1));
ncwrite(FileFullName, 'y', 1 : size(PolynyaIDMap, 2));
ncwrite(FileFullName, 'PolynyaIDMap', PolynyaIDMap);
ncwrite(FileFullName, 'PolynyaIDs', CoastalPolynyasforDay(:, 1));
ncwrite(FileFullName, 'CoastalPolynyaFlag', CoastalPolynyasforDay(:, 2));
ncwrite(FileFullName, 'PolynyaIDOverlapLoc', PolynyaIDOverlapLoc);
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