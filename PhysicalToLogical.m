function [AllIndex, MachineManualID, isOpenWaterCurrent] = ...
    PhysicalToLogical(MachineIDSeries, TotalLastOpen, isOpenWaterCurrent, SICLon, ...
    In_RebirthOverlapThres, In_SeriesLengthThres, In_TimeFilterAfter, ...
    In_CombineMergeThres, In_MinPolynyaArea)
%% Combine Merge/Apart polynya series
% If two open water series with same ID more than 30 days, then this two
% open water will be combined and considered as the same logical ID.
% Result: The combined MachineIDSeries
Result = CombineMergeApart(MachineIDSeries, TotalLastOpen, SICLon, In_CombineMergeThres);
%% Derive the index of long-lasting open water
% for i = 1 : length(Time)
%     load(StoragePath + datestr(Time(i), 'yyyymmdd') + "LastOpenWater.mat");
%     LastOpenID = 1 : max(LastOpen, [], 'all');
%     LastOpenIndex = cell(1, length(LastOpenID));
%     for k = 1 : length(LastOpenID)
%         LastOpenIndex{1, k} = find(LastOpen == LastOpenID(k));
%     end
%     TotalLastOpen(i, 1 : length(LastOpenID)) = LastOpenIndex;
% end

clearvars -except Result Time TotalLastOpen TotalLastOpen MergeLast ...
    SICLon SICLat In_RebirthOverlapThres In_SeriesLengthThres In_MinPolynyaArea ...
    In_TimeFilterAfter In_MinPolynyaArea isOpenWaterCurrent
%% Find the location of each logical ID open water
% Pick out the sharing physical ID open water within a logical ID, and find
% the pixel which the logical ID open water exist more than threshold days.
% If none of the exist day of pixel in the logical ID open water over the
% threshold, all of the pixel will be considered as the location of the
% logical ID open water.
LogiIndex = cell(length(Result), 2);
LogiIndexTime = zeros(size(Result, 2), 1);
for i = 1 : length(Result)
    TotalLogiLastOpen = Result{1, i};
%     LastOpenLength = zeros(1, size(TotalLogiLastOpen, 2));
%% Get the length of each physical ID open water
    LastOpenLength = sum(~isnan(TotalLogiLastOpen), 2);
%     for k = 1 : length(LastOpenLength)
%         LastOpenLength(k) = ...
%             length(TotalLogiLastOpen(~isnan(TotalLogiLastOpen(:, k)), k));
%     end
    LogiIndexTime(i) = length(nonzeros(LastOpenLength));
    MinLength = LogiIndexTime(i) * In_SeriesLengthThres; 
%     if min(LastOpenLength) <= 60
%         
%         % If the shortest series less than 60, the threshold days is set to 
%         % the half of the minimum days.
%     else
%         MinLength = 30;
%     end
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
%         [~, PhyMaxIndex] = max(TotalPhyCounts);
        if length(TotalPhyIDnum(TotalPhyCounts >= MinLength)) >= 1
            LogiIndex{i, 1} = TotalPhyIDnum(TotalPhyCounts >= MinLength);
            % Extract the pixel last over the threshold
%             LogiIndex{i, 2} = TotalPhyIDnum(PhyMaxIndex);
        else
            LogiIndex{i, 1} = TotalPhyIDnum;
%             LogiIndex{i, 2} = TotalPhyIDnum(PhyMaxIndex);
        end
    end
end

% SICLon1D = reshape(SICLon, 1, []);
AllIndexSize = [size(SICLon, 1), size(SICLon, 2)];
% [Result, LogiIndex, AllIndex, AllIndexTime] = Rebirth(AllIndexSize, ...
%     LogiIndex, Result, LogiIndexTime);
[Result, LogiIndex, ~] = Rebirth(AllIndexSize, ...
    flipud(LogiIndex), fliplr(Result), In_RebirthOverlapThres);
