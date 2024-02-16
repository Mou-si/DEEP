function GreatTempeDiffMat = isGreatTempeDiff(MachineIDSeries, TempeDiffMat)

global T_DiffThreshold

GreatTempeDiffMat = nanmean(TempeDiffMat, 2) > T_DiffThreshold;
GreatTempeDiffMat(isnan(TempeDiffMat)) = true;
GreatTempeDiffMat = GreatTempeDiffMat(1 : size(MachineIDSeries, 2), :);