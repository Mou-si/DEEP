clear; close all; clc;
load('C:\Users\13098\Documents\冰间湖识别\DataTrans\SITOpenWaterFrequence.mat')
Lon_DEEP = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lon');
Lat_DEEP = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lat');
Lon_SIT = hdfread(...
    ['G:\AMSR36_PSSM\', ...
    'LongitudeLatitudeGrid-s12500-Antarctic.hdf'], 'Longitudes');
Lat_SIT = hdfread(...
    ['G:\AMSR36_PSSM\', ...
    'LongitudeLatitudeGrid-s12500-Antarctic.hdf'], 'Latitudes');

%% Maud Rise
subplot(2, 4, 1)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [15, -69], 'rec', 'on')
% Open water frequence
h = m_pcolor(Lon_SIT, Lat_SIT, OpenWater);
set(h, 'LineStyle', 'None');

m_gshhs_h('patch', [0.8, 0.8, 0.8])
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)
set(gca, 'CLim', [0, 0.6])

subplot(2, 4, 2)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [15, -69], 'rec', 'on')
% MODIS
MODISPath = 'G:\MODIS\MRP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2017-09-25'));

% polynya extent
hold on
DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2017-09-25'), Lon_DEEP, Lat_DEEP)

m_gshhs_h('patch', [0.8, 0.8, 0.8])
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

%% Cosmonauts Sea
subplot(2, 4, 3)
m_proj('Azimuthal Equal-area', 'lon', 46, 'lat', -66, 'rad', [61, -70.2], 'rec', 'on')
% Open water frequence
h = m_pcolor(Lon_SIT, Lat_SIT, OpenWater);
set(h, 'LineStyle', 'None');
set(gca, 'CLim', [0, 0.6])

hold on
m_gshhs_h('patch', [0.8, 0.8, 0.8])
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

subplot(2, 4, 4)
m_proj('Azimuthal Equal-area', 'lon', 46, 'lat', -66, 'rad', [61, -70.2], 'rec', 'on')
% MODIS
MODISPath = 'G:\MODIS\Cosmonauts Sea\09\';
PlotMODIS(MODISPath, datetime('2014-09-11'));

% polynya extent
hold on
DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2014-09-11'), Lon_DEEP, Lat_DEEP)

m_gshhs_h('patch', [0.8, 0.8, 0.8])
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

%% Cooperation Sea
subplot(2, 4, 5)
m_proj('Azimuthal Equal-area', 'lon', 77, 'lat', -62.3, 'rad', [83, -64.8], ...
    'rec', 'on')
% Open water frequence
h = m_pcolor(Lon_SIT, Lat_SIT, OpenWater);
set(gca, 'CLim', [0, 0.6])
set(h, 'LineStyle', 'None');

hold on
m_gshhs_h('patch', [0.8, 0.8, 0.8])
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

subplot(2, 4, 6)
m_proj('Azimuthal Equal-area', 'lon', 77, 'lat', -62.3, 'rad', [83, -64.8], ...
    'rec', 'on')
% MODIS
MODISPath = 'G:\MODIS\Cooperation Sea\09\';
PlotMODIS(MODISPath, datetime('2009-09-08'));

% polynya extent
hold on
DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2009-09-08'), Lon_DEEP, Lat_DEEP)

m_gshhs_h('patch', [0.8, 0.8, 0.8])
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

%% N. Ross Sea
subplot(2, 4, 7)
m_proj('Azimuthal Equal-area', 'lon', -174.5, 'lat', -65.7, 'rad', [-179.9, -63.3], ...
    'rec', 'on')
% Open water frequence
h = m_pcolor(Lon_SIT, Lat_SIT, OpenWater);
set(h, 'LineStyle', 'None');

hold on
m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

subplot(2, 4, 8)
m_proj('Azimuthal Equal-area', 'lon', -174.5, 'lat', -65.7, 'rad', [-179.9, -63.3], ...
    'rec', 'on')

% MODIS
MODISPath = 'G:\MODIS\NRSP\09\';
PlotMODIS(MODISPath, datetime('2004-09-13'));

% polynya extent
hold on
DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2004-09-13'), Lon_DEEP, Lat_DEEP)

m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

%% total
load('G:\AAPSResults\AMSR_SIC60_6.25km_20d\OverviewMap.mat')
OverviewMap(isnan(OverviewMap)) = 0;

subplot(2, 4, 7)
m_proj('Azimuthal Equal-area', 'lon', 0, 'lat', -90, 'rad', 36)
h = m_pcolor(Lon_DEEP, Lat_DEEP, OpenWater);
set(h, 'LineStyle', 'None');
set(gca, 'CLim', [0, 0.6])
hold on

[~, h] = m_contour(double(Lon_DEEP), double(Lat_DEEP), OverviewMap, [0.5, 0.5]);
set(h, 'LineWidth', 1, 'LineColor', [0.8, 0, 0])

m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
m_grid('XaxisLocation', 'top', 'xticklabels', ['', '', '', '', '', ''], ...
    'yticklabels', ['', '', ''], 'FontSize', 8)
