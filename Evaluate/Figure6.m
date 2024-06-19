close all; clear; clc;
load('C:\Users\13098\Documents\冰间湖识别\DataTrans\SICOpenWaterFrequence.mat')
Lon_DEEP = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lon');
Lat_DEEP = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lat');
load('C:\Users\13098\Documents\MATLAB\Othertools\colorbar\MPL_Blues.rgb')
MPL_Blues = ColorbarRemap(MPL_Blues, 105);
MPL_Blues(1 : 5, :) = [];

%% Total Antarctica
figure

% SITopen water frequency
ax1 = axes('position', [0.1, 0.68, 0.27, 0.27]);
m_proj('Azimuthal Equal-area', 'lon', 0, 'lat', -90, 'rad', 36)
h = m_pcolor(Lon_DEEP, Lat_DEEP, OpenWater);
set(h, 'LineStyle', 'None');
set(gca, 'CLim', [0, 0.6])
hold on

% DEEP polynya robust extent
DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\OverviewMap.mat';
OverviewMap = load(DEEPPath);
OverviewMap = OverviewMap.OverviewMap;
OverviewMap = double(OverviewMap > 0);
[~, h] = m_contour(double(Lon_DEEP), double(Lat_DEEP), OverviewMap, [0.5, 0.5]);
set(h, 'LineWidth', 1, 'LineColor', [0.8, 0, 0])

m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
m_grid('XaxisLocation', 'top', 'xticklabels', ['', '', '', '', '', ''], ...
    'yticklabels', ['', '', ''], 'FontSize', 8)

% research region position
hold on
m_plot(180, -74.5, 'k.')
m_plot(153, -78.5, 'b.')

% zoom-in
ax2 = axes('position', [0.1, 0.35, 0.27, 0.27]);
m_proj('Azimuthal Equal-area', 'lon', 180, 'lat', -74.5, 'rad', [153, -78.5], 'rec', 'on')
h = m_pcolor(Lon_DEEP, Lat_DEEP, OpenWater);
set(h, 'LineStyle', 'None');
set(gca, 'CLim', [0, 0.6])
hold on

[~, h] = m_contour(double(Lon_DEEP), double(Lat_DEEP), OverviewMap, [0.5, 0.5]);
set(h, 'LineWidth', 1, 'LineColor', [0.8, 0, 0])

m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

colormap(MPL_Blues)

%% SDITP

% muilty-years frequency map
ax3 = axes('position', [0.4, 0.35, 0.235, 0.6]);
m_proj('Azimuthal Equal-area', 'lon', 164.7, 'lat', -76.3, 'rad', [162, -74.3], 'rec', 'on')
h = m_pcolor(Lon_DEEP, Lat_DEEP, OpenWater);
set(h, 'LineStyle', 'None');
set(gca, 'CLim', [0, 0.6])
hold on

% m_gshhs_h('patch', [0.8, 0.8, 0.8])
PlotMeanWinds
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

colormap(ax3, MPL_Blues)

% DEEP (vs. MODIS)
ax4 = axes('position', [0.665, 0.35, 0.235, 0.6]);
m_proj('Azimuthal Equal-area', 'lon', 164.7, 'lat', -76.3, 'rad', [162, -74.3], 'rec', 'on')
MODISPath = 'G:\MODIS\DITP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2013-09-22'));

hold on
DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotDEEP(DEEPPath, datetime('2013-09-22'), Lon_DEEP, Lat_DEEP)

PlotWinds(datetime('2013-09-22'))
m_grid('XaxisLocation', 'bottom', 'YaxisLocation', 'right', 'FontSize', 8)

%% island
if 1
%% Peter I Island

% muilty-years frequency map
ax5 = axes('position', [0.1, 0.1, 0.18, 0.18]);
m_proj('Azimuthal Equal-area', ...
    'lon', -90.5, 'lat', -68.8, 'rad', [-94, -69.7], 'rec', 'on')
h = m_pcolor(Lon_DEEP, Lat_DEEP, OpenWater);
set(h, 'LineStyle', 'None');
set(gca, 'CLim', [0, 0.6])
hold on

m_gshhs_h('patch', [0.8, 0.8, 0.8])
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

colormap(ax5, MPL_Blues)

% DEEP (vs. MODIS)
ax6 = axes('position', [0.3, 0.1, 0.18, 0.18]);
m_proj('Azimuthal Equal-area', ...
    'lon', -90.5, 'lat', -68.8, 'rad', [-94, -69.7], 'rec', 'on')
MODISPath = 'G:\MODIS\DITP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2015-09-24'));

hold on
DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotDEEP(DEEPPath, datetime('2015-09-24'), Lon_DEEP, Lat_DEEP)

PlotWinds(datetime('2015-09-24'))
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

%% Balleny Islands

% muilty-years frequency map
ax7 = axes('position', [0.52, 0.1, 0.18, 0.18]);
m_proj('Azimuthal Equal-area', ...
    'lon', 163.699, 'lat', -66.899, 'rad', [159, -65.3], 'rec', 'on')
h = m_pcolor(Lon_DEEP, Lat_DEEP, OpenWater);
set(h, 'LineStyle', 'None');
set(gca, 'CLim', [0, 0.6])
hold on

% m_gshhs_h('patch', [0.8, 0.8, 0.8])
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

colormap(ax7, MPL_Blues)

