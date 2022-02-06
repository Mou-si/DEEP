function MeanHeatFlux = HeatLoss(LastOpenWater, MachineIDList, ...
    SICLon, SICLat, Time)
% Calculate the mean heat flux of each polynya. Loss is positive.
%
% we only calculate the sea-surface heat loss, and ignore the ice-surface
% heat loss. Here we need to read meteorology reanalysis data in latitude
% and longitude axis. The parameterization comes from Nakata et al. (2021),
% and you can change the parameters in HeatLossParms.m.

%%  call global
% read reanalysis data
%   global var. defined in HeatLossParms.m
global Heat_FileDir     Heat_Files1     Heat_Files2     Heat_TimeForm
global Heat_SRDName     Heat_CloudName  Heat_u10mName   Heat_v10mName ...
       Heat_T2mName     Heat_D2mName    Heat_P0Name

% parameter for calculating sea surface heat flux
%   global var. defined in HeatLossParms.m
global Heat_alpha
global Heat_epsilon     Heat_sigma
global Heat_rho_a       Heat_c_p        Heat_L          Heat_Ch_a...
       Heat_Ch_b        Heat_Ch_c       Heat_Ce_a       Heat_Ce_b...
       Heat_Ce_c        Heat_Ts

% axis of reanalysis data
%   global var. defined in HeatLossParms.m
global LonHeat          LatHeat
global HeatFluxReArrange

global Heat_MovingMeanDays     Heat_MovingMaxDays

%%
Time = Time - days((Heat_MovingMeanDays - 1) ./ 2 + Heat_MovingMaxDays - 1);
TimeStr = datestr(Time, Heat_TimeForm);
TimeEndDay = day(Time, 'dayofyear');
FileDirSingle = fullfile(Heat_FileDir, [Heat_Files1, TimeStr, Heat_Files2]);
MeanHeatFlux = zeros(size(MachineIDList, 1), 1);

%% read data
% solar radiation
Sraw = ncread(FileDirSingle, Heat_SRDName);
Sraw = Sraw ./ 60 ./ 60; % solar radiation is cumsumed by 1 hour
% cloud cover
Craw = ncread(FileDirSingle, Heat_CloudName);
% wind speed
u10raw = ncread(FileDirSingle, Heat_u10mName);
v10raw = ncread(FileDirSingle, Heat_v10mName);
% air tempreature
T_araw = ncread(FileDirSingle, Heat_T2mName);
% dew-point temperature
D_araw = ncread(FileDirSingle, Heat_D2mName);
% surface pressure
P_0raw = ncread(FileDirSingle, Heat_P0Name);
% if the row reanalysis meteor data cross the meridian (longitude:
% -180~180), we will rearrange the calculated heat fulx data (make
% the longitude of it to 0~360)
if HeatFluxReArrange
    Sraw = cat(1, Sraw(HeatFluxReArrange + 1 : end, :, :), ...
        Sraw(1 : HeatFluxReArrange, :, :));
    Craw = cat(1, Craw(HeatFluxReArrange + 1 : end, :, :), ...
        Craw(1 : HeatFluxReArrange, :, :));
    u10raw = cat(1, u10raw(HeatFluxReArrange + 1 : end, :, :), ...
        u10raw(1 : HeatFluxReArrange, :, :));
    v10raw = cat(1, v10raw(HeatFluxReArrange + 1 : end, :, :), ...
        v10raw(1 : HeatFluxReArrange, :, :));
    T_araw = cat(1, T_araw(HeatFluxReArrange + 1 : end, :, :), ...
        T_araw(1 : HeatFluxReArrange, :, :));
    D_araw = cat(1, D_araw(HeatFluxReArrange + 1 : end, :, :), ...
        D_araw(1 : HeatFluxReArrange, :, :));
    P_0raw = cat(1, P_0raw(HeatFluxReArrange + 1 : end, :, :), ...
        P_0raw(1 : HeatFluxReArrange, :, :));
end


Sraw = cat(1, Sraw, Sraw(1, :, :));
Craw = cat(1, Craw, Craw(1, :, :));
u10raw = cat(1, u10raw, u10raw(1, :, :));
v10raw = cat(1, v10raw, v10raw(1, :, :));
T_araw = cat(1, T_araw, T_araw(1, :, :));
D_araw = cat(1, D_araw, D_araw(1, :, :));
P_0raw = cat(1, P_0raw, P_0raw(1, :, :));

