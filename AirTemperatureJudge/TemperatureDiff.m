function MeanTempeDiff = TemperatureDiff(LastOpenWater, MachineIDList, ...
    SICLon, SICLat, Time)
% Calculate the mean air temperature difference in each polynya

%%  call global
% read reanalysis data
%   global var. defined in AirTemperatureParameter.m
global T2m_FileDir     T2m_Files1     T2m_TimeForm     T2m_Files2   T2m_Name
global T_Ocean

% axis of reanalysis data
%   global var. defined in HeatLossParms.m
global LonTempe          LatTempe
global TempeReArrange

%%
% Time = Time - days((Heat_MovingMeanDays - 1) ./ 2 + Heat_MovingMaxDays - 1);
TimeStr = datestr(Time, T2m_TimeForm);
TimeEndDay = day(Time, 'dayofyear');
FileDirSingle = fullfile(T2m_FileDir, [T2m_Files1, TimeStr, T2m_Files2]);
MeanTempeDiff = nan(size(MachineIDList, 1), 1);

%% read data
T2m_raw = ncread(FileDirSingle, T2m_Name);
% if the row reanalysis meteor data cross the meridian (longitude:
% -180~180), we will rearrange the calculated heat fulx data (make
% the longitude of it to 0~360)
if TempeReArrange
    T2m_raw = cat(1, T2m_raw(TempeReArrange + 1 : end, :, :), ...
        T2m_raw(1 : TempeReArrange, :, :));
end
T2m_raw = cat(1, T2m_raw, T2m_raw(1, :, :));

%% calculate data
LastOpenWater = sparse(LastOpenWater);
for i = 1 : size(MachineIDList, 1)
    % !!ATTENTION!!
    % the reanalysis data should start at 0 of lon.
    
    temp = LastOpenWater == MachineIDList(i);
    SICLon2 = SICLon(temp);
    SICLat2 = SICLat(temp);
    PolynyaRange = [min(SICLon2); max(SICLon2); min(SICLat2); max(SICLat2)];
    if isempty(PolynyaRange)
        continue
    end
    
    if abs(PolynyaRange(2) - PolynyaRange(1)) > 180
        Cross0 = 1;
    else
        Cross0 = 0;
    end
    
    MeanTempeDiffTemp = zeros(2, 2);
    for j = 1 : Cross0 + 1
        
        % get xlim and ylim by the polynya range. So that we just read and
        % calculate the data with polynya, which is much less than the
        % total Antarctica and much time will be saved.
        
        if Cross0
            if j == 1
                [LonLim, LatLim] = CutReanalysis(...
                    [0, PolynyaRange(1)], PolynyaRange(3 : 4), ...
                    LonTempe(: ,1), LatTempe(1, :));
            elseif j == 2
                [LonLim, LatLim] = CutReanalysis(...
                    [PolynyaRange(2), 360], PolynyaRange(3 : 4), ...
                    LonTempe(:, 1), LatTempe(1, :));
            end
        else
            [LonLim, LatLim] = CutReanalysis(...
                PolynyaRange(1 : 2), PolynyaRange(3 : 4), ...
                LonTempe(:, 1), LatTempe(1, :));
        end
        
        % select the nearest reanalysis data of the 12:00 of local time
        % (reanalysis is UTC 00 06 12 18).
        Time_UTC = round(mean(LonTempe(LonLim, 1)) ./ 90) + 1;
        if Time_UTC >= 4
            Time_UTC = 8 - Time_UTC;
        else
            Time_UTC = 4 - Time_UTC;
        end
        
        T_a = T2m_raw(min(LonLim) : max(LonLim), min(LatLim): max(LatLim), ...
            Time_UTC);
        LonTemp = LonTempe(min(LonLim) : max(LonLim), ...
            min(LatLim) : max(LatLim));
        LatTemp = LatTempe(min(LonLim) : max(LonLim), ...
            min(LatLim) : max(LatLim));
        if LatTemp(2) == -55
            MeanTempeDiff(i) = -99;
            continue
        end
        
        %% Calculate temperature difference
        TempeDiff = T_Ocean - T_a;
        
        %% heat loss of polynya
        if Cross0
            if j == 1
                SICLon2 = SICLon2(SICLon2 < 180);
                SICLat2 = SICLat2(SICLon2 < 180);
            elseif j == 2
                SICLon2 = SICLon2(SICLon2 > 180);
                SICLat2 = SICLat2(SICLon2 > 180);
            end
        end
        TempeDiff = interp2(LonTemp', LatTemp', TempeDiff', SICLon2, SICLat2);
        % change the positive direction of heat flux to upward
%         if ~isempty(HeatFlux)
%             MeanHeatFluxTemp(j, 1) = max(-HeatFlux);
%         else
%             MeanHeatFluxTemp(j, 1) = -Inf;
%         end
        MeanTempeDiffTemp(j, 1) = sum(TempeDiff);
        MeanTempeDiffTemp(j, 2) = length(TempeDiff);
    end
    MeanTempeDiff(i) = sum(MeanTempeDiffTemp(:, 1)) ...
        / sum(MeanTempeDiffTemp(:, 2));
%     MaxHeatFlux(i) = max(MeanHeatFluxTemp(:, 1));
end

end

function [LonLim, LatLim] = CutReanalysis(SLon, SLat, LLon, LLat)
% Cut reanalysis data in latitude and longitude to make it just cover a
% polynya.
% Input
%   SLon, SLat      1*2 vectors shows the latitude and longitude rang of a
%                   polynya
%   LLon, LLat      1D vectors shows the latitude and longitude rang of
%                   reanalysis data
% Output
%   LonLim, LatLim  1*2 vectors of the start and end position of reanalysis
%                   data on latitude and longitude axis.

if min(SLon) == 0
    LonLimmin = 1;
else
    LonLimmin = find(LLon < min(SLon), 1, 'last');
end
if max(SLon) == 360
    LonLimmax = find(LLon >= 360, 1);
else
    LonLimmax = find(LLon > max(SLon), 1);
end
LonLim = [LonLimmin, LonLimmax];
LatLim = [find(LLat > max(SLat), 1, 'last'), find(LLat < min(SLat), 1)];
end