[Result, LogiIndex, AllIndex] = Rebirth(AllIndexSize, ...
    flipud(LogiIndex), fliplr(Result), In_RebirthOverlapThres);
% AllIndexTimeThreshold = zeros(size(AllIndexTime));
% for i = 1 : size(LogiIndex, 1)
%     if LogiIndexTime(i) == 0
%         continue
%     end
%     AllIndexTimeThresholdtemp = quantile(AllIndexTime(LogiIndex{i, 1}), 0.25);
%     AllIndexTimeThreshold(LogiIndex{i, 1}) = AllIndexTimeThresholdtemp;
% end

clearvars -except Result Time LogiIndex AllIndex MergeLast LogiIndexTime ...
    In_TimeFilterAfter isOpenWaterCurrent In_MinPolynyaArea
% %% Find which current open water overlap on over two logical ID open water
% for i = 1 : length(Time)
%     MergeLast{i} = Overlap(AllIndex, MergeLast{i});
% end
% 
% clearvars -except Result Time LogiIndex AllIndex MergeLast LogiIndexTime
% %% Find how many times two logical open water has been overlap by the same current open water
% % If a current open water overlap more than two logical open water, each 
% % two will be considered as a pair open water. If a pair open water occure
% % more than threshold times, this pair of open water will be combined. And
% % every pair open water with same open water will all combined together.
% TotalMergeID = zeros(length(Result));
% for i = 1 : length(Time)
%     if isfield(MergeLast{i}, 'Current')
% %         if i == 1 % Run for the first time
%             for k = 1 : size(MergeLast{i}, 2)
% %                 PartMergeID = MergeLast{i}(k).LongLast;
%                 % Each two logical open water overlap on the single current
%                 % water will be considered as a pair open water
%                 PartMergeID = nchoosek(MergeLast{i}(k).LongLast, 2);
%                 PartMergeID = PartMergeID(:, 1) + ...
%                     (PartMergeID(:, 2) - 1) .* size(TotalMergeID, 2);
%                 TotalMergeID(PartMergeID) = TotalMergeID(PartMergeID) + 1;
% %                 for j = 1 : length(PartMergeID) - 1
% %                     for l = j + 1 : length(PartMergeID)
% %                         TwoMergeID = sort([PartMergeID(j); PartMergeID(l)]);
% %                         TotalMergeID = [TotalMergeID [TwoMergeID; 1]];
% %                     end
% %                 end
%             end
% %         else
% %             for k = 1 : size(MergeLast{i}, 2)
% %                 PartMergeID = nchoosek(MergeLast{i}(k).LongLast, 2);
% %                 TotalMergeID(PartMergeID(:, 1), PartMergeID(:, 2)) = ...
% %                     TotalMergeID(PartMergeID(:, 1), PartMergeID(:, 2)) + 1;
% %                 PartMergeID = MergeLast{i}(k).LongLast;
% %                 % Each two logical open water overlap on the single current
% %                 % water will be considered as a pair open water.
% %                 TotalMergeID2 = [];
% %                 for j = 1 : length(PartMergeID) - 1
% %                     for l = j + 1 : length(PartMergeID)
% %                         TwoMergeID = sort([PartMergeID(j); PartMergeID(l)]);
% %                         flag = 0;
% %                         % Find wether this pair of open water exist before,
% %                         % if it has existed, add one existed day
% %                         for q = 1 : size(TotalMergeID, 2)
% %                             MergeDiff = TotalMergeID(1 : 2, q) - TwoMergeID;
% %                             if all(MergeDiff == 0)
% %                                 TotalMergeID(3, q) = TotalMergeID(3, q) + 1;
% %                                 flag = 1;
% %                                 break
% %                             end
% %                         end
% %                         % If this pair open water doesn't exist, it will be
% %                         % appended to the total pair open water series.
% %                         if flag == 0
% %                             TotalMergeID2 = [TotalMergeID2 [TwoMergeID; 1]];
% %                         end
% %                     end
% %                 end
% %                 TotalMergeID = [TotalMergeID TotalMergeID2];
% %             end
% %         end
%     end
% end
% [TotalMergeIDtemp1, TotalMergeIDtemp2] = find(TotalMergeID ~=0);
% TotalMergeID = [TotalMergeIDtemp1, TotalMergeIDtemp2, TotalMergeID(TotalMergeID ~=0)]';
% % Input the total pixels of each logical ID open water 
% for i = 1 : size(TotalMergeID, 2)
% %     TotalMergeID(4, i) = length(LogiIndex{TotalMergeID(1, i), 1});
% %     TotalMergeID(5, i) = length(LogiIndex{TotalMergeID(2, i), 1});
%     TotalMergeID(4, i) = LogiIndexTime(TotalMergeID(1, i));
%     TotalMergeID(5, i) = LogiIndexTime(TotalMergeID(2, i));
% end
% % Derive the minimum number of pixel of each pair of logical ID open water,
% % if the pixel less than 100, the threshold is set to 10 days. If the pixel
% % more than 500, the threshold is set to 50 days. If the pixel is 100 to
% % 500, the threshold is linear increase between 10 to 50 days.
% MinIDIndex = min(TotalMergeID(4 : 5, :)) .* 0.4;
% % MinIDIndex = (MinIDIndex - 30) ./ (200 - 30);
% % MinIDIndex(MinIDIndex < 0) = 0;
% % MinIDIndex(MinIDIndex > 1) = 1;
% % MinIDIndex = ceil(MinIDIndex .* 40 + 10);
% Index = TotalMergeID(3, :) - MinIDIndex >= 0; 
% TotalMergeID = TotalMergeID(1 : 2, Index);
% [~, Sq] = sort(TotalMergeID(1, :));
% TotalMergeID = TotalMergeID(:, Sq);
% MergeIDnum = unique(TotalMergeID);
% l = 1;
% % Combined all the pair open water with the same logical ID, e.g. three
% % pairs open water 122-132, 132-144, 122-155, they will be combined as the
% % same logical open water.
% TotalID = cell(1, 1);
% for i = 1 : length(MergeIDnum)
%     if length(find(TotalMergeID == MergeIDnum(i))) >= 1
%         NextID = MergeIDnum(i);
%         CurrentID = NextID;
%         PartID = NextID;
%         while ~isempty(CurrentID)
%             NextID = [];
%             for k = 1 : length(CurrentID)
%                 [Row, Col] = find(TotalMergeID == CurrentID(k));
%                 for j = 1 : length(Row)
%                     RowIndex = ones(2, 1);
%                     RowIndex(Row(j)) = 0;
%                     NextID = unique([NextID TotalMergeID(RowIndex == 1, Col)]);
%                     % The pair of same open water, the anothor open water
%                     % in this pair will be appended and to find wether
%                     % there is any other pair of open water can be combined
%                     % into this series.
%                 end
%                 TotalMergeID(:, Col) = nan;
%             end
%             CurrentID = NextID;
%             PartID = [PartID NextID];
%         end
%         TotalID{l} = unique(PartID);
%         l = l + 1;
%         TotalMergeID(:, isnan(TotalMergeID(1, :))) = []; 
%         % Delet the pair open water has been combined
%     end
% end
% 
% clearvars -except Result Time LogiIndex AllIndex MergeLast TotalID
% %% Plot the physical ID open water
% % SingleIndex = 1 : length(FinalResult);
% % LogIncludePhy = cell(1, 2);
% % l = 1;]
% for i = 1 : length(TotalID)
%     MergeID = TotalID{1, i};
% %     SingleIndex(SingleIndex == MergeID(1)) = [];
% %     TotalPhysicalID = nonzeros(unique(FinalResult{1, MergeID(1)}));
%     for k = 2 : length(MergeID)
%         AllIndex(AllIndex == MergeID(k)) = MergeID(1);
%         Result{MergeID(1)} = [Result{MergeID(1)}, Result{MergeID(k)}];
%         Result{MergeID(k)} = [];
% %         LogiIndex{MergeID(1), 1} = ...
% %             unique([LogiIndex{MergeID(1), 1}; LogiIndex{MergeID(k), 1}]);
% %         LogiIndex{MergeID(k), 1} = [];
% %         SingleIndex(SingleIndex == MergeID(k)) = [];
% %         TotalPhysicalID = [TotalPhysicalID; nonzeros(unique(FinalResult{1, MergeID(k)}))];
%     end
% %     LogIncludePhy{i, 1} = MergeID(1);
% %     LogIncludePhy{i, 2} = nonzeros(unique(TotalPhysicalID(~isnan(TotalPhysicalID))));
% %     l = l + 1;
% end
% 
% % for i = 1 : length(SingleIndex)
% %     if ~isempty(LogiIndex{SingleIndex(i), 2})
% %         TotalPhysicalID = nonzeros(unique(FinalResult{1, MergeID(k)}));
% %         LogIncludePhy{l, 1} = SingleIndex(i);
% %         LogIncludePhy{l, 2} = TotalPhysicalID(~isnan(TotalPhysicalID));
% %         l = l + 1;
% %     end
% % end
% % 
% % figure(1);
% % m_proj('azimuthal equal-area','latitude',-90,'radius',50,'rectbox','on');
% % m_grid('box','on','xaxislocation','top','xtick',[-180:30:180],'yticklabels',...
% %     [ ; ],'ytick',[-80 -70 -60],'linewi',1,'tickdir','out','FontSize',8,'FontName','times new roman');
% % m_coast('color','k');
% % hold on
% % SICLon1D = reshape(SICLon, 1, []);
% % SICLat1D = reshape(SICLat, 1, []);
% % 
% % AllIndex(AllIndex == 0) = nan;
% % m_pcolor(SICLon, SICLat, AllIndex);
% % for i = 1 : size(LogiIndex)
% %     if ~isempty(LogiIndex{i, 1})
% %         m_text(double(SICLon1D(LogiIndex{i, 2})), double(SICLat1D(LogiIndex{i, 2})), num2str(i), 'fontsize', 3);
% %         m_scatter(SICLon1D(LogiIndex{i, 2}), SICLat1D(LogiIndex{i, 2}), 1, 'r', 'filled');
% %     end
% % end
% % print(1, "PhysicalIDNewMergeFlexThre", '-dpng', '-r1000');
% % close(1)