%% calculate data
LastOpenWater = sparse(LastOpenWater);
for i = 1 : size(MachineIDList, 1)
    % !!ATTENTION!!
    % the reanalysis data should start at 0 of lon.
    
    temp = LastOpenWater == MachineIDList(i);
    SICLon2 = SICLon(temp);
    SICLat2 = SICLat(temp);
    PolynyaRange = [min(SICLon2); max(SICLon2); min(SICLat2); max(SICLat2)];
    
    if abs(PolynyaRange(2) - PolynyaRange(1)) > 180
        Cross0 = 1;
    else
        Cross0 = 0;
    end
    
    MeanHeatFluxTemp = zeros(2, 2);
    for j = 1 : Cross0 + 1
        
        % get xlim and ylim by the polynya range. So that we just read and
        % calculate the data with polynya, which is much less than the
        % total Antarctica and much time will be saved.
        if Cross0
            if j == 1
                [LonLim, LatLim] = CutReanalysis(...
                    [0, PolynyaRange(1)], PolynyaRange(3 : 4), ...
                    LonHeat(: ,1), LatHeat(1, :));
            elseif j == 2
                [LonLim, LatLim] = CutReanalysis(...
                    [PolynyaRange(2), 360], PolynyaRange(3 : 4), ...
                    LonHeat(:, 1), LatHeat(1, :));
            end
        else
            [LonLim, LatLim] = CutReanalysis(...
                PolynyaRange(1 : 2), PolynyaRange(3 : 4), ...
                LonHeat(:, 1), LatHeat(1, :));
        end
        
        % select the nearest reanalysis data of the 12:00 of local time
        % (reanalysis is UTC 00 06 12 18).
        Time_UTC = round(mean(LonHeat(LonLim, 1)) ./ 90) + 1;
        if Time_UTC >= 4
            Time_UTC = 8 - Time_UTC;
        else
            Time_UTC = 4 - Time_UTC;
        end
        
        S = Sraw(min(LonLim) : max(LonLim), min(LatLim): max(LatLim), ...
            Time_UTC);
        C = Craw(min(LonLim) : max(LonLim), min(LatLim): max(LatLim), ...
            Time_UTC);
        u10 = u10raw(min(LonLim) : max(LonLim), min(LatLim): max(LatLim), ...
            Time_UTC);
        v10 = v10raw(min(LonLim) : max(LonLim), min(LatLim): max(LatLim), ...
            Time_UTC);
        U = sqrt(u10 .^ 2 + v10 .^ 2);
        T_a = T_araw(min(LonLim) : max(LonLim), min(LatLim): max(LatLim), ...
            Time_UTC);
        D_a = D_araw(min(LonLim) : max(LonLim), min(LatLim): max(LatLim), ...
            Time_UTC);
        P_0 = P_0raw(min(LonLim) : max(LonLim), min(LatLim): max(LatLim), ...
            Time_UTC);
        LonTemp = LonHeat(min(LonLim) : max(LonLim), ...
            min(LatLim) : max(LatLim));
        LatTemp = LatHeat(min(LonLim) : max(LonLim), ...
            min(LatLim) : max(LatLim));
        
                
        %% calculate sea surface heat flux
        % !!ATTENTION!!
        % the data we read is in a positive downward direction, but when
        % the result is returned, positive means upward.
        
        % the parameterization scheme is followed by Nakata, K., K. I.
        % Ohshima, and S. Nihashi (2021), Mapping of Active Frazil for
        % Antarctic Coastal Polynyas, With an Estimation of Sea-Ice
        % Production, Geophys Res Lett, 48(6), doi:10.1029/2020GL091353.
        
        % short wave
        SubSolarLat = cosd((172 - TimeEndDay) ./ 365 .* 360) .* 23.44;
        S = (1 - Heat_alpha) .* S .* ...
            (1 - 0.62 .* C + 0.0019 .* (90 - abs(SubSolarLat - ...
            LatTemp)));
        
        % long wave
        Ln = -Heat_epsilon .* Heat_sigma .* Heat_Ts .^ 4 + ...
            Heat_sigma .* T_a .^ 4 .* (0.765 + 0.22 .* C .^ 3);
        
        % sensible heat
        C_h = (Heat_Ch_a + Heat_Ch_b .* U + Heat_Ch_c .* (U - 8) .^ 2)...
            .* 1e-3;
        Fs = Heat_rho_a .* Heat_c_p .* C_h .* U .* (T_a - Heat_Ts);
        
        % latern heat
        C_e = (Heat_Ce_a + Heat_Ce_b .* U + Heat_Ce_c .* (U - 8) .^ 2)...
            .* 1e-3;
        % sea surface vapour pressure
        re_a = 6.1078 .* exp(17.2693882 .* (D_a - 273.16) ./ (D_a - 35.68))...
            .* 100;
        % sea surface saturation vapour pressure
        e_ss = 6.1078 .* ...
            exp(17.2693882 .* (Heat_Ts - 273.16) ./ (Heat_Ts - 35.68))...
            .* 100;
        Fe = Heat_rho_a .* Heat_L .* C_e .* U .* 0.622 .* ...
            (re_a - e_ss) ./ P_0;
        
        % total heat flux. downward is positive
        HeatFlux = S + Ln + Fs + Fe;
        
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
        HeatFlux = interp2(LonTemp', LatTemp', HeatFlux', SICLon2, SICLat2);
        % change the positive direction of heat flux to upward
        MeanHeatFluxTemp(j, 1) = sum(-HeatFlux);
        MeanHeatFluxTemp(j, 2) = length(HeatFlux);
    end
    MeanHeatFlux(i) = sum(MeanHeatFluxTemp(:, 1)) ...
        / sum(MeanHeatFluxTemp(:, 2));
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

LonLim = [find(LLon <= min(SLon), 1, 'last'), find(LLon >= max(SLon), 1)];
LatLim = [find(LLat >= max(SLat), 1, 'last'), find(LLat <= min(SLat), 1)];
end