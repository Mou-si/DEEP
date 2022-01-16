%% Load the original result
clear; clc;
load test16_Final.mat
%% Physical ID to Logical ID
ResultNew = Result;
DeleteCol = []; % Series with only one open water from birth to death
j = 1;
%% Get the series with only one open water from birth to death
for i = 1 : size(Result, 2)
    ResultCol = nonzeros(Result(:, i));
    ResultCol = ResultCol(~isnan(ResultCol));
    if ResultCol(end) - ResultCol(1) == 0
        FinalResult(j) = {Result(:, i)};
        j = j + 1;
        DeleteCol = [DeleteCol i];
    end
end
ResultNew(:, DeleteCol) = []; % Delete the column of single open water from the result
%% Detect which series should be combined
% If two open water series with same ID more than 30 days, then this two
% open water will be combined and considered as the same logical ID.
ResultNew(ResultNew == 0) = nan;
TimeThres = 30; % Combination time threshold
while ~isempty(ResultNew)
    TotalResult = ResultNew(:, 1);
    NextCol = ResultNew(:, 1);
    NextIndex = 1;
    ResultNew = ResultNew(:, 2 : end);
    flag = 0;
    while flag == 0
        CurrentCol = NextCol;
        NextCol = [];
        NextIndex = [];
        for i = 1 : size(CurrentCol, 2)
            for k = 1 : size(ResultNew, 2)
                ResultDiff = ResultNew(:, k) - CurrentCol(:, i);
                % If a open water last for less than 40 days, the overlap
                % time will be determined as the percentage of the overlap
                % time by shorter last time
                if length(ResultNew(~isnan(ResultNew(:, k)), k)) <= 40 || ...
                        length(CurrentCol(~isnan(CurrentCol(:, i)), i)) <= 40
                    if double(length(find(ResultDiff == 0))) / ...
                            min(length(ResultNew(~isnan(ResultNew(:, k)), k)), ...
                            length(CurrentCol(~isnan(CurrentCol(:, i)), i))) >= 0.5
                        NextCol = [NextCol ResultNew(:, k)]; 
                        % If any open water series meet the threshold, it
                        % will be saved, and use these series to find
                        % whether there is any other series in the result
                        % can meet the threshold
                        ResultNew(:, k) = nan;
                        NextIndex = [NextIndex k]; % Get the index of the series which has been matched
                    end
                else
                    if length(find(ResultDiff == 0)) > TimeThres
                        NextCol = [NextCol ResultNew(:, k)];
                        ResultNew(:, k) = nan;
                        NextIndex = [NextIndex k];
                    end
                end
            end
        end
        TotalResult = [TotalResult NextCol]; 
        if ~isempty(NextIndex)
            ResultNew(:, NextIndex) = []; % Delete the matched column
        else
            flag = 1; % When this is no more series can meet the threshold, break the loop
        end
    end
    FinalResult(j) = {TotalResult};
    j = j + 1;
end

save test16_Final Result FinalResult DeleteCol
%% Derive the index of long-lasting open water
Time = ... %The time you want to identify polynyas
    datetime('2017-05-01') : datetime('2017-09-30');
