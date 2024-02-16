function [TempeDiffMat] = TemperatureDiffSeries...
    (Main_i, TempeDiff, MachineIDSeries, MachineIDList, varargin)

if Main_i == 1
    TempeDiffMat = [];
else
    if length(varargin) == 2
        TempeDiffMat = varargin{1};
        TotalAppend = varargin{2};
    else
        error(['Lack input.', newline, ...
            'Please check wheather HeatFluxMat, TotalAppend, ', ...
            'WarmSeasonSeries is inputed.'])
    end
    if ~isempty(TotalAppend)
        TempeDiffMat(TotalAppend(2, :), :) = TempeDiffMat(TotalAppend(1, :), :);
    end
end

overflow = size(MachineIDSeries, 2) - size(TempeDiffMat, 1);
if overflow > 0
    TempeDiffMat = [TempeDiffMat; ...
        nan(overflow, size(TempeDiffMat, 2))];
end
TempeDiffMat = MakeTempeDiffMat(TempeDiff, TempeDiffMat);

    function TempeDiffMat = MakeTempeDiffMat(TempeDiff, TempeDiffMat)
        TempeDiffMat(:, Main_i) = NaN;
        for ii = 1 : size(TempeDiff)
            TempeDiffMat(MachineIDList(ii) == ...
                MachineIDSeries, Main_i) = ...
                TempeDiff(ii);
        end
    end
end