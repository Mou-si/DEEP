function WarmSeasonMat = isWarmSeason(MachineIDSeries, HeatFluxMat)

global Heat_Threshold

WarmSeasonMat = nanmean(HeatFluxMat, 2) < Heat_Threshold;
WarmSeasonMat = repmat(WarmSeasonMat, 1, size(HeatFluxMat, 2));
WarmSeasonMat(isnan(HeatFluxMat)) = true;
WarmSeasonMat = WarmSeasonMat(1 : size(MachineIDSeries, 2), :);