for i = 1 : length(Time)
    load(".\test16\"+datestr(Time(i), 'yyyymmdd')+"LastOpenWater.mat");
    LastOpenID = 1 : max(LastOpen, [], 'all');
    LastOpenIndex = cell(1, length(LastOpenID));
    for k = 1 : length(LastOpenID)
        LastOpenIndex{1, k} = find(LastOpen == LastOpenID(k));
    end
    TotalLastOpen(i, 1 : length(LastOpenID)) = LastOpenIndex;
end

save test16_TotalID.mat
%% Find the location of each logical ID open water
% Pick out the sharing physical ID open water within a logical ID, and find
% the pixel which the logical ID open water exist more than threshold days.
% If none of the exist day of pixel in the logical ID open water over the
% threshold, all of the pixel will be considered as the location the
% logical ID open water.
clear;clc;
load test16_Final.mat
load test16_TotalID.mat
LogiIndex = cell(length(FinalResult), 2);
for i = 1 : length(FinalResult)
    TotalLogiLastOpen = FinalResult{1, i};
    LastOpenLength = zeros(1, size(TotalLogiLastOpen, 2));
%% Get the length of each physical ID open water
    for k = 1 : length(LastOpenLength)
        LastOpenLength(k) = ...
            length(TotalLogiLastOpen(~isnan(TotalLogiLastOpen(:, k)), k));
    end
    if min(LastOpenLength) <= 60
        MinLength = min(LastOpenLength) * 0.5; 
        % If the shortest series less than 60, the threshold days is set to 
        % the half of the minimum days.
    else
        MinLength = 30;
    end
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
        for j = 1 : size(TotalLastOpen, 1)
            TotalPhyID = [TotalPhyID; TotalLastOpen{j, LogiLastOpen(k)}];
        end
    end
%% Calculate the days of each pixel
    if ~isempty(TotalPhyID)
        [TotalPhyIDnum, ~, TotalPhyic] = unique(TotalPhyID);
        TotalPhyCounts = accumarray(TotalPhyic, 1);
        [~, PhyMaxIndex] = max(TotalPhyCounts);
        if length(TotalPhyIDnum(TotalPhyCounts >= MinLength)) >= 1
            LogiIndex{i, 1} = TotalPhyIDnum(TotalPhyCounts >= MinLength);
            % Extract the pixel last over the threshold
            LogiIndex{i, 2} = TotalPhyIDnum(PhyMaxIndex);
        else
            LogiIndex{i, 1} = TotalPhyIDnum;
            LogiIndex{i, 2} = TotalPhyIDnum(PhyMaxIndex);
        end
    end
end

load s3125grid.mat
lon1 = reshape(lon, 1, []);
lat1 = reshape(lat, 1, []);
AllIndex = zeros(size(lon1));
for i = 1 : size(LogiIndex)
    if ~isempty(LogiIndex{i, 1})
    AllIndex(LogiIndex{i, 1}) = i; %Put all logical ID open water into an array
    end
end
AllIndex = reshape(AllIndex, size(lon));
save test16_PhyArea LogiIndex AllIndex
%% Find which current open water overlap on over two logical ID open water
clear; clc;
global IDCpacity
IDCpacity = ... It is a constant for OverlapDye.m. If it 
    10000;
load test16_PhyArea.mat
Time = ... %The time you want to identify polynyas
    datetime('2017-05-01') : datetime('2017-09-30');
MergeLast = cell(length(Time), 1);
for i = 1 : length(Time)
    load(".\test16\"+datestr(Time(i), 'yyyymmdd')+"OpenWater.mat");
    MergeLast{i} = Overlap(AllIndex, OpenWater);
end

save test16_MergeLast MergeLast
%% Find how many times two logical open water has been overlap by the same current open water
% If a current open water overlap more than two logical open water, each 
% two will be considered as a pair open water. If a pair open water occure
% more than threshold times, this pair of open water will be combined. And
% every pair open water with same open water will all combined together.
clear;clc;
load test16_MergeLast.mat
Time = ... %The time you want to identify polynyas
    datetime('2017-05-01') : datetime('2017-09-30');
TotalMergeID = [];
for i = 1 : length(Time)
    if isfield(MergeLast{i, 1}, 'Current')
        if isempty(TotalMergeID) % Run for the first time
            for k = 1 : size(MergeLast{i, 1}, 2)
                PartMergeID = MergeLast{i, 1}(k).LongLast;
                % Each two logical open water overlap on the single current
                % water will be considered as a pair open water
                for j = 1 : length(PartMergeID) - 1
                    for l = j + 1 : length(PartMergeID)
                        TwoMergeID = sort([PartMergeID(j); PartMergeID(l)]);
                        TotalMergeID = [TotalMergeID [TwoMergeID; 1]];
                    end
                end
            end
        else
            for k = 1 : size(MergeLast{i, 1}, 2)
                PartMergeID = MergeLast{i, 1}(k).LongLast;
                % Each two logical open water overlap on the single current
                % water will be considered as a pair open water.
                TotalMergeID2 = [];
                for j = 1 : length(PartMergeID) - 1
                    for l = j + 1 : length(PartMergeID)
                        TwoMergeID = sort([PartMergeID(j); PartMergeID(l)]);
                        flag = 0;
                        % Find wether this pair of open water exist before,
                        % if it has existed, add one existed day
                        for q = 1 : size(TotalMergeID, 2)
                            MergeDiff = TotalMergeID(1 : 2, q) - TwoMergeID;
                            if all(MergeDiff == 0)
                                TotalMergeID(3, q) = TotalMergeID(3, q) + 1;
                                flag = 1;
                                break
                            end
                        end
                        % If this pair open water doesn't exist, it will be
                        % appended to the total pair open water series.
                        if flag == 0
                            TotalMergeID2 = [TotalMergeID2 [TwoMergeID; 1]];
                        end
                    end
                end
                TotalMergeID = [TotalMergeID TotalMergeID2];
            end
        end
    end
end
% Select the pair open water repeat more than 20 times as they are the same
% logical ID open water
Index = find(TotalMergeID(3, :) >= 20); 
TotalMergeID = TotalMergeID(:, Index);
TotalMergeID = TotalMergeID(1 : 2, :);
[~, Sq] = sort(TotalMergeID(1, :));
TotalMergeID = TotalMergeID(:, Sq);
MergeIDnum = unique(TotalMergeID);
l = 1;
% Combined all the pair open water with the same logical ID, e.g. three
% pairs open water 122-132, 132-144, 122-155, they will be combined as the
% same logical open water.
for i = 1 : length(MergeIDnum)
    if length(find(TotalMergeID == MergeIDnum(i))) >= 1
        NextID = MergeIDnum(i);
        CurrentID = NextID;
        PartID = NextID;
        while ~isempty(CurrentID)
            NextID = [];
            for k = 1 : length(CurrentID)
                [Row, Col] = find(TotalMergeID == CurrentID(k));
                for j = 1 : length(Row)
                    RowIndex = ones(2, 1);
                    RowIndex(Row(j)) = 0;
                    NextID = unique([NextID TotalMergeID(RowIndex == 1, Col)]);
                    % The pair of same open water, the anothor open water
                    % in this pair will be appended and to find wether
                    % there is any other pair of open water can be combined
                    % into this series.
                end
                TotalMergeID(:, Col) = nan;
            end
            CurrentID = NextID;
            PartID = [PartID NextID];
        end
        TotalID{l} = unique(PartID);
        l = l + 1;
        TotalMergeID(:, isnan(TotalMergeID(1, :))) = []; 
        % Delet the pair open water has been combined
    end
end

save test16_MergeLast MergeLast TotalID
%% Plot the physical ID open water
clear; clc;
load test16_PhyArea.mat
load test16_MergeLast.mat
load s3125grid.mat
for i = 1 : length(TotalID)
    MergeID = TotalID{1, i};
    for k = 2 : length(MergeID)
        AllIndex(AllIndex == MergeID(k)) = MergeID(1);
        LogiIndex{MergeID(k), 1} = [];
    end
end
figure(1);
m_proj('azimuthal equal-area','latitude',-90,'radius',50,'rectbox','on');
m_grid('box','on','xaxislocation','top','xtick',[-180:30:180],'yticklabels',[ ; ],'ytick',[-80 -70 -60],'linewi',1,'tickdir','out','FontSize',8,'FontName','times new roman');
m_coast('color','k');
hold on
lon1 = reshape(lon, 1, []);
lat1 = reshape(lat, 1, []);

AllIndex(AllIndex == 0) = nan;
m_pcolor(lon,lat,AllIndex);
for i = 1 : size(LogiIndex)
    if ~isempty(LogiIndex{i, 1})
        m_text(double(lon1(LogiIndex{i, 2})),double(lat1(LogiIndex{i, 2})),num2str(i),'fontsize',3);
        m_scatter(lon1(LogiIndex{i, 2}),lat1(LogiIndex{i, 2}),1,'r','filled');
    end
end
print(1,"PhysicalIDNewMerge1",'-dpng','-r1000');
close(1)