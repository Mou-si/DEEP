function [HeatFluxMat] = HeatLossSeries...
    (Main_i, HeatFlux, MachineIDSeries, MachineIDList, varargin)

%   global var. defined in HeatLossParms.m
global Heat_MovingMeanDays      Heat_MovingMaxDays

if Main_i == 1
    if length(varargin) == 4
        LastOpenWater = varargin{1};
        SICLon = varargin{2};
        SICLat = varargin{3};
        Time = varargin{4};
    else
        error(['lack input for HeatLoss.m.', newline, ...
            'Please check wheather PolynyaRange, SICLon, SICLat, ', ...
            'Time is inputed.'])
    end
        HeatFluxMat = nan(800, ...
            length(Time) + Heat_MovingMeanDays + Heat_MovingMaxDays - 1);
    Time = Time(Main_i);
    for i = 1 : (Heat_MovingMeanDays - 1) / 2
        HeatFluxtemp = HeatLoss(LastOpenWater, MachineIDList, ...
            SICLon, SICLat, Time - days(i));
        HeatFluxMat = MakeHeatFluxMat(HeatFluxtemp, HeatFluxMat);
        Main_i = Main_i + 1;
    end
else
    if length(varargin) == 2
        HeatFluxMat = varargin{1};
        TotalAppend = varargin{2};
    else
        error(['Lack input.', newline, ...
            'Please check wheather HeatFluxMat, TotalAppend, ', ...
            'WarmSeasonSeries is inputed.'])
    end
    Main_i = Main_i + (Heat_MovingMeanDays - 1) / 2;
    if ~isempty(TotalAppend)
        HeatFluxMat(TotalAppend(2, :), :) = HeatFluxMat(TotalAppend(1, :), :);
    end
end

overflow = size(MachineIDSeries, 2) - size(HeatFluxMat, 1);
if overflow > 0
    HeatFluxMat = [HeatFluxMat; ...
        nan(overflow, size(HeatFluxMat, 2))];
end
HeatFluxMat = MakeHeatFluxMat(HeatFlux, HeatFluxMat);

    function HeatFluxMat = MakeHeatFluxMat(MaxHeatFlux, HeatFluxMat)
        HeatFluxMat(:, Main_i) = NaN;
        for ii = 1 : size(MaxHeatFlux)
            HeatFluxMat(MachineIDList(ii) == ...
                MachineIDSeries, Main_i) = ...
                MaxHeatFlux(ii);
        end
    end
end