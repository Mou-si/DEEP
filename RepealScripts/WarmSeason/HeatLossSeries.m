function [HeatFluxMat] = HeatLossSeries...
    (Main_i, HeatFlux, MachineIDSeries, MachineIDList, varargin)

if Main_i == 1
    HeatFluxMat = [];
else
    if length(varargin) == 2
        HeatFluxMat = varargin{1};
        TotalAppend = varargin{2};
    else
        error(['Lack input.', newline, ...
            'Please check wheather HeatFluxMat, TotalAppend, ', ...
            'WarmSeasonSeries is inputed.'])
    end
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
