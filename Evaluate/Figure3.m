close all; clear;  clc;

%% read and plot PIPERS22 SIT

% read
data = readtable('C:\Users\13098\Desktop\PIPERS22.csv');
Time = datetime(cell2mat([data.Date, data.Time]), 'InputFormat', 'MM/dd/yyyyHH:mm');
SITrow = [data.z1, data.z2, data.z3];
SICrow = [data.c1, data.c2, data.c3];
SIT = nansum(SITrow .* (SICrow ./ 10), 2);
SIT(isnan(SITrow(:, 1))) = NaN;

% plot
figure
yyaxis left
h = plot(datenum(Time), SIT, 'LineWidth', 1.5);
set(h, 'Color', [0, 0, .6])
set(gca, 'ylim', [0, 80], 'YTick', 0 : 20 : 80, 'YColor', [0, 0, .7], 'FontSize', 9)
ylabel('Sea Ice Thickness (cm)')

%% plot disition from ship to the polynya edge in DEEP

% location of ship
Lon = data.Longitude;
Lon(Lon < 0) = Lon(Lon < 0) + 360;
Lat = data.Latitude;
% 1 deg in lon is much ledd than 1 deg in lat, it will bring error in
% interpolation. Here we cange the map to polar projection, the error will
% not so significant
m_proj('Azimuthal Equal-area', 'lon', 0, 'lat', -90, 'rad', 32)
[Lon, Lat] = m_ll2xy(Lon, Lat);

% ship-polynya edge disition
DEEPPath = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
DEEPLon = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lon');
DEEPLat = ncread('G:\DEEP-AAShare\SIC60_6.25km_20d\LonLat.nc', 'Lat');
DEEPLon = double(DEEPLon);
DEEPLat = double(DEEPLat);
% smaller region will be faster in interpplation
DEEPLat = DEEPLat(200 : 440, 540 : 720); 
DEEPLon = DEEPLon(200 : 440, 540 : 720);
% as what we do on ship position
m_proj('Azimuthal Equal-area', 'lon', 0, 'lat', -90, 'rad', 32)
[DEEPLon, DEEPLat] = m_ll2xy(DEEPLon, DEEPLat);

for i = 1 : length(Time)
    
    % read data
    try
    PolynyaID = ncread([DEEPPath, datestr(Time(i), 'yyyymmdd'), '_v0.4.nc'], ...
        'PolynyaIDMap');
    catch
        PolynyaDistPSSM(i) = NaN;
        continue
    end
    PolynyaID = PolynyaID(200 : 440, 540 : 720);
    PolynyaID = PolynyaID ~= 0 & ~isnan(PolynyaID);
    
    % every pixels' distance to the polynya
    % outside polynya
    PolynyaIDDist = double(bwdist(PolynyaID));
    % minus the distance from center to edge in one pixel
    PolynyaIDDist = PolynyaIDDist - 0.5 / sqrt(3) * 2;
    % pixels in the polynya
    PolynyaIDDist2 = double(bwdist(~PolynyaID));
    PolynyaIDDist2 = PolynyaIDDist2 + 0.5 / sqrt(3) * 2;
    % combine them two
    PolynyaIDDist(PolynyaIDDist == 0) = -PolynyaIDDist2(PolynyaIDDist == 0);
    
    % ship-polynya distance
    PolynyaDistPSSM(i) = griddata(DEEPLon, DEEPLat, PolynyaIDDist, Lon(i), Lat(i));
end
PolynyaDistPSSM = PolynyaDistPSSM .* 6.25;
PolynyaDistPSSM(PolynyaDistPSSM > 130) = 130;
PolynyaDistPSSM(PolynyaDistPSSM < 0) = 0;

% plot
yyaxis right
h = plot(datenum(Time), PolynyaDistPSSM, 'LineWidth', 1.5);
set(h, 'Color', [.6, 0, 0])
set(gca, 'xlim', [min(datenum(Time)) - 1, max(datenum(Time)) + 1], ...
    'XMinorTick', 'on', 'TickDir', 'out', ...
    'ylim', [0, 130], 'YTick', 0 : 20 : 130, 'Ycolor', [.7, 0, 0], 'FontSize', 9)
datetick('x', 'dd-mmm', 'keeplimits')
ylabel('Distance to polynyas (km)')
set(gcf, 'units', 'centimeters', 'Position', [5, 5, 19.5, 5])

%% band indicates when the ship is in the polynya in our dataset
Timedate = Time;
Timedate = [datenum(Timedate) - 1 / 24, datenum(Timedate) + 1 / 24]; % hourly data
PolynyaPSSM(PolynyaPSSM == 41660750) = 1200; % TNBP
PolynyaPSSM(PolynyaPSSM == 41915780) = 800; % RSP
PolynyaPSSM(PolynyaPSSM == -2) = 400; % Open sea
PolynyaPSSM(PolynyaPSSM == -100) = -400; % Landfast ice mask
% polynyas only
PolynyaPSSM1 = PolynyaPSSM;
PolynyaPSSM1(PolynyaPSSM1 < 500) = NaN;
% open sea only
PolynyaPSSM2 = PolynyaPSSM;
PolynyaPSSM2(PolynyaPSSM2 ~= 400) = NaN;
% landfast ice mask only
PolynyaPSSM3 = PolynyaPSSM;
PolynyaPSSM3(PolynyaPSSM3 ~= -400) = NaN;
% no data only
PolynyaPSSM4 = PolynyaPSSM;
PolynyaPSSM4 = ones(size(PolynyaPSSM4)) * 100;
PolynyaPSSM4(~isnan(PolynyaPSSM)) = NaN;

% plot
% different elements solo will be easier to recise and easier to see in
% MATLAB
figure
% polynyas
h = patch(Timedate', zeros(size(Timedate))', [PolynyaPSSM1; PolynyaPSSM1], ...
    'EdgeColor', 'interp');
set(h, 'LineWidth', 8)
% open sea
hold on
h = patch(Timedate', zeros(size(Timedate))', [PolynyaPSSM2; PolynyaPSSM2], ...
    'EdgeColor', 'interp');
set(h, 'LineWidth', 8)
% landfast ice
hold on
h = patch(Timedate', zeros(size(Timedate))', [PolynyaPSSM3; PolynyaPSSM3], ...
    'EdgeColor', 'interp');
set(h, 'LineWidth', 8)
% no data
hold on
h = patch(Timedate', zeros(size(Timedate))', [PolynyaPSSM4; PolynyaPSSM4], ...
    'EdgeColor', 'interp');
set(h, 'LineWidth', 8)

set(gca, 'xlim', [min(datenum(Time)) - 1, max(datenum(Time)) + 1], ...
    'XMinorTick', 'on', 'TickDir', 'out', 'box', 'on', 'FontSize', 9)
ylabel('Polynya Name')
datetick('x', 'dd-mmm', 'keeplimits')
colormap([1, 1, 1; .8, .8, .8; .5, .5, .8; .4, .4, .4; .1, .1, .1])
set(gcf, 'units', 'centimeters', 'Position', [5, 5, 19, 3])

%% plot the ship track (S Fig. 3)
figure
m_proj('Azimuthal Equal-area', ...
    'lon', 180, 'lat', -73, 'rad', [152, -78.3], 'rec', 'on')
m_gshhs_h('patch', [0.8, 0.8, 0.8])
hold on
h = m_plot(Lon, Lat);
set(h, 'LineWidth', 1, 'Color', [0.6, 0, 0])
m_grid
m_AdjudgeTickLabel
set(gcf, 'units', 'centimeters', 'Position', [5, 5, 19, 5.5])

figure
m_proj('Azimuthal Equal-area', 'lon', 165.5, 'lat', -75, ...
    'rad', [162.01, -75.8], 'rec', 'on')
m_gshhs_h('patch', [0.8, 0.8, 0.8])
hold on
h = m_plot(Lon, Lat);
set(h, 'LineWidth', 1, 'Color', [0.6, 0, 0])
m_grid
m_AdjudgeTickLabel
set(gcf, 'units', 'centimeters', 'Position', [5, 5, 19, 4])

figure
m_proj('Azimuthal Equal-area', 'lon', 180, 'lat', -90, 'rad', 32)
m_gshhs_h('patch', [0.8, 0.8, 0.8])
hold on
h = m_plot(Lon, Lat);
set(h, 'LineWidth', 1, 'Color', [0.6, 0, 0])
m_grid('fontname', 'Times New Roman', 'fontsize', 8.5, 'XaxisLocation', 'top',...
    'xtick', -180 : 30 : 180, 'ytick', -80 : 10 : -60, ...
    'xticklabels', {}, 'yticklabels', {})
set(gcf, 'units', 'centimeters', 'Position', [5, 5, 19, 11])