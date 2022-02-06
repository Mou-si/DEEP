function WarmSeasonMat = isWarmSeason(Time, ...
    LastOpenWater, MachineIDList, SICLon, SICLat, ...
    Main_i, MachineIDSeries, HeatFluxMat)

global Heat_Threshold       Heat_MovingMeanDays     Heat_MovingMaxDays

Time = Time + days(1 : (Heat_MovingMeanDays - 1) / 2 + Heat_MovingMaxDays);
for i = 1 : length(Time)
    HeatFlux = HeatLoss(LastOpenWater, ...
        MachineIDList, SICLon, SICLat, Time(i));
    HeatFluxMat = HeatLossSeries...
        (Main_i, HeatFlux, MachineIDSeries, MachineIDList,...
        HeatFluxMat, []);
end
WarmSeasonMat = movmax(movmean(HeatFluxMat, 5, 2), 5, 2) < Heat_Threshold;
WarmSeasonMat = WarmSeasonMat(:, 3 : end - length(Time));
WarmSeasonMat = WarmSeasonMat(1 : size(MachineIDSeries, 2), :);
