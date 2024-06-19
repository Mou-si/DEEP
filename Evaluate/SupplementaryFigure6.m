clear; close all; clc;
load('C:\Users\13098\Documents\冰间湖识别\DataTrans\SITOpenWaterFrequence.mat')
Lon_PSSM = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Longitudes');
Lat_PSSM = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Latitudes');
Lon_SIT = hdfread(...
    ['G:\AMSR36_PSSM\', ...
    'LongitudeLatitudeGrid-s12500-Antarctic.hdf'], 'Longitudes');
Lat_SIT = hdfread(...
    ['G:\AMSR36_PSSM\', ...
    'LongitudeLatitudeGrid-s12500-Antarctic.hdf'], 'Latitudes');

%% Basical Map
figure
DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\OverviewMap.mat';
SICMap = load(DEEPPath);
SICMap = SICMap.OverviewMap;

%% Cooperation Sea
m_proj('Azimuthal Equal-area', 'lon', 73.8, 'lat', -62.8, 'rad', [83, -64.8], ...
    'rec', 'on')
% Open water frequence
h = m_pcolor(Lon_SIT, Lat_SIT, OpenWater);
set(gca, 'CLim', [0, 0.6])
set(h, 'LineStyle', 'None');

% Robust extent
hold on
SICMap = SICMap(660 : 850, 1050 : 1160);
Lon_PSSM = Lon_PSSM(660 : 850, 1050 : 1160);
Lat_PSSM = Lat_PSSM(660 : 850, 1050 : 1160);
PolynyaIDs = unique(SICMap);

for i = 2 : length(PolynyaIDs)
    SICMap_temp = double(SICMap == PolynyaIDs(i));
    [~, h] = m_contour(double(Lon_PSSM), double(Lat_PSSM), SICMap_temp, [0.5, 0.5]);
    set(h, 'LineWidth', 1, 'LineColor', [0.8, 0, 0])
end

m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

load('C:\Users\13098\Documents\MATLAB\Othertools\colorbar\MPL_Blues.rgb')
MPL_Blues = ColorbarRemap(MPL_Blues, 105);
MPL_Blues(1 : 5, :) = [];
colormap(MPL_Blues)
m_AdjudgeTickLabel('all')

set(gcf, 'units', 'centimeters', 'position', [5, 5, 13.5, 13.5])

colorbar('position', [0.5, 0.1, 0.35, 0.016], 'orientation', 'horizontal')
ColorbarArrowOuter('left', 0, 'ArrowLength', 1.5)