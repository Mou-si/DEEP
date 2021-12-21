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
%%
save test14_finalnew Result FinalResult DeleteCol