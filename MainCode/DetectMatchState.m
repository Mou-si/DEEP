function [MapState] = DetectMatchState(TotalLastOpenWater, Apart)
global IDCpacity
ApartID = [];
if ~isempty(Apart)
    for i = 1 : length(Apart)
        ApartID = [ApartID; Apart(i).after]; % Get apart after open water ID
    end
    MapState = cell(length(ApartID), 2);
else
    MapState = [];
end
if ~isempty(Apart)
    TotalID = [ApartID];
    NowOpenWater = TotalLastOpenWater.Data(:, :, TotalLastOpenWater.i == 1);
    AllOpenWater = zeros(size(NowOpenWater)); % AllOpenWater only includes the ID of 
                                              % apart open water ID
    for i = 1 : length(TotalID)
        AllOpenWater(NowOpenWater == TotalID(i)) = TotalID(i);
    end
    TotalMaxLastID = [];
    for i = length(TotalLastOpenWater.i) : -1 : 2
        % If an apart and reincranation ID overlap on open water before,
        % for example, an apart open water ID is 435, it overlap on 231,
        % and the overlap ID is 43500231
        OverlapID = ...
            TotalLastOpenWater.Data(:, :, TotalLastOpenWater.i == i) + ...
            AllOpenWater * IDCpacity;
        OverlapID = unique(sparse(OverlapID));
        OverlapIDNow1 = floor(OverlapID / IDCpacity); % Get all overlaped apart ID
        OverlapIDLast1 = mod(OverlapID, IDCpacity); % Get all ID overlaped by apart ID
        OverlapIDNow = OverlapIDNow1(OverlapIDNow1 ~= 0 & OverlapIDLast1~= 0);
        OverlapIDLast = OverlapIDLast1(OverlapIDNow1 ~= 0 & OverlapIDLast1~= 0);
        OverlapIDNowNum = unique(OverlapIDNow);
        for k = 1 : length(OverlapIDNowNum)
            % Find the mapping open water of every apart ID
            PartOverlapIDLast = OverlapIDLast(OverlapIDNow == OverlapIDNowNum(k));
            TotalMaxLastID = ...
                [TotalMaxLastID; ...
                repmat(OverlapIDNowNum(k), length(PartOverlapIDLast), 1), ...
                PartOverlapIDLast];
            % First line is the ID of apart and open water, 
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
end
end