hold on
m_plot(15, -69, 'b.')
m_plot(3, -65, 'k.')
m_plot(61, -70.2, 'b.')
m_plot(46, -66, 'k.')
m_plot(83, -64.8, 'b.')
m_plot(77, -62.3, 'k.')  
m_plot(-174.5, -65.7, 'b.')
m_plot(-179.9, -63.3, 'k.')  

set(gcf, 'units', 'centimeter', 'position', [0, 0, 26, 8.8])

load('C:\Users\13098\Documents\MATLAB\Othertools\colorbar\MPL_Blues.rgb')
MPL_Blues = ColorbarRemap(MPL_Blues, 105);
MPL_Blues(1 : 5, :) = [];
colormap(MPL_Blues)
m_AdjudgeTickLabel('all')

colorbar('position', [0.75, 0.2, 0.12, 0.02], 'orientation', 'horizontal')
ColorbarArrowOuter('left', 0)

%%
figure
subplot(1, 6, 1)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [15, -69], 'rec', 'on')
MODISPath = 'G:\MODIS\MRP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2005-10-05'));
hold on

DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2005-10-05'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'XaxisLocation', 'bottom', 'xtick', [], 'ytick', [], 'box', 'off')

subplot(1, 6, 2)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [15, -69], 'rec', 'on')
MODISPath = 'G:\MODIS\MRP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2005-10-10'));
hold on

DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2005-10-10'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'XaxisLocation', 'bottom', 'xtick', [], 'ytick', [], 'box', 'off')

subplot(1, 6, 3)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [15, -69], 'rec', 'on')
MODISPath = 'G:\MODIS\MRP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2005-10-14'));
hold on

DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2005-10-14'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'XaxisLocation', 'bottom', 'xtick', [], 'ytick', [], 'box', 'off')

subplot(1, 6, 4)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [15, -69], 'rec', 'on')
MODISPath = 'G:\MODIS\MRP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2018-09-08'));
hold on

DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2018-09-08'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'XaxisLocation', 'bottom', 'xtick', [], 'ytick', [], 'box', 'off')

subplot(1, 6, 5)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [15, -69], 'rec', 'on')
MODISPath = 'G:\MODIS\MRP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2018-09-09'));
hold on

DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2018-09-09'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'XaxisLocation', 'bottom', 'xtick', [], 'ytick', [], 'box', 'off')

subplot(1, 6, 6)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [15, -69], 'rec', 'on')
MODISPath = 'G:\MODIS\MRP_SWATH\09\';
PlotMODIS(MODISPath, datetime('2018-09-12'));
hold on

DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2018-09-12'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'XaxisLocation', 'bottom', 'xtick', [], 'ytick', [], 'box', 'off')

set(gcf, 'units', 'centimeter', 'position', [0, 0, 26, 2.7])

%%
figure
m_proj('Azimuthal Equal-area', 'lon', 77, 'lat', -60, 'rad', [120, -70], ...
    'rec', 'on')
MODISPath = 'G:\MODIS\Cooperation Sea\';
PlotMODIS(MODISPath, datetime('2009-09-08'));

DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
PlotPSSM(DEEPPath, datetime('2009-09-08'), Lon_DEEP, Lat_DEEP)

m_grid('XaxisLocation', 'bottom', 'FontSize', 8)

%%
function PlotMODIS(Path, Time)
RDataSetName = '/MODIS SWATH TYPE L2/Data Fields/500m Surface Reflectance Band 1';
GDataSetName = '/MODIS SWATH TYPE L2/Data Fields/500m Surface Reflectance Band 4';
BDataSetName = '/MODIS SWATH TYPE L2/Data Fields/500m Surface Reflectance Band 3';
Yr = datestr(Time, 'yyyy');
Yr_1 = num2str(str2double(datestr(Time, 'yyyy')) - 1);
FileName = dir([Path, 'MYD09.A', Yr, ...
    num2str(days(Time - datetime([Yr_1, '-12-31'])), '%.3d'), '*']);
if isempty(FileName)
    FileName = dir([Path, 'MOD09.A', Yr, ...
        num2str(days(Time - datetime([Yr_1, '-12-31'])), '%.3d'), '*']);
end
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

%%
function PlotPSSM(Path, Time, Lon_PSSM, Lat_PSSM)
PolynyaID_PSSM = ncread([Path, datestr(Time, 'yyyymmdd'), '_v0.4.nc'], ...
    'PolynyaIDMap');
PolynyaID_PSSM = double(PolynyaID_PSSM > 0 & ~isnan(PolynyaID_PSSM));
[~, h] = m_contour(double(Lon_PSSM), double(Lat_PSSM), PolynyaID_PSSM, [0.5, 0.5]);
set(h, 'LineWidth', 1.5, 'LineColor', [0.8, 0, 0]);
hold on

Polynya = ncread([Path, datestr(Time, 'yyyymmdd'), '_v0.4.nc'], ...
    'PolynyaIDMap');
Polynya = double(Polynya < 0 & Polynya > -100);
[~, h] = m_contour(double(Lon_PSSM), double(Lat_PSSM), Polynya, [0.5, 0.5]);
set(h, 'LineWidth', 0.75, 'LineColor', [0.8, 0.8, 0]);

end