isOpenWaterCurrent_2 = zeros(size(Result, 2), size(isOpenWaterCurrent, 1));
for i = 1 : size(Result, 2)
    if ~isempty(Result{i})
        if sum(sum(~isnan(Result{i}), 2) ~= 0) < (In_TimeFilterAfter * 0.7)
            Result{i} = [];
            AllIndex(AllIndex == i) = 0;
            continue
        elseif length(LogiIndex{i, 1}) < In_MinPolynyaArea
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

%% Subfunction Overlap
function [MergeLastOpen] = Overlap(IDLongLast, IDCurrent)
global IDCpacity
IDTotal = sparse(IDLongLast) + IDCurrent .* IDCpacity;
IDTotal = unique(IDTotal(:));
IDTotal(IDTotal < IDCpacity | mod(IDTotal, IDCpacity) == 0) = [];
IDTotalLong = mod(IDTotal, IDCpacity);
IDTotalCur = floor(IDTotal / IDCpacity);
IDTotalCurnum = unique(IDTotalCur);
MergeQuan = 1;
MergeLastOpen = struct([]);
for i = 1 : length(IDTotalCurnum)
    LongLastID = unique(IDTotalLong(IDTotalCur == IDTotalCurnum(i)));
    if length(LongLastID) >= 2
        MergeLastOpen(MergeQuan).Current = IDTotalCurnum(i);
        MergeLastOpen(MergeQuan).LongLast = LongLastID;
        MergeQuan = MergeQuan + 1;
    end
end
end