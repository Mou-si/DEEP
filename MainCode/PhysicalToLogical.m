function [AllIndex, MachineManualID, isOpenWaterCurrent] = ...
    PhysicalToLogical(MachineIDSeries, TotalLastOpen, isOpenWaterCurrent, SICLon, ...
    In_RebirthOverlapThres, In_SeriesLengthThres, In_TimeFilterAfter, ...
    In_CombineMergeThres, In_MinPolynyaArea)
%% Check the independentment of Merge/Apart polynya series (Step-3)
% If two open water series with same ID more than 30 days, then this two
% open water will be combined and considered as the same logical ID.
% Result: The combined MachineIDSeries

Result = CombineMergeApart(MachineIDSeries, TotalLastOpen, SICLon, In_CombineMergeThres);

clearvars -except Result Time TotalLastOpen TotalLastOpen MergeLast ...
    SICLon SICLat In_RebirthOverlapThres In_SeriesLengthThres In_MinPolynyaArea ...
    In_TimeFilterAfter In_MinPolynyaArea isOpenWaterCurrent

%% Get polynya typical area
% Pick out the sharing physical ID open water within a logical ID, and find
% the pixel which the logical ID open water exist more than threshold days.
% If none of the exist day of pixel in the logical ID open water over the
% threshold, all of the pixel will be considered as the location of the
% logical ID open water.

LogiIndex = cell(length(Result), 2);
LogiIndexTime = zeros(size(Result, 2), 1);
for i = 1 : length(Result)
    TotalLogiLastOpen = Result{1, i};
    
    %% Get the length of each physical ID open water
    
    LastOpenLength = sum(~isnan(TotalLogiLastOpen), 2);
    LogiIndexTime(i) = length(nonzeros(LastOpenLength));
    MinLength = LogiIndexTime(i) * In_SeriesLengthThres;
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
    
    %% Calculate the days of each pixel
    
    if ~isempty(TotalPhyID)
        [TotalPhyIDnum, ~, TotalPhyic] = unique(TotalPhyID);
        TotalPhyCounts = accumarray(TotalPhyic, 1);
        if length(TotalPhyCounts) <= 0
            Result{i} = [];
            LogiIndexTime(i) = 0;
            continue
        end
        if length(TotalPhyIDnum(TotalPhyCounts >= MinLength)) >= 1
            LogiIndex{i, 1} = TotalPhyIDnum(TotalPhyCounts >= MinLength);
            % Extract the pixel last over the threshold
        else
            LogiIndex{i, 1} = TotalPhyIDnum;
        end
    end
end

%% Rebirth (Part-3)
AllIndexSize = [size(SICLon, 1), size(SICLon, 2)];
[Result, LogiIndex, ~] = Rebirth(AllIndexSize, ...
    flipud(LogiIndex), fliplr(Result), In_RebirthOverlapThres);
[Result, LogiIndex, AllIndex] = Rebirth(AllIndexSize, ...
    flipud(LogiIndex), fliplr(Result), In_RebirthOverlapThres);

clearvars -except Result Time LogiIndex AllIndex MergeLast LogiIndexTime ...
    In_TimeFilterAfter isOpenWaterCurrent In_MinPolynyaArea

%% Select polynyas (Step-4)
isOpenWaterCurrent_2 = zeros(size(Result, 2), size(isOpenWaterCurrent, 1));
for i = 1 : size(Result, 2)
    if ~isempty(Result{i})
        if sum(sum(~isnan(Result{i}), 2) ~= 0) < (In_TimeFilterAfter * 0.7)
            % here is a relaxed threshold, so some shorter sequences will
            % also be temporarily retained. In the Step-5, we will check
            % the reappearance. If in the study period, there are more than
            % 2 years meet this threshold (i.e., > 20d), all them,
            % including these 'shorter sequences' will be retained. If not
            % all them will be deleted.
            Result{i} = [];
            AllIndex(AllIndex == i) = 0;
            continue
        elseif length(LogiIndex{i, 1}) < In_MinPolynyaArea % chech area
            Result{i} = [];
            AllIndex(AllIndex == i) = 0;
            continue
        end
        for j = 1 : size(Result{i}, 1)
            Result_ijtemp = Result{i}(j, :);
            Result_ijtemp = Result_ijtemp(~isnan(Result_ijtemp));
            if any(isOpenWaterCurrent(j, Result_ijtemp))
                isOpenWaterCurrent_2(i, j) = 1;
            end
        end
    end
end
isOpenWaterCurrent = isOpenWaterCurrent_2;
isOpenWaterCurrent = logical(isOpenWaterCurrent);

%% summary the result of link and select
j = 0;
for i = 1 : size(Result, 2)
    if ~isempty(Result{i})
        j = j + 1;
        MachineManualID.MachineID{j} = unique(Result{i}(:));
        MachineManualID.MachineID{j} = MachineManualID.MachineID{j}...
            (~isnan(MachineManualID.MachineID{j}));
        MachineManualID.ManualID(j) = i;
    end
end
end