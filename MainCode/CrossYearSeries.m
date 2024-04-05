function [MachineIDSeries, TotalLastOpen, MaxOpenWater, TotalLastOpenWater, ...
    IDYeartoCrossYear, isOpenWaterCurrent] = ...
    CrossYearSeries(MaxOpenWater, AllIndex, TotalLastOpen,...
    TotalLastOpenWater, MachineIDSeries, isOpenWaterCurrent, ...
    In_CrossYearOverlapThres)
AllIndexRaw = AllIndex;
MaxOpenWater(1) = MaxOpenWater(2);
[AllIndexUnique, ~, ic] = unique(AllIndex);
AllIndexIDcounts = accumarray(ic,1);
AllIndexBefore = TotalLastOpenWater.Data(:, :, end);
[AllIndexBeforeUnique, ~, ic] = unique(AllIndexBefore);
AllIndexBeforeIDcounts = accumarray(ic,1);
AllIndexBeforeDel = [];
for i = 2 : length(AllIndexUnique)
    AllIndexUniqueLocation = find(AllIndex == AllIndexUnique(i));
    AllIndexBeforetemp = AllIndexBefore(AllIndexUniqueLocation);
    [AllIndexBeforetempUnique, ~, ic] = unique(AllIndexBeforetemp);
    AllIndexBeforetempIDcounts = accumarray(ic,1);
    if AllIndexBeforetempUnique(1) == 0
        AllIndexBeforetempUnique(1) = [];
        AllIndexBeforetempIDcounts(1) = [];
    end
    if isempty(AllIndexBeforetempUnique)
        continue
    end
    for j = 1 : length(AllIndexBeforetempUnique)
        AllIndexBeforeFlag = AllIndexBeforetempIDcounts(j) / ...
            AllIndexBeforeIDcounts(AllIndexBeforeUnique == AllIndexBeforetempUnique(j));
        if length(nonzeros(AllIndexBeforetemp)) < ...
                AllIndexIDcounts(i) * In_CrossYearOverlapThres && ...
                AllIndexBeforeFlag < In_CrossYearOverlapThres
            AllIndexBefore(AllIndexUniqueLocation(ic == j + 1)) = 0;
        end
    end
end
AllIndexBeforeUniqueNew = unique(AllIndexBefore);
if length(AllIndexBeforeUniqueNew) ~= length(AllIndexBeforeUnique)
    AllIndexBeforeDel = setdiff(AllIndexBeforeUnique, AllIndexBeforeUniqueNew);
else
    AllIndexBeforeDel = [];
end
[AllIndex, IDnumMatch, MaxOpenWater(2), IDnumBye] = ...
    OverlapDye(AllIndex, AllIndexBefore, 1, MaxOpenWater(1), ...
    'NotConnect');
IDnumBye.Death = sort([IDnumBye.Death; AllIndexBeforeDel]);
[~, IDYeartoCrossYear] = OverlapDye(AllIndex, AllIndexRaw);
LastOpenwaterSparse = sparse(AllIndex);
LastOpenIndex = cell(1, MaxOpenWater(2));
for k = 1 : MaxOpenWater(2)
    LastOpenIndex{1, k} = find(LastOpenwaterSparse == k);
end
TotalLastOpen(size(TotalLastOpen, 1) + 1, 1 : MaxOpenWater(2)) = LastOpenIndex;
[MergeIDnum, ApartIDnum] = ...
    MergeAndApart(IDnumMatch);
TotalLastOpenWater.i = [max(TotalLastOpenWater.i) + 1, TotalLastOpenWater.i];
TotalLastOpenWater.Data = cat(3, TotalLastOpenWater.Data, AllIndex);
[MapStateApart] = ... ,ReinState
    DetectMatchState(TotalLastOpenWater,ApartIDnum); % ,ReincarnationBooktemp
MachineIDSeries = [MachineIDSeries; MachineIDSeries(end, :)]; % Copy the ID of the last day
[MachineIDSeries, ~, ~] = ...
    ProcessSeries(MachineIDSeries, MergeIDnum, ApartIDnum, ...
    MapStateApart, MaxOpenWater, IDnumBye.Death, []);
isOpenWaterCurrent_2 = zeros(size(MachineIDSeries, 2), size(isOpenWaterCurrent, 2));
for i = 1 : size(IDYeartoCrossYear.Give, 1)
    isOpenWaterCurrent_2(IDYeartoCrossYear.Get(i), :) = ...
        isOpenWaterCurrent(IDYeartoCrossYear.Give(i), :);
end
isOpenWaterCurrent = isOpenWaterCurrent_2;
end