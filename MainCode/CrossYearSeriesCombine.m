function [Result, AllIndex] = CrossYearSeriesCombine...
    (MachineIDSeries, TotalLastOpen, isOpenWaterCurrent, SICLon, ...
    In_RebirthOverlapThres, In_SeriesLengthThres, ...
    In_CombineMergeThres, In_LandMask, In_Resolution, In_TimeFilterAfter)

%% Check the independentment of Merge/Apart polynya series
MachineIDSeries(MachineIDSeries == 0) = NaN;
Result = CombineMergeApart(MachineIDSeries, TotalLastOpen, SICLon, In_CombineMergeThres);

%% Get typical polynyas area
% but yealr-scale (i.e., reappear). So ver's names are the same as what in
% Step-3, but their play diff roles.

LogiIndex = cell(length(Result), 1);
CoastalFlag = true(size(LogiIndex));
for i = 1 : length(Result)
    TotalLogiLastOpen = Result{1, i};
    
    %% Get the length of each physical ID open water
    LastOpenLength = sum(~isnan(TotalLogiLastOpen), 2);
    LogiIndexTime(i) = length(nonzeros(LastOpenLength));
    LogiLastOpennum = unique(nonzeros(TotalLogiLastOpen(~isnan(TotalLogiLastOpen))));
    
    %% If the logical ID open water more than one series, find the sharing ID
    if size(TotalLogiLastOpen, 2) >= 2
        LogiLastOpen = [];
        for k = 1 : length(LogiLastOpennum)
            [~, LogiLastCol] = find(TotalLogiLastOpen == LogiLastOpennum(k));
            if length(unique(LogiLastCol)) >= 2
                LogiLastOpen = [LogiLastOpen LogiLastOpennum(k)];
            end
        end
    else
        % If the logical ID open water only have one series, all the ID in
        % this series is considered as the sharing ID
        LogiLastOpen = LogiLastOpennum;
    end
    
    %% Extract the pixel of all the sharing ID
    TotalPhyID = [];
    for k = 1 : length(LogiLastOpen)
        [rowtemp, ~] = find(Result{i} == LogiLastOpen(k));
        rowtemp = rowtemp';
        for j = unique(rowtemp)
            TotalPhyID = [TotalPhyID; TotalLastOpen{j, LogiLastOpen(k)}];
        end
    end
    
    %% get typical polynya area
    if ~isempty(TotalPhyID)
        [TotalPhyIDnum, ~, TotalPhyic] = unique(TotalPhyID);
        TotalPhyCounts = accumarray(TotalPhyic, 1);
        MinLength = LogiIndexTime(i) * In_SeriesLengthThres .* 2;
        if length(TotalPhyIDnum(TotalPhyCounts >= MinLength)) >= 1
            LogiIndex{i, 1} = TotalPhyIDnum(TotalPhyCounts >= MinLength);
            % Extract the pixel last over the threshold
        else
            LogiIndex{i, 1} = TotalPhyIDnum;
        end
        if ~DetectCoastalPolynyas(TotalPhyIDnum, In_LandMask, In_Resolution)
            CoastalFlag(i) = false;
        end
    end
end

%% Rebirth
AllIndexSize = [size(SICLon, 1), size(SICLon, 2)];
RebirthOverlapThresCOO.Coastal = In_RebirthOverlapThres;
RebirthOverlapThresCOO.OpenOcean = 0.05;
RebirthOverlapThresCOO.CoastalFlag = flipud(CoastalFlag);
[Result, LogiIndex, ~] = Rebirth(AllIndexSize, flipud(LogiIndex), ...
    fliplr(Result), RebirthOverlapThresCOO);
RebirthOverlapThresCOO.CoastalFlag = CoastalFlag;
[Result, LogiIndex, ~] = Rebirth(AllIndexSize, flipud(LogiIndex), ...
    fliplr(Result), RebirthOverlapThresCOO);
RebirthOverlapThresCOO.CoastalFlag = flipud(CoastalFlag);
DilateMask = {ones(round(30 / In_Resolution) * 2 + 1), ...
    double(strel('disk', round(5 / In_Resolution)).Neighborhood)};
[Result, LogiIndex, AllIndex] = Rebirth(AllIndexSize, flipud(LogiIndex), ...
    fliplr(Result), RebirthOverlapThresCOO, 'dilate', DilateMask);

%% Select (reappear)
for i = 1 : length(Result)
    
    % some combined series loss their ID, so we need to change the polynya
    % series and maps
    if isempty(Result{i})
        continue
    end
    if length(nonzeros(sum(~isnan(Result{i}), 2))) <= 1
        temp = Result{i}(~isnan(Result{i}));
        Result{i} = [];
        AllIndex(AllIndex == i) = 0;
        LogiIndex{i} = [];
    end
    
    % check reappear
    isOpenWaterCurrent_temp = zeros(size(Result{i}, 1), 1);
    for j = 1 : size(Result{i}, 1)
        if all(isnan(Result{i}(j, :)))
            continue
        end
        Result_temp = Result{i}(j, :);
        Result_temp = Result_temp(~isnan(Result_temp));
        isOpenWaterCurrent_temp(j) = ...
            sum(double(any(isOpenWaterCurrent{j}(Result_temp, :), 1)));
        clear Result_temp
    end
    if sum(double(isOpenWaterCurrent_temp >= In_TimeFilterAfter)) < 2
        Result{i} = [];
        AllIndex(AllIndex == i) = 0;
        LogiIndex{i} = [];
    end
    clear isOpenWaterCurrent_temp
end
end