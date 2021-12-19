function [MapState, ReinState] = DetectMatchState(TotalLastOpenWater, Apart, ReinBook)
global IDCpacity
ApartID = [];
ReinBookID = [];
if ~isempty(Apart)
    for i = 1 : length(Apart)
        ApartID = [ApartID; Apart(i).after]; % Get apart after open water ID
    end
    MapState = cell(length(ApartID), 2);
else
    MapState = [];
end
if isfield(ReinBook, 'Get')
    if ~isempty(ReinBook.Get)
        ReinBookID = unique(ReinBook.Get); % Get reincarnation open water ID
        ReinState = cell(length(ReinBookID), 2);
    else
        ReinState = [];
    end
else
    ReinBook.Get = [];
    ReinState = [];
end
if ~isempty(Apart) || ~isempty(ReinBook.Get)
    TotalID = [ApartID; ReinBookID];
    NowOpenWater = TotalLastOpenWater(:, :, end);
    AllOpenWater = zeros(size(NowOpenWater)); % AllOpenWater only includes the ID of 
                                              % apart and reincarnation open water ID
    for i = 1 : length(TotalID)
        AllOpenWater(NowOpenWater == TotalID(i)) = TotalID(i);
    end
    TotalLastOpenWater(TotalLastOpenWater == 0) = nan;
    AllOpenWater(AllOpenWater == 0) = nan;
    TotalMaxLastID = [];
    for i = 1 : size(TotalLastOpenWater, 3) - 1
        % If an apart and reincranation ID overlap on open water before,
        % for example, an apart open water ID is 435, it overlap on 231,
        % and the overlap ID is 43500231
        OverlapID = ...
            TotalLastOpenWater(:, :, i) + AllOpenWater * IDCpacity;
        OverlapID = unique(OverlapID(~isnan(OverlapID)));
        OverlapIDNow = floor(OverlapID / IDCpacity); % Get all overlaped apart and reincranation ID
        OverlapIDNowNum = unique(OverlapIDNow);
        OverlapIDLast = mod(OverlapID, IDCpacity); % Get all ID overlaped by apart and reincranation ID
        for k = 1 : length(OverlapIDNowNum)
            % Find the mapping open water of every apart and reincranation ID
            PartOverlapIDLast = OverlapIDLast(OverlapIDNow == OverlapIDNowNum(k));
            TotalMaxLastID = ...
                [TotalMaxLastID; ...
                repmat(OverlapIDNowNum(k), length(PartOverlapIDLast), 1), ...
                PartOverlapIDLast];
            % First line is the ID of apart and reincranation open water, 
            % the second line is the mapping open water ID
        end
    end
    if ~isempty(ApartID)
        for i = 1 : length(ApartID)
            MapState(i, 1) = {ApartID(i)};
            MapState(i, 2) = {unique(TotalMaxLastID(TotalMaxLastID(:, 1) == ApartID(i), 2))};
            % Get the series of all mapping open water ID of each apart
            % open water
        end
    end
    if ~isempty(ReinBook)
        for i = 1 : length(ReinBookID)
            ReinState(i, 1) = {ReinBookID(i)};
            if isempty(TotalMaxLastID)
                ReinState(i, 2) = {[]};
            else
                ReinState(i, 2) = {unique(TotalMaxLastID(TotalMaxLastID(:, 1) == ReinBookID(i), 2))};
                % Get the series of all mapping open water ID of each
                % reincranation open water
            end
        end
    end
end
end