function [Result, LogiIndex, AllIndex] = ...
    Rebirth(AllIndexSize, LogiIndex, ...
    Result, In_RebirthOverlapThres, varargin)
if isequal(class(In_RebirthOverlapThres), 'struct')
    In_RebirthOverlapThresOpenOcean = In_RebirthOverlapThres.OpenOcean;
    In_RebirthOverlapThresCoastal = In_RebirthOverlapThres.Coastal;
    CoastalFlag = In_RebirthOverlapThres.CoastalFlag;
end
AllIndex = zeros(AllIndexSize); % size((MergeLast{1}))
% AllIndexTime = zeros(AllIndexSize);
AllIndexCount = [];
dilate = false;
for i = 1 : length(varargin)
    if isequal(varargin{i}, 'dilate')
        dilate = true;
        DilateMask = varargin{i + 1};
    end
end
for i = 1 : size(LogiIndex)
    if ~isempty(LogiIndex{i, 1})
        if exist('CoastalFlag', 'var')
            if CoastalFlag(i)
                In_RebirthOverlapThres = In_RebirthOverlapThresCoastal;
            else
                In_RebirthOverlapThres = In_RebirthOverlapThresOpenOcean;
            end
        end
%         AllIndexTime(LogiIndex{i, 1}) = ...
%             AllIndexTime(LogiIndex{i, 1}) + LogiIndexTime(i);
        if dilate && exist('CoastalFlag', 'var')
            if ~CoastalFlag(i)
                LogiIndextemp = zeros(AllIndexSize);
                LogiIndextemp(LogiIndex{i, 1}) = 1;
                LogiIndextemp = imdilate(LogiIndextemp, ...
                    DilateMask{1});
                CoveredLogiID = AllIndex(logical(LogiIndextemp));
            elseif CoastalFlag(i) && length(DilateMask{2}) > 1
                LogiIndextemp = zeros(AllIndexSize);
                LogiIndextemp(LogiIndex{i, 1}) = 1;
                LogiIndextemp = imdilate(LogiIndextemp, ...
                    DilateMask{2});
                CoveredLogiID = AllIndex(logical(LogiIndextemp));
            else
                CoveredLogiID = AllIndex(LogiIndex{i, 1});
            end
        else
            CoveredLogiID = AllIndex(LogiIndex{i, 1});
        end
        CoveredLogiIDNew = ...
            sum(CoveredLogiID ~= 0) / length(CoveredLogiID);
        [CoveredLogiID, ~, ic] = unique(CoveredLogiID);
        CoveredLogiIDOldCount = accumarray(ic, 1);
        CoveredLogiIDOldCount(CoveredLogiID == 0) = [];
        CoveredLogiID(CoveredLogiID == 0) = [];
        if isempty(CoveredLogiID)
            AllIndex(LogiIndex{i, 1}) = i; % Put all logical ID open water into an array
            AllIndexCount(i) = length(LogiIndex{i, 1});
            continue
        end
        for j = 1 : length(CoveredLogiID)
            CoveredLogiIDOld(j) = ...
                CoveredLogiIDOldCount(j) / AllIndexCount(CoveredLogiID(j));
        end
        OverCoveredLogiIDOld = CoveredLogiID(CoveredLogiIDOld >= In_RebirthOverlapThres);
        if length(OverCoveredLogiIDOld) > 1
            for j = 2 : length(OverCoveredLogiIDOld)
                AllIndex(AllIndex == OverCoveredLogiIDOld(j)) = OverCoveredLogiIDOld(1);
%                 AllIndexCount(OverCoveredLogiIDOld(1)) = ...
%                     AllIndexCount(OverCoveredLogiIDOld(1)) + ...
%                     AllIndexCount(OverCoveredLogiIDOld(j));
                Result{OverCoveredLogiIDOld(1)} = [Result{OverCoveredLogiIDOld(1)}, ...
                    Result{OverCoveredLogiIDOld(j)}];
                Result{OverCoveredLogiIDOld(j)} = [];
                LogiIndex{OverCoveredLogiIDOld(1), 1} = [LogiIndex{OverCoveredLogiIDOld(1), 1}; ...
                    LogiIndex{OverCoveredLogiIDOld(j), 1}];
                LogiIndex{OverCoveredLogiIDOld(j), 1} = [];
                LogiIndex{OverCoveredLogiIDOld(1), 1} = unique(LogiIndex{OverCoveredLogiIDOld(1), 1});
                AllIndexCount(OverCoveredLogiIDOld(1)) = length(LogiIndex{OverCoveredLogiIDOld(1), 1});
                AllIndexCount(OverCoveredLogiIDOld(j)) = 0;
            end
        end
        if any(CoveredLogiIDOld >= In_RebirthOverlapThres)
            AllIndex(LogiIndex{i, 1}) = OverCoveredLogiIDOld(1);
%             AllIndexCount(OverCoveredLogiIDOld(1)) = ...
%                 AllIndexCount(OverCoveredLogiIDOld(1)) + ...
%                 length(LogiIndex{i, 1}) - ...
%                 sum(CoveredLogiIDOldCount(CoveredLogiIDOld >= 0.5));
            Result{OverCoveredLogiIDOld(1)} = [Result{OverCoveredLogiIDOld(1)}, ...
                Result{i}];
            Result{i} = [];
            LogiIndex{OverCoveredLogiIDOld(1), 1} = [LogiIndex{OverCoveredLogiIDOld(1), 1}; ...
                LogiIndex{i, 1}];
            LogiIndex{OverCoveredLogiIDOld(1), 1} = unique(LogiIndex{OverCoveredLogiIDOld(1), 1});
            AllIndexCount(OverCoveredLogiIDOld(1)) = length(LogiIndex{OverCoveredLogiIDOld(1), 1});
            LogiIndex{i, 1} = [];
        elseif CoveredLogiIDNew >= In_RebirthOverlapThres
            MaxCoveredLogiIDOld = ...
                CoveredLogiID(CoveredLogiIDOldCount == max(CoveredLogiIDOldCount));
            MaxCoveredLogiIDOld = MaxCoveredLogiIDOld(1);
            AllIndex(LogiIndex{i, 1}) = MaxCoveredLogiIDOld;
%             AllIndexCount(AllIndex(LogiIndex{i, 1}(1))) = ...
%                 AllIndexCount(AllIndex(LogiIndex{i, 1}(1))) + ...
%                 length(LogiIndex{i, 1}) * CoveredLogiIDNew - max(CoveredLogiIDOldCount);
            Result{MaxCoveredLogiIDOld} = ...
                [Result{MaxCoveredLogiIDOld}, Result{i}];
            Result{i} = [];
            LogiIndex{MaxCoveredLogiIDOld, 1} = ...
                [LogiIndex{MaxCoveredLogiIDOld, 1}; LogiIndex{i, 1}];
            LogiIndex{MaxCoveredLogiIDOld, 1} = unique(LogiIndex{MaxCoveredLogiIDOld, 1});
            AllIndexCount(MaxCoveredLogiIDOld) = length(LogiIndex{MaxCoveredLogiIDOld, 1});
            LogiIndex{i, 1} = [];
        else
            AllIndex(LogiIndex{i, 1}) = i;
            AllIndexCount(i) = length(LogiIndex{i, 1});
        end
        clear CoveredLogiIDOld
    end
end
% AllIndex = reshape(AllIndex, size(SICLon));
end