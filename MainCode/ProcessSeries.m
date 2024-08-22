%% ProcessSeries
% This function use the apart, merging, death, reincranation information 
% to connect all the physical ID into a series along the time, to show how 
% the ID of a open water change
function [Result, TotalDeathID, TotalAppend] = ProcessSeries(Result, Merge, Apart, MapStateApart, ...
    MaxOpenWater, Death, TotalDeathID)
% function [Result, TotalDeathID, TotalAppend] = ProcessSeries(Result, Merge, Apart, MapStateApart, ...
%     MaxOpenWater, Death, TotalDeathID, ReincarnationBook, ReinState)
TotalAppendFrom = [];
TotalAppendTo = [];

%% Merge State
% Find all the ID of merge before, all change the present day ID into the
% ID of merge after
if ~isempty(Merge)
    for k = 1 : length(Merge)
        MergeBefore = Merge(k).before;
        MergeAfter = Merge(k).after;
        Result(end, ismember(Result(end - 1, :), MergeBefore)) = ...
            MergeAfter;
    end
end

%% Apart State
% Find all the series before apart, and use the apart mapping state to
% confirm which the apart after open water connect to.
if ~isempty(Apart)
    ApartLastID = MapStateApart;
    for k = 1 : length(Apart)
        ApartAfter = Apart(k).after;
        ApartBefore = Apart(k).before;
        ApartCol = find(Result(end - 1, :) == ApartBefore);
        [ApartOrig, ApartAddi, AppendFrom] = ... % Match the apart open water to the best fit series
            ApartMatch(Result(1 : end - 1, ApartCol), ApartAfter, ApartLastID);
        TotalAppendFrom = [TotalAppendFrom ApartCol(AppendFrom)];
        TotalAppendTo = [TotalAppendTo size(Result, 2) + 1 : size(Result, 2) + size(ApartAddi, 2)];
        Result(:, ApartCol) = ApartOrig;
        Result = [Result ApartAddi];
    end
end

%% Death State
% If a open water die in the last step, open water ID in this step will be
% changed into nan, and its index will be record in the total death ID
if ~isempty(Death)
%     Death = intersect(Result(end - 1, :), Death);
    for k = 1 : length(Death)
        DeathIndex = find(Result(end - 1, :) == Death(k));
        TotalDeathID = [TotalDeathID; repmat(Death(k), ...
            length(DeathIndex), 1) DeathIndex'];
        % Total DeathID: first line is the death ID, the second
        % line is the index in the result of the death open water
    end
    Result(end, ismember(Result(end - 1, :), Death)) = nan;
end

%% New Born State
% If a ID is not formed by seperating, merging, reincranation, it will be
% considered as a new born open water append to the Result
TotalID = MaxOpenWater(1) + 1 : MaxOpenWater(2);
NewBornID = TotalID(~ismember(TotalID, Result(end, :)));
Result(end, end + 1 : end + length(NewBornID)) = NewBornID;

%% Append State
% Get the copied column index
TotalAppend = [TotalAppendFrom; TotalAppendTo];

end

%% Match the apart open water to the best fit series
function [ApartOrigNew, ApartAddi, AppendFrom] = ...
    ApartMatch(ApartOrig, ApartAfter, ApartLastID)
% This function is run in two steps: 
% First: go through all the series and find the best fit apart open water
% with maximum overlap previous open water.
% Second: if any open water is not considered as the best fit open water of
% any series, it will go through all the left open water to find the best
% fit series with maximum overlap pervious open water.

AfterFlag = zeros(1, length(ApartAfter)); % To record how many times a open water match to a series
ApartOrigNew = [];
ApartAddi = []; % If the number of apart open water is more than current series, it will
                % appended to the result by ApartAddi
AppendFrom = [];
for i = 1 : size(ApartOrig, 2)
    OrigNum = unique(ApartOrig(:, i)); % What ID a series content
    OverlapNum = [];
    for k = 1 : length(ApartAfter)
        LastSeries = ApartLastID{cell2mat(ApartLastID(1 : end, 1)) == ApartAfter(k), 2}; 
        % Get all the previous mapping open water of the apart open water
        OverlapNum(k) = length(nonzeros(ismember(OrigNum, LastSeries)));
        % Calculate how many open water is the same between the series and
        % the apart open water overlaped
    end
    [~, MaxNumIndex] = max(OverlapNum); 
    % Consider apart open water which has the maximum overlaped open water 
    % as the best fit open water to connect
    AfterFlag(MaxNumIndex) = AfterFlag(MaxNumIndex) + 1; 
    ApartOrigNew = [ApartOrigNew [ApartOrig(:, i); ApartAfter(MaxNumIndex)]];
    % Copy the series from the best fit series
end      
if any(AfterFlag == 0) % If any apart open water is not considered as the best
                       % fit open water, it will find the best fit series
                       % of the apart open water to avoid miss any
                       % potential situation
    ApartAfter = ApartAfter(AfterFlag == 0);
    for k = 1 : length(ApartAfter)
        LastSeries = ApartLastID{cell2mat(ApartLastID(1 : end, 1)) == ApartAfter(k), 2};
        % Get all the previous mapping open water of the apart open water
        OverlapNum = [];
        for i = 1 : size(ApartOrig, 2)
            OrigNum = unique(ApartOrig(:, i));
            OverlapNum(i) = length(nonzeros(ismember(OrigNum, LastSeries)));
        end
        [~, MaxNumIndex] = max(OverlapNum); % Find the maximun overlap quantity as the best fit series
        ApartAddi = [ApartAddi [ApartOrig(:, MaxNumIndex); ApartAfter(k)]];
        AppendFrom = [AppendFrom MaxNumIndex]; % Record which line is copied and append to the result
    end
end
end