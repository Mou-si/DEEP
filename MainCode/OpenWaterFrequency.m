function [SICFrequencyID, MoveMeanSIC] = OpenWaterFrequency...
    (SIC, SeriesLength, TimeAdvance, FrequencyThreshold, ...
    MoveMeanSIC)
% We use this function to calculate which is the frequent open water. We
% calculte the mean membership of openwater in seriselength time, which is
% moving but include today. So it means the moving mean window start at
% today-seriselength~today and end at today~today+seriselength. So that we
% can get a 3-d matrix with seriselength+1 length time dim. The max of each
% pixel  used as the final membership. And than we use two threshold called
% pan and core. The region of frequent open water is defined by the pan
% threshold but it must have a pixel identified bu core threshold.
%
%                           -------------------------------
%    ------------           |    ------------             |
%    |    pan   |           |    |   core   |      pan    |
%    ------------           |    ------------             |
%                           -------------------------------
%
% the outer box on right will be selected and the left one will be ignored.

%% calculate the frequency of open water
% get moving mean SIC by incremental calculate
Dim3DataAll = size(MoveMeanSIC.Data, 3);
if TimeAdvance > Dim3DataAll
    TimeAdvance = Dim3DataAll;
end
% get new data order
if isempty(MoveMeanSIC.i)
    MoveMeanSIC.i = SeriesLength + 1 : -1 : 1;
else
    MoveMeanSIC.i = MoveMeanSIC.i + TimeAdvance;
    MoveMeanSIC.i = mod(MoveMeanSIC.i - 0.5, SeriesLength + 1) + 0.5;
end
% calculate
for j = TimeAdvance : -1 : 1
    MeanRange = SIC.i >= j & ...
        SIC.i <= j + SeriesLength;
     temp = mean(SIC.Data(:, :, MeanRange), 3);
     MoveMeanSIC.Data(:, :, j == MoveMeanSIC.i) = temp;
end
% use the max mean SIC as the frequenct SIC
SICFrequency = max(MoveMeanSIC.Data, [], 3);

%% get frequent open water by core/pan threshold
% get core/pan threshold
FrequencyThresholdCore = FrequencyThreshold(1);
% FrequencyThresholdPan = FrequencyThreshold(2);

% use two threshold to get smaller but with less fake signal area (by core
% threshold) and larger but including more fake signal area (by pan
% threshold)
SICFrequencyCore = SICFrequency;
SICFrequencyCore(SICFrequencyCore < FrequencyThresholdCore) = 0;
%
% SICFrequencyPan = SICFrequency;
% SICFrequencyPan(SICFrequencyPan < FrequencyThresholdPan) = 0;

% do OverlapDye to select all region identified by pan threshold that have
% core area
SICFrequencyCore = bwlabel(SICFrequencyCore);
% SICFrequencyPan = bwlabel(SICFrequencyPan);
SICFrequencyID = SICFrequencyCore;
end

%% subfunction
% make mean for SIC
function MoveMeanSIC = WindowMean(SIC, j, SeriesLength)
MoveMeanSIC = mean(SIC(:, :, end - j - SeriesLength + 1 : end - j + 1), 3);
end