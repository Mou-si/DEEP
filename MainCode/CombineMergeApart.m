function [Result] = CombineMergeApart(MachineIDSeries, ...
    TotalLastOpen, SICLon, In_CombineMergeThres)
MachineIDSeriesNew = MachineIDSeries;
DeleteCol = []; % Series with only one open water from birth to death
j = 1;
%% Get the series with only one open water from birth to death
SingleOpenWaterID = [];
MachineIDPosition = zeros(size(MachineIDSeriesNew, 2), 1);
for i = 1 : size(MachineIDSeries, 2)
%     MachineIDSeriesCol = nonzeros(MachineIDSeries(:, i));
%     MachineIDSeriesCol = MachineIDSeriesCol(~isnan(MachineIDSeriesCol));
%     if isempty(MachineIDSeriesCol)
%         DeleteCol = [DeleteCol i];
%         continue
%     end
%     MachineIDSeries(cellfun(@isempty, TotalLastOpen(:, MachineIDSeriesCol(1))), i) = NaN;
    MachineIDSeriesCol = nonzeros(MachineIDSeries(:, i));
    MachineIDSeriesCol = MachineIDSeriesCol(~isnan(MachineIDSeriesCol));
    if isempty(MachineIDSeriesCol)
        DeleteCol = [DeleteCol i];
    else
        MachineIDPosition(i) = ...
            SICLon(TotalLastOpen{find(~isnan(MachineIDSeries(:, i)), 1), MachineIDSeriesCol(1)}(1));
        if MachineIDSeriesCol(end) - MachineIDSeriesCol(1) == 0
            if ~ismember(MachineIDSeriesCol(1), SingleOpenWaterID)
                MachineIDSeries(MachineIDSeries(:, i) == 0, i) = nan;
                Result(j) = {MachineIDSeries(:, i)};
                j = j + 1;
                SingleOpenWaterID = [SingleOpenWaterID; MachineIDSeriesCol(1)];
            end
            DeleteCol = [DeleteCol i];
        end
    end
end
MachineIDSeriesNew(:, DeleteCol) = []; % Delete the column of single open water from the result
MachineIDPosition(DeleteCol) = [];
%% Detect which series should be combined
% If two open water series with same ID more than 30 days, then this two
% open water will be combined and considered as the same logical ID.
MachineIDSeriesNew(MachineIDSeriesNew == 0) = nan;
TimeThres = In_CombineMergeThres * 60; % Combination time threshold
while ~isempty(MachineIDSeriesNew)
    TotalResult = MachineIDSeriesNew(:, 1);
    NextCol = MachineIDSeriesNew(:, 1);
    NextColPosition = MachineIDPosition(1);
    NextIndex = 1;
    MachineIDSeriesNew = MachineIDSeriesNew(:, 2 : end);
    MachineIDPosition = MachineIDPosition(2 : end);
    flag = 0;
    while flag == 0
        CurrentCol = NextCol;
        CurrentColPosition = NextColPosition;
        NextCol = [];
        NextColPosition = [];
        NextIndex = [];
        for i = 1 : size(CurrentCol, 2)
            PositionDiff = abs(MachineIDPosition - CurrentColPosition(i));
            PositionDiff(PositionDiff > 180) = 360 - PositionDiff(PositionDiff > 180);
            PositionDiff = find(PositionDiff < TimeThres);
            % TimeThres here means close in position
            for kk = 1 : length(PositionDiff)
                k = PositionDiff(kk);
                ResultDiff = MachineIDSeriesNew(:, k) - CurrentCol(:, i);
                % If a open water last for less than 40 days, the overlap
                % time will be determined as the percentage of the overlap
                % time by shorter last time
                if length(MachineIDSeriesNew(~isnan(MachineIDSeriesNew(:, k)), k)) <= 60 || ...
                        length(CurrentCol(~isnan(CurrentCol(:, i)), i)) <= 60
                    if double(length(find(ResultDiff == 0))) / ...
                            min(length(MachineIDSeriesNew(~isnan(MachineIDSeriesNew(:, k)), k)), ...
                            length(CurrentCol(~isnan(CurrentCol(:, i)), i))) >= In_CombineMergeThres
                        NextCol = [NextCol MachineIDSeriesNew(:, k)]; 
                        NextColPosition = [NextColPosition MachineIDPosition(k)];
                        % If any open water series meet the threshold, it
                        % will be saved, and use these series to find
                        % whether there is any other series in the result
                        % can meet the threshold
                        MachineIDSeriesNew(:, k) = nan;
                        MachineIDPosition(k) = nan;
                        NextIndex = [NextIndex k]; % Get the index of the series which has been matched
                    end
                else
                    if length(find(ResultDiff == 0)) > TimeThres
                        NextCol = [NextCol MachineIDSeriesNew(:, k)];
                        NextColPosition = [NextColPosition MachineIDPosition(k)];
                        MachineIDSeriesNew(:, k) = nan;
                        NextIndex = [NextIndex k];
                    end
                end
            end
        end
        TotalResult = [TotalResult NextCol]; 
        if ~isempty(NextIndex)
            MachineIDSeriesNew(:, NextIndex) = []; % Delete the matched column
            MachineIDPosition(NextIndex) = [];
        else
            flag = 1; % When this is no more series can meet the threshold, break the loop
        end
    end
    Result(j) = {TotalResult};
    j = j + 1;
end