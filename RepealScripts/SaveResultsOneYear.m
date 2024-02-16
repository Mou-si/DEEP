function SaveResultsOneYear(TimeYear, In, OneYearIDSeriesYear)
for yeari = 1 : size(TimeYear, 2)
    if str2double(datestr(In.TimeTotal(TimeYear(2, yeari)), 'mmdd')) <= ...
            str2double(In.NewYear([1 : 2, 4 : 5]))
        disp(['[', datestr(now), ']   Do ', ...
            num2str(year(In.TimeTotal(TimeYear(2, yeari)))-1), '...'])
        load([In.Cache, '\AAPSCacheforYear', ...
            num2str(year(In.TimeTotal(TimeYear(2, yeari)))-1), '.mat'])
    else
        disp(['[', datestr(now), ']   Do ', ...
            num2str(year(In.TimeTotal(TimeYear(2, yeari)))), '...'])
        load([In.Cache, '\AAPSCacheforYear', ...
            num2str(year(In.TimeTotal(TimeYear(2, yeari)))), '.mat'])
    end

    for dayi = 1 : size(OpenWaterCurrent, 1)
        Time = In.TimeTotal(TimeYear(1, yeari) + dayi - 1);
        PolynyaIDMap_1Y = zeros(size(In.SICFile.LandMask));
        PolynyaIDMap_1Y(logical(In.SICFile.LandMask)) = NaN;
        for i = 1 : size(OneYearIDSeriesYear, 2)
            if isempty(OneYearIDSeriesYear{i})
                continue
            end
            MachineIDYear = OneYearIDSeriesYear{i}(yeari, :);
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
                    PolynyaIDMap_1Y(OpenWaterCurrent{dayi, MachineID(k)}) = i;
                end
            end
        end
        SaveResultstoNC_OneYear(In, Time, PolynyaIDMap_1Y);
    end
end
end

function SaveResultstoNC_OneYear(In, Time, PolynyaIDMap_1Y)
FileFullName = [In.Save.Path, '/', ...
    In.Save.FileName1, datestr(Time, 'yyyymmdd'), In.Save.FileName2];
try
    nccreate(FileFullName, 'PolynyaIDMap_1y', ...
        'Dimensions', {'x', size(In.SICLon, 1), 'y', size(In.SICLon, 2)},...
        'Datatype', 'int16', ...
        'FillValue', int16(-999), ...
        'DeflateLevel', 5);
end
ncwrite(FileFullName, 'PolynyaIDMap_1y', PolynyaIDMap_1Y);
end