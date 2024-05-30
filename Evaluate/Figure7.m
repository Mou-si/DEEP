close all; clear; clc;

MODISPath = 'G:\MODIS\TNBP_SWATH\';
FileName = dir([MODISPath, 'MOD021KM.*']);
FileName = cat(1, FileName.name);
DatesetName = '/Data Fields/EV_1KM_Emissive';
LonName = '/Geolocation Fields/Longitude';
LatName = '/Geolocation Fields/Latitude';

DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
Lon_DEEP = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lon');
Lat_DEEP = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lat');

ERA5Path = 'G:\ERA5Data\ERA5-SignalLevel-TPDUShortWaveCloud-';
Lon_ERA5 = ncread([ERA5Path , '20000624.nc'], 'longitude');
Lat_ERA5 = ncread([ERA5Path , '20000624.nc'], 'latitude');
[Lon_ERA5, Lat_ERA5] = meshgrid(Lon_ERA5, Lat_ERA5);

%% plot B15A event
count = 1;
for i = [1, 3, 8, 13, 24, 30, 31]
    % read MODIS
    Time = datetime('2004-12-31') + days(str2double(FileName(i, 15 : 17)));
    Data = hdfread([MODISPath, FileName(i, :)], DatesetName);
    Lon = hdfread([MODISPath, FileName(i, :)], LonName);
    Lat = hdfread([MODISPath, FileName(i, :)], LatName);
    % that data is too large and my PC always dies when running it. So I
    % change it's size
    x = 1 : size(Data, 2);
    y = 1 : size(Data, 3);
    [x, y] = meshgrid(x, y');
    x = x';
    y = y';
    Lon(Lon < 0) = Lon(Lon < 0) + 360;
    Lon = interp2(y(1 : 5 : end, 1 : 5 : end), x(1 : 5 : end, 1 : 5 : end), ...
        Lon, y, x);
    Lat = interp2(y(1 : 5 : end, 1 : 5 : end), x(1 : 5 : end, 1 : 5 : end), ...
        Lat, y, x);
    Lon = Lon(1 : end - 4, 1 : end - 4);
    Lat = Lat(1 : end - 4, 1 : end - 4);
    Data = Data(end - 4, 1 : end - 4, 1 : end - 4);
    
    % plot
    subplot(4, 4, count * 2)
    m_proj('Azimuthal Equal-area', 'lon', 166, 'lat', -75, ...
        'rad', [162.01, -76.01], 'rec', 'on')
    h = m_pcolor(Lon, Lat, squeeze(Data));
    set(h, 'LineStyle', 'None')
    set(gca, 'CLim', [5500, 10000])
    colormap(flipud(gray))
    
    hold on
    PlotDEEP(DEEPPath, Time, Lon_DEEP, Lat_DEEP)
    
    m_gshhs_h('patch', [0.8, 0.8, 0.8])
    WindU = ncread([ERA5Path , datestr(Time, 'yyyymmdd'), '.nc'], 'u10');
    WindU = WindU(:, :, 1);
    WindV = ncread([ERA5Path , datestr(Time, 'yyyymmdd'), '.nc'], 'v10');
    WindV = WindV(:, :, 1);
    WindU = WindU ./ 2;
    WindV = WindV ./ 2;
    m_quiverSparse(Lon_ERA5', Lat_ERA5', WindU, 6, WindV, 1, 'AutoScale', 'off');
    m_grid

    count = count + 1;
end

%% plot mean state
load('C:\Users\13098\Documents\冰间湖识别\DataTrans\PolynyaFreq_625.mat')
subplot(4, 4, 15)
m_proj('Azimuthal Equal-area', 'lon', 166, 'lat', -75, ...
    'rad', [162.01, -76.01], 'rec', 'on')
h = m_pcolor(double(Lon_DEEP), double(Lat_DEEP), PolynyaMap);
set(h, 'LineStyle', 'None');
load('C:\Users\13098\Documents\MATLAB\Othertools\colorbar\MPL_Blues.rgb')
MPL_Blues = MPL_Blues(1 : end - 10, :);
MPL_Blues = ColorbarRemap(MPL_Blues, 75);
MPL_Blues(1 : 15, :) = [];
MPL_Blues(1, :) = [1, 1, 1];
colormap(MPL_Blues)
set(gca, 'CLim', [0, 0.6])
hold on

m_gshhs_h('patch', [0.8, 0.8, 0.8])
load('C:\Users\13098\Documents\冰间湖产冰量\Data\DataTemp\WindMeanRossSea.mat')
m_quiverSparse(WindMeanLon, WindMeanLat, Windu, 6, Windv, 1, 'AutoScale', 'off');
m_grid

AxShareTick('m_map', 1, 'XAxisLocation', 'top')
m_AdjudgeTickLabel('all')
h = gca;
cb = colorbar('position', ...
    [h.Position(1) + h.Position(3) + 0.05, h.Position(2), 0.015, h.Position(4)]);
cb.Label.String = 'Polynya Frequence';
cb.Label.FontSize = 8;
ColorbarArrowOuter('low', 0);
set(gcf, 'units', 'centimeters');
set(gcf, 'position', [0, 0, 14, 14]);

%% plot polynyas in DEEP
function PlotDEEP(Path, Time, Lon, Lat)
% polynyas
PolynyaID_DEEP = ncread([Path, datestr(Time, 'yyyymmdd'), '_v0.4.nc'], ...
    'PolynyaIDMap');
PolynyaID_DEEP = double(PolynyaID_DEEP > 0 & ~isnan(PolynyaID_DEEP));
[~, h] = m_contour(double(Lon), double(Lat), PolynyaID_DEEP, [0.5, 0.5]);
set(h, 'LineWidth', 1.5, 'LineColor', [0.8, 0, 0]);
hold on

% the other open waters
Polynya = ncread([Path, datestr(Time, 'yyyymmdd'), '_v0.4.nc'], ...
    'PolynyaIDMap');
Polynya = double(Polynya < 0 & Polynya > -100);
[~, h] = m_contour(double(Lon), double(Lat), Polynya, [0.5, 0.5]);
set(h, 'LineWidth', 0.75, 'LineColor', [0.8, 0.8, 0]);

end