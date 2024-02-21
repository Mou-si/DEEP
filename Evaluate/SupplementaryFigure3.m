close all; clear; clc;
MODISPath = 'G:\MODIS\MRP_SWATH\09\';
%% 6.25
DEEPPath = 'G:\AAPSResults\AMSR_SIC60_6.25km_20d\AAPS_s3125_AMSR_SIC_';
subplot(1, 2, 1)
Lon_6250 = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Longitudes');
Lat_6250 = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Latitudes');
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [10, -67.5], 'rec', 'on')
PlotMODIS(MODISPath, datetime('2017-09-09'));
hold on
PlotDEEP(DEEPPath, datetime('2017-09-09'), Lon_6250, Lat_6250)
m_grid('XaxisLocation', 'top', 'FontSize', 8)

%% 3.125
DEEPPath = 'G:\AAPSResults\AMSR_SIC60_3.125km_20d\AAPS_s3125_AMSR_SIC_';
subplot(1, 2, 2)
Lon_3125 = hdfread(...
    ['G:\Antaratica_ASI_SIC(02-11_12-20)\', ...
    'LongitudeLatitudeGrid-s3125-Antarctic.hdf'], 'Longitudes');
Lat_3125 = hdfread(...
    ['G:\Antaratica_ASI_SIC(02-11_12-20)\', ...
    'LongitudeLatitudeGrid-s3125-Antarctic.hdf'], 'Latitudes');
m_proj('Azimuthal Equal-area', 'lon', 3, 'lat', -65, 'rad', [10, -67.5], 'rec', 'on')
PlotMODIS(MODISPath, datetime('2017-09-09'));
hold on
PlotDEEP(DEEPPath, datetime('2017-09-09'), Lon_3125, Lat_3125)
m_grid('XaxisLocation', 'top', 'FontSize', 8)

m_AdjudgeTickLabel('all')

%%
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
function PlotDEEP(Path, Time, Lon, Lat)
PolynyaIDMap = ncread([Path, datestr(Time, 'yyyymmdd'), '_v0.4.nc'], ...
    'PolynyaIDMap');
if isempty(PolynyaIDMap)
    disp('a')
end
PolynyaIDMap2 = double(PolynyaIDMap > 0 & ~isnan(PolynyaIDMap));
[~, h] = m_contour(double(Lon), double(Lat), PolynyaIDMap2, [0.5, 0.5]);
set(h, 'LineWidth', 1.5, 'LineColor', [0.8, 0, 0]);
hold on

PolynyaID_Map3 = PolynyaIDMap < 0 & PolynyaIDMap > -100;
[~, h] = m_contour(double(Lon), double(Lat), double(PolynyaID_Map3), [0.5, 0.5]);
set(h, 'LineWidth', 0.75, 'LineColor', [0.8, 0.8, 0]);

end