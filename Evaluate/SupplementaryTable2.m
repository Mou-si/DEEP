clear; close all; clc;
FreqID = xlsread('C:\Users\13098\Documents\冰间湖识别\FreqID.xlsx');
FreqID = FreqID(~isnan(FreqID));
FreqID = sort(FreqID);
load('G:\DEEP-AAShare\SIC60_6.25km_20d\OverviewMap.mat')
OverviewMap(isnan(OverviewMap)) = 0;
OverviewMap(~ismember(OverviewMap, FreqID)) = 0;
Lon = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lon');
Lat = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lat');

PolynyaIDs = unique(OverviewMap);
% get longitudes of polynyas
PolynyaLocation = PolynyaIDs(2 : end);
PolynyaLocation = mod(PolynyaLocation, 10000000);
PolynyaLocation = floor(PolynyaLocation ./ 1000) ./ 10;

% change the IDs in OverviewMap, so the adjacent will have different colors
% in the colormap lines
[~, PolynyaLocation_i] = sort(PolynyaLocation);
[~, ~, ic] = unique(OverviewMap);
PolynyaLocation_i = [0; PolynyaLocation_i];
OverviewMap_New = PolynyaLocation_i(ic);
OverviewMap_New = reshape(OverviewMap_New, ...
    size(OverviewMap, 1), size(OverviewMap, 2));

OverviewMap_New(OverviewMap_New == 0) = NaN;
figure
% west antarctica
subplot(4, 1, 1)
m_proj('Miller Cylindrical', 'lon', [160, 340], 'lat', [-80, -60])
m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
hold on
h = m_pcolor(Lon, Lat, OverviewMap_New);
set(h, 'LineStyle', 'None')
m_grid('XaxisLocation', 'bottom', ...
    'ytick', [-80, -70, -60], 'FontSize', 8)
load('C:\Users\13098\Documents\MATLAB\Othertools\colorbar\MPL_Blues.rgb')
colormap(lines(length(FreqID)))
set(gca, 'CLim', [1, length(FreqID)])

% west antarctica
subplot(4, 1, 2)
Lon2 = Lon;
Lon2(Lon2 > 180) = Lon2(Lon2 > 180) - 360; % lon here should be -180 ~ 180
m_proj('Miller Cylindrical', 'lon', [-20, 160], 'lat', [-76, -56])
m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
hold on
h = m_pcolor(Lon2, Lat, OverviewMap_New);
set(h, 'LineStyle', 'None')
m_grid('XaxisLocation', 'bottom', ...
    'ytick', [-80, -70, -60], 'FontSize', 8)
load('C:\Users\13098\Documents\MATLAB\Othertools\colorbar\MPL_Blues.rgb')
colormap(lines(length(PolynyaIDs)))
set(gca, 'CLim', [1, length(PolynyaIDs)])

%%
Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
Time = datetime('2003-04-01') : datetime('2022-10-31');
MMDD = str2double(string(datestr(Time, 'mmdd')));
Time = Time(MMDD > 400 & MMDD < 1100);
PolynyaIDs = [];
for i = 1 : length(Time)
    try
        Polynyatemp = ncread([Path, datestr(Time(i), 'yyyymmdd'), '_v1.0.nc'], ...
            'Map');
    catch
        PolynyaArea(i, :) = NaN;
        continue
    end
    Polynyatemp(Polynyatemp < 100) = 0;
    Polynyatemp(isnan(Polynyatemp)) = 0;
    
    % only need coastal polynyas
    % it will be easier to use the tag in polynya IDs
    [Polynyatemp, ~, ic] = unique(Polynyatemp);
    PolynyaAreatemp = accumarray(ic, 1);
    for j = 1 : length(Polynyatemp)
        if ~ismember(Polynyatemp(j), PolynyaIDs)
            PolynyaIDs = [PolynyaIDs; Polynyatemp(j)];
        end
        PolynyaArea(i, PolynyaIDs == Polynyatemp(j)) = PolynyaAreatemp(j);
    end
end
PolynyaArea(isnan(PolynyaArea(:, 1)), :) = NaN;
PolynyaArea(:, 1) = [];
PolynyaIDs = PolynyaIDs(2 : end);

PolynyaOccur = PolynyaArea > 0;
PolynyaOccur = reshape(PolynyaOccur, 214, 20, size(PolynyaOccur, 2));
PolynyaOccur(:, 9 : 10, :) = [];
PolynyaOccur = reshape(PolynyaOccur, 214 * 18, size(PolynyaOccur, 3));
PolynyaOccur = sum(double(PolynyaOccur)) ./ 18;

FreqPolynyaOccur = zeros(length(FreqID), 1);
for i = 1 : length(FreqID)
    FreqPolynyaOccur(i) = PolynyaOccur(PolynyaIDs == FreqID(i));
end