% DEEP (vs. MODIS)
ax8 = axes('position', [0.72, 0.1, 0.18, 0.18]);
m_proj('Azimuthal Equal-area', ...
    'lon', 163.71, 'lat', -66.91, 'rad', [159, -65.3], 'rec', 'on')
MODISPath = 'G:\MODIS\DITP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2010-10-23'));

hold on
DEEPPath = 'G:\AAPSResults\AMSR_SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotDEEP(DEEPPath, datetime('2010-10-23'), Lon_DEEP, Lat_DEEP)

PlotWinds(datetime('2010-10-23'))
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

end

m_AdjudgeTickLabel('all')
set(gcf, 'units', 'centimeters', 'position', [0, 0, 16, 18])

%% plot MODIS
function PlotMODIS(Path, Time)
RDataSetName = '/MODIS SWATH TYPE L2/Data Fields/500m Surface Reflectance Band 1';
GDataSetName = '/MODIS SWATH TYPE L2/Data Fields/500m Surface Reflectance Band 4';
BDataSetName = '/MODIS SWATH TYPE L2/Data Fields/500m Surface Reflectance Band 3';
Yr = datestr(Time, 'yyyy');
Yr_1 = num2str(str2double(datestr(Time, 'yyyy')) - 1);
FileName = dir([Path, 'MYD09.A', Yr, ...
    num2str(days(Time - datetime([Yr_1, '-12-31'])), '%.3d'), '*']);
FileName = cat(1, FileName.name);
FileName = flipud(FileName);
for i = 1 : size(FileName, 1)
    Lon = hdfread([Path, FileName(i, :)], '/Geolocation Fields/Longitude');
    Lat = hdfread([Path, FileName(i, :)], '/Geolocation Fields/Latitude');
    
    R = hdfread([Path, FileName(i, :)], RDataSetName);
    R(R == 65535) = NaN;
    Rscale = hdfinfo([Path, FileName(i, :)]);
    R = double(R) .* Rscale.Vgroup.Vgroup(2).SDS(10).Attributes(6).Value(1);
    G = hdfread([Path, FileName(i, :)], GDataSetName);
    G(G == 65535) = NaN;
    Gscale = hdfinfo([Path, FileName(i, :)]);
    G = double(G) .* Gscale.Vgroup.Vgroup(2).SDS(13).Attributes(6).Value(1);
    B = hdfread([Path, FileName(i, :)], BDataSetName);
    B(B == 65535) = NaN;
    Bscale = hdfinfo([Path, FileName(i, :)]);
    B = double(B) .* Bscale.Vgroup.Vgroup(2).SDS(12).Attributes(6).Value(1);
    RGB = cat(3, R, G, B);
    RGB = RGB .* 255;
    RGB = uint8(RGB);
    m_imageProj(Lon, Lat, RGB)
    hold on
end
end

%% plot polynyas in DEEP
function PlotDEEP(Path, Time, Lon_PSSM, Lat_PSSM)
% polynyas
PolynyaID_DEEP = ncread([Path, datestr(Time, 'yyyymmdd'), '_v1.0.nc'], ...
    'Map');
PolynyaID_DEEP = double(PolynyaID_DEEP > 0 & ~isnan(PolynyaID_DEEP));
[~, h] = m_contour(double(Lon_PSSM), double(Lat_PSSM), PolynyaID_DEEP, [0.5, 0.5]);
set(h, 'LineWidth', 1.5, 'LineColor', [0.8, 0, 0]);
hold on

% the other open waters
PolynyaID_DEEP = ncread([Path, datestr(Time, 'yyyymmdd'), '_v1.0.nc'], ...
    'Map');
PolynyaID_DEEP = double(PolynyaID_DEEP < 0 & PolynyaID_DEEP > -100);
[~, h] = m_contour(double(Lon_PSSM), double(Lat_PSSM), PolynyaID_DEEP, [0.5, 0.5]);
set(h, 'LineWidth', 0.75, 'LineColor', [0.8, 0.8, 0]);

end

%% plot climate state winds
function PlotMeanWinds
load('C:\Users\13098\Documents\冰间湖产冰量\Data\DataTemp\WindMeanRossSea.mat')
Windu = Windu ./ 3;
Windv = Windv ./ 3;
m_quiverSparse(WindMeanLon, WindMeanLat, Windu, 3, Windv, 1, ...
    'AutoScale', 'off', 'ShowArrowHead', 'off');
end

%% plot winds
function PlotWinds(Time)
ERA5Path = 'G:\ERA5Data\ERA5-SignalLevel-TPDUShortWaveCloud-';
Lon_ERA5 = ncread([ERA5Path , '20000624.nc'], 'longitude');
Lat_ERA5 = ncread([ERA5Path , '20000624.nc'], 'latitude');
[Lon_ERA5, Lat_ERA5] = meshgrid(Lon_ERA5, Lat_ERA5);
WindU = ncread([ERA5Path , datestr(Time, 'yyyymmdd'), '.nc'], 'u10');
WindU = WindU(:, :, 1);
WindV = ncread([ERA5Path , datestr(Time, 'yyyymmdd'), '.nc'], 'v10');
WindV = WindV(:, :, 1);
WindU = WindU ./ 4;
WindV = WindV ./ 4;
m_quiverSparse(Lon_ERA5', Lat_ERA5', WindU, 7, WindV, 3, ...
    'AutoScale', 'off', 'ShowArrowHead', 'off');
m_quiverlegend(165, -76, 10 / 4, 0, '10 m s^{-1}')
end