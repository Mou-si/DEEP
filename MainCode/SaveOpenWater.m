function SaveOpenWater(In_SICFile, In_TimeGap, In_Save, In_Lim, FastIceFlag, ...
    OverviewOverlap)
FileName = dir(fullfile(In_Save.Path, [In_Save.FileName1, '*', In_Save.FileName2]));
Yr = -1000;
Time_before = 0;
for i = 1 : length(FileName)
    
    Time = FileName(i, :).name(length(In_Save.FileName1) + 1 : ...
        end - length(In_Save.FileName2));
    Time = datetime(Time, 'InputFormat', 'yyyyMMdd');
    if str2double(datestr(Time, 'yyyy')) ~= Yr
        disp(['[', datestr(now), ']   Adding ', datestr(Time, 'yyyy'), '...'])
        Yr = str2double(datestr(Time, 'yyyy'));
    end
    
    % read map
    PolynyaIDMap = ncread(fullfile(In_Save.Path, FileName(i, :).name), 'PolynyaIDMap');
    IDs = ncread(fullfile(In_Save.Path, FileName(i, :).name), 'PolynyaIDs');
    
    % overview overlap revise
        % from SaveOverviewMap.m
    isOverviewOverlap = ismember(OverviewOverlap.Get, IDs);
    if any(isOverviewOverlap)
        OverviewOverlapGet_temp = OverviewOverlap.Get(isOverviewOverlap);
        OverviewOverlapGive_temp = OverviewOverlap.Give(isOverviewOverlap);
        for j = 1 : length(OverviewOverlapGet_temp)
            PolynyaIDMap(PolynyaIDMap == OverviewOverlapGet_temp(j)) = ...
                OverviewOverlapGive_temp(j);
            IDs(IDs == OverviewOverlapGet_temp(j)) = NaN;
        end
    end
    
    % open water
    SIC = ReadOneDay(Time, In_SICFile, In_TimeGap); % land mask
    if size(SIC, 1) == 1
        delete(fullfile(In_Save.Path, FileName(i, :).name))
        warning([datestr(Time), ' loss.'])
        continue
    end
    if FastIceFlag
        TimeAdvance = datenum(Time) - Time_before;
        SIC_FastIce = MaskFastIce(SIC, Time, TimeAdvance, 'NoMaskDisp', false); % fastice mask
    else
        SIC_FastIce = SIC;
    end
    OpenWater = SIC_FastIce <= In_Lim;
    
    % open sea
    OpenWater = OpenWater & ~(PolynyaIDMap > 100);
    OpenWaterlabel = bwlabel(OpenWater);
    Areatemp = regionprops(OpenWaterlabel, 'Area');
    Areatemp = cat(1, Areatemp.Area);
    Areatemp = find(Areatemp == max(Areatemp), 1);
    OpenWater = double(OpenWater);
    OpenWater(OpenWaterlabel == Areatemp) = 2;
    
    PolynyaIDMap = PolynyaIDMap - OpenWater;
    if FastIceFlag
        PolynyaIDMap(isnan(SIC_FastIce )) = -100;
    end
    PolynyaIDMap(isnan(SIC)) = NaN;
    ncwrite(fullfile(In_Save.Path, FileName(i, :).name), ...
        'PolynyaIDMap', PolynyaIDMap);
    ncwrite(fullfile(In_Save.Path, FileName(i, :).name), ...
        'PolynyaIDs', IDs);
    Time_before = datenum(Time);
end
end

%%
function SIC = ReadOneDay(Time, In_SICFile, In_TimeGap)

TimeStr = datestr(Time, 'yyyymmdd');
FileNameNo = 1;
if ~isempty(In_TimeGap)
    for i = 1 : length(In_TimeGap)
        if Time >= In_TimeGap(i)
            FileNameNo = i + 1;
            break
        end
    end
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
catch
    SIC = NaN;
end
SIC(logical(In_SICFile.LandMask)) = NaN;
end