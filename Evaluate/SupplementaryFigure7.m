clear; close all; clc
Path = 'G:\AAPSResults\AMSR_SIC60_6.25km_20d\AAPS_s3125_AMSR_SIC_';
RONPID = [43064760, 53001750, 63078770  122989750];
Lon = hdfread(...
    'G:\Antaratica_ASI_SIC_6250\LongitudeLatitudeGrid-s6250-Antarctic.hdf', ...
    'Longitudes');
Lat = hdfread(...
    'G:\Antaratica_ASI_SIC_6250\LongitudeLatitudeGrid-s6250-Antarctic.hdf', ...
    'Latitudes');

%% 2005
RONPLength = 0;
Year = 2005;
FileName = dir([Path, num2str(Year), '*']);
for i = 1 : length(FileName)
    PolynyaMap = ncread(fullfile(FileName(i).folder, FileName(i).name), ...
        'PolynyaIDMap');
    IDs = ncread(fullfile(FileName(i).folder, FileName(i).name), ...
        'PolynyaIDs');
    Mask(:, :, i) = PolynyaMap < -50 | isnan(PolynyaMap);
    if ~any(ismember(IDs, RONPID))
        continue
    end
    RONP(:, :, i) = ismember(PolynyaMap, RONPID);
    RONPLength = RONPLength + 1;
end

Mask = nanmean(double(Mask), 3);
RONP = nansum(double(RONP), 3);
RONP = RONP > RONPLength * 0.2; % robust extent
RONP = double(RONP);
RONP(RONP == 0) = NaN;

figure
subplot(1, 2, 1)
m_proj('Azimuthal Equal-area', 'lon', -53.5, 'lat', -76, 'rad', [-42, -77.6], 'rec', 'on')
h = m_contourf(Lon, Lat, Mask, [0.5, 0.5]);
hold on
h = m_pcolor(Lon, Lat, RONP);
set(h, 'LineStyle', 'None');
m_grid

%% 2017
RONPLength = 0;
Year = 2017;
FileName = dir([Path, num2str(Year), '*']);
for i = 1 : length(FileName)
    PolynyaMap = ncread(fullfile(FileName(i).folder, FileName(i).name), ...
        'PolynyaIDMap');
    IDs = ncread(fullfile(FileName(i).folder, FileName(i).name), ...
        'PolynyaIDs');
    Mask(:, :, i) = PolynyaMap < -50 | isnan(PolynyaMap);
    if ~any(ismember(IDs, RONPID))
        continue
    end
    RONP(:, :, i) = ismember(PolynyaMap, RONPID);
    RONPLength = RONPLength + 1;
end

Mask = nanmean(double(Mask), 3);
RONP = nansum(double(RONP), 3);
RONP = RONP > RONPLength * 0.2;
RONP = double(RONP);
RONP(RONP == 0) = NaN;

subplot(1, 2, 2)
m_proj('Azimuthal Equal-area', 'lon', -53.5, 'lat', -76, 'rad', [-42, -77.6], 'rec', 'on')
h = m_contourf(Lon, Lat, Mask, [0.5, 0.5]);
hold on
h = m_pcolor(Lon, Lat, RONP);
set(h, 'LineStyle', 'None');
m_grid

m_AdjudgeTickLabel('all')
colormap([0.8, 0, 0])
set(gcf, 'units', 'centimeters', 'Position', [5, 5, 18, 9])

figure
m_proj('Azimuthal Equal-area', 'lon', 0, 'lat', -90, 'rad', 31)
m_gshhs_h('patch', [0.8, 0.8, 0.8])
hold on
m_plot(-53.5, -76, 'r.')
hold on
m_plot(-42, -77.6, 'k.')
m_grid