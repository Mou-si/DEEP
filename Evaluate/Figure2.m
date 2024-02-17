close all; clear; clc;
%% read the overview map
load('G:\AAPSResults\AMSR_SIC60_6.25km_20d\OverviewMap.mat')
OverviewMap(isnan(OverviewMap)) = 0;
PolynyaIDs = unique(OverviewMap);

Lon = hdfread(...
    'G:\Antaratica_ASI_SIC_6250\LongitudeLatitudeGrid-s6250-Antarctic.hdf', ...
    'Longitudes');
Lat = hdfread(...
    'G:\Antaratica_ASI_SIC_6250\LongitudeLatitudeGrid-s6250-Antarctic.hdf', ...
    'Latitudes');

%% rename the polynya IDs
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

%% plot robust extent
OverviewMap_New(OverviewMap_New == 0) = NaN;

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
colormap(lines(length(PolynyaIDs)))
set(gca, 'CLim', [1, length(PolynyaIDs)])

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

%% calculate polynya frequency
SIC60Path = 'G:\AAPSResults\AMSR_SIC60_6.25km_20d\';
SIC60Files = dir([SIC60Path, 'AAPS*']);
PolynyaFrequency = zeros(size(OverviewMap));
for i = 1 : length(SIC60Files)
    PolynyaMap = ncread([SIC60Path, SIC60Files(i).name], 'PolynyaIDMaps');
    PolynyaFrequency = PolynyaFrequency + double(PolynyaMap > 100);
end
PolynyaFrequency = PolynyaFrequency ./ length(SIC60Files);

%% plot polynya frequency
% west antarctica
subplot(4, 1, 3)
m_proj('Miller Cylindrical', 'lon', [160, 340], 'lat', [-80, -60])
m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
hold on
[~, h] = m_contourf(Lon, Lat, PolynyaFrequency, 0 : 0.01 : 0.6);
set(h, 'LineStyle', 'None')
m_grid('XaxisLocation', 'top', ...
    'ytick', [-80, -70, -60], 'FontSize', 8)
set(gca, 'CLim', [0, 0.6])

% east antarctica
subplot(4, 1, 4)
m_proj('Miller Cylindrical', 'lon', [-20, 160], 'lat', [-76, -56])
m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
hold on
[~, h] = m_contourf(Lon2, Lat, PolynyaFrequency, 0 : 0.01 : 0.6);
set(h, 'LineStyle', 'None')
m_grid('XaxisLocation', 'top', ...
    'ytick', [-80, -70, -60], 'FontSize', 8)
set(gca, 'CLim', [0, 0.6])

load('C:\Users\13098\Documents\MATLAB\Othertools\colorbar\MPL_Blues.rgb')
MPL_Blues = MPL_Blues(1 : end - 10, :);
MPL_Blues = ColorbarRemap(MPL_Blues, 75);
MPL_Blues(1 : 15, :) = [];
MPL_Blues(1, :) = [1, 1, 1];
colormap(MPL_Blues)
set(gcf, 'units', 'centimeters', 'Position', [5, 0, 16.8, 18])

%% total antarctica
% robust extent
figure
m_proj('Azimuthal Equal-area', 'lon', 0, 'lat', -90, 'rad', 34)
h = m_pcolor(Lon, Lat, OverviewMap_New);
hold on
set(h, 'LineStyle', 'None')
m_grid('XaxisLocation', 'top', ...
'ytick', [-80, -70, -60], 'yticklabels', {}, 'FontSize', 8)
colormap(lines(length(PolynyaIDs)))
set(gca, 'CLim', [1, length(PolynyaIDs)])
% plot the region of west/east antarctica
x1 = 160 : 340;
y1 = [repmat(-80, 1, length(x1)), repmat(-60, 1, length(x1)), -60];
x1 = [x1, fliplr(x1), x1(1)];
m_plot(x1, y1, 'b');
x1 = -20 : 160;
y1 = [repmat(-76, 1, length(x1)), repmat(-56, 1, length(x1)), -76];
x1 = [x1, fliplr(x1), x1(1)];
m_plot(x1, y1, 'k');

% polynya freuqency
m_proj('Azimuthal Equal-area', 'lon', 0, 'lat', -90, 'rad', 34)
m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
hold on
[~, h] = m_contourf(Lon, Lat, PolynyaFrequency, 0 : 0.01 : 0.6);
set(h, 'LineStyle', 'None')
m_grid('XaxisLocation', 'top', ...
'ytick', [-80, -70, -60], 'yticklabels', {}, 'FontSize', 8)
colormap(MPL_Blues)
set(gca, 'CLim', [0, 0.6])
% plot the region of west/east antarctica
x1 = 160 : 340;
y1 = [repmat(-80, 1, length(x1)), repmat(-60, 1, length(x1)), -60];
x1 = [x1, fliplr(x1), x1(1)];
m_plot(x1, y1, 'b');
x1 = -20 : 160;
y1 = [repmat(-76, 1, length(x1)), repmat(-56, 1, length(x1)), -76];
x1 = [x1, fliplr(x1), x1(1)];
m_plot(x1, y1, 'k');