close all; clear; clc;
DEEPPath = 'G:\AAPSResults\AMSR_SIC60_6.25km_14d\AAPS_s3125_AMSR_SIC_';

MODISPath = 'G:\MODIS\MRP_SWATH\09\';
RDataSetName = '/Data Fields/EV_250_Aggr500_RefSB';
GBDataSetName = '/Data Fields/EV_500_RefSB';

SITPath = 'C:\Users\13098\Documents\Data\SMOS_Icethickness\SMOS_Icethickness_v3.2_south_';
Lon12500 = ncread([SITPath, '20100415.nc'], 'longitude');
Lat12500 = ncread([SITPath, '20100415.nc'], 'latitude');

Time = [datetime('2017-09-01') : datetime('2017-10-15')];

color = load('C:\Users\13098\Documents\MATLAB\Othertools\colorbar\MPL_GnBu.rgb');
color = ColorbarRemap(color, 35);
color = [repmat(color(1, :), 10, 1); color; repmat(color(end, :), 5, 1)];

count = 0;
for Dayi = [2, 7, 9, 15, 23, 25, 26, 30, 36, 40, 44] % what image is not such cloudy
    count = count + 1;
    FileName = dir([MODISPath, 'MOD09.A2017', ...
        num2str(days(Time(Dayi) - datetime('2016-12-31'))), '*']);
    FileName = cat(1, FileName.name);
    FileName = flipud(FileName);、
    
    %% vs. MODIS
    subplot(4, 6, count * 2 - 1)
    m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [10, -67.5], 'rec', 'on')
    
    % plot MODIS
    PlotMODIS(MODISPath, Time(Dayi))
    
    % plot DEEP polynyas
    PlotDEEP(AASPPath, Time(Dayi), Lon_PSSM, Lat_PSSM)
    
    m_grid('XaxisLocation', 'top', 'FontSize', 8)
    
    %% vs. SMOS SIT
    subplot(4, 6, count * 2)
    m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [10, -67.5], 'rec', 'on')
    
    % plot SMOS SIT
    SIT = ncread([SITPath, datestr(Time(Dayi), 'yyyymmdd'), '.nc'], 'sea_ice_thickness');
    SIT = SIT .* 100;
    h = m_pcolor(Lon12500, Lat12500, SIT);
    set(h, 'LineStyle', 'None');
    set(gca, 'CLim', [0, 50])
    colormap(flipud(color))
    
    % plot DEEP polynyas
    PlotDEEP(DEEPPath, Time(Dayi), Lon_PSSM, Lat_PSSM)
    m_grid('XaxisLocation', 'top', 'FontSize', 8)
    
end
AxShareTick('m_map', 1, 'Gap', [0.4, 0.2])
m_AdjudgeTickLabel('all')
cb = colorbar('position', [0.7440 0.1300 0.012 0.1545]);
cb.Ticks = [0, 25, 50];
ColorbarArrowOuter('low', 0)
set(gcf, 'units', 'centimeter', 'position', [0, 0, 17, 12.5])

%% plot 2004 and 2016
% vs. MODIS only
Lon_DEEP = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Longitudes');
Lat_DEEP = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Latitudes');

figure
% 2004
subplot(1, 6, 1)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [10, -67.5], 'rec', 'on')
PlotMODIS(MODISPath, datetime('2004-10-09'));
hold on
PlotDEEP(DEEPPath, datetime('2004-10-09'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'xtixk', [], 'ytixk', [], 'box', 'off')

subplot(1, 6, 2)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [10, -67.5], 'rec', 'on')
PlotMODIS(MODISPath, datetime('2004-10-15'));
hold on
PlotDEEP(DEEPPath, datetime('2004-10-15'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'xtixk', [], 'ytixk', [], 'box', 'off')

% 2016
subplot(1, 6, 3)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [10, -67.5], 'rec', 'on')
PlotMODIS(MODISPath, datetime('2016-08-14'));
hold on
PlotDEEP(DEEPPath, datetime('2016-08-14'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'xtixk', [], 'ytixk', [], 'box', 'off')

subplot(1, 6, 4)
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [10, -67.5], 'rec', 'on')
PlotMODIS(MODISPath, datetime('2016-08-16'));
hold on
PlotDEEP(DEEPPath, datetime('2016-08-16'), Lon_DEEP, Lat_DEEP)
m_grid('XaxisLocation', 'top', 'FontSize', 8, 'xtixk', [], 'ytixk', [], 'box', 'off')

AxShareTick('m_map', 1, 'Gap', [0.4, 0.2])
set(gcf, 'units', 'centimeter', 'position', [0, 0, 17, 12.5])

%% study region
figure
m_proj('Azimuthal Equal-area', 'lon', 0, 'lat', -90, 'rad', 30.001)
m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
hold on
m_plot([3, 10], [-65, -67.5])
m_grid('fontname', 'Times New Roman', 'fontsize', 8.5, 'XaxisLocation', 'top',...
    'xtick', -180 : 30 : 180, 'ytick', -80 : 10 : -50, ...
    'xticklabels', {}, 'yticklabels', {})

%% plot MODIS
function PlotMODIS(Path, Time)
RDataSetName = '/MODIS SWATH TYPE L2/Data Fields/500m Surface Reflectance Band 1';
GDataSetName = '/MODIS SWATH TYPE L2/Data Fields/500m Surface Reflectance Band 4';
BDataSetName = '/MODIS SWATH TYPE L2/Data Fields/500m Surface Reflectance Band 3';
Yr = datestr(Time, 'yyyy');
Yr_1 = num2str(str2double(datestr(Time, 'yyyy')) - 1);
FileName = dir([Path, 'MOD09.A', Yr, ...
    num2str(days(Time - datetime([Yr_1, '-12-31'])), '%.3d'), '*']);
if isempty(FileName)
    FileName = dir([Path, 'MYD09.A', Yr, ...
        num2str(days(Time - datetime([Yr_1, '-12-31'])), '%.3d'), '*']);
end
FileName = cat(1, FileName.name);
for i = 1 : size(FileName, 1)
    Lon = hdfread([Path, FileName(i, :)], '/Geolocation Fields/Longitude');
    Lat = hdfread([Path, FileName(i, :)], '/Geolocation Fields/Latitude');
    
    R = hdfread([Path, FileName(i, :)], RDataSetName);
    R(R == 65535) = NaN; % 65535 is fill number 
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
PolynyaIDMap = ncread([Path, datestr(Time, 'yyyymmdd'), '_v0.4.nc'], ...
    'PolynyaIDMap');
if isempty(PolynyaIDMap)
    error([datestr(Time, 'yyyymmdd'), ' MODIS Missed'])
end

% plot polynyas
PolynyaIDMap2 = double(PolynyaIDMap > 0 & ~isnan(PolynyaIDMap));
[~, h] = m_contour(double(Lon_PSSM), double(Lat_PSSM), PolynyaIDMap2, [0.5, 0.5]);
set(h, 'LineWidth', 1.5, 'LineColor', [0.8, 0, 0]);
hold on

% plot the other open waters
PolynyaIDMap3 = PolynyaIDMap < 0 & PolynyaIDMap > -100;
[~, h] = m_contour(double(Lon_PSSM), double(Lat_PSSM), double(PolynyaIDMap3), [0.5, 0.5]);
set(h, 'LineWidth', 0.75, 'LineColor', [0.8, 0.8, 0]);
end