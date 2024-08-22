close all; clear; clc;
%% SIT integration map

% time
SIC60Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d\';
SICFiles = dir(SIC60Path);
SICFiles = cat(1, SICFiles(3 : end - 3).name);
SICFiles = SICFiles(:, 21 : 28);
Time = datetime(SICFiles, 'InputFormat', 'yyyyMMdd');
clear Timetemp

% fast ice mask
FastIceParameter_125km;

Path = 'G:\AMSR_SIT\36GHz\';
LandMask = ncread('G:\AMSR_SIT\landmask_Antarctic_12.500km.nc', 'z');
OpenWater = zeros(size(LandMask'));
MissCounts = 0;

for i = 1 : length(Time)
    disp(datestr(Time(i), 'yyyymmdd'))
    
    % read data
    try
        SIT = load([Path, datestr(Time(i), 'yyyymmdd'), '.mat']);
    catch
        disp([datestr(Time(i), 'yyyymmdd'), '   MISS'])
        MissCounts = MissCounts + 1;
        continue
    end
    SIT = SIT.h;
    SIT(~logical(LandMask')) = NaN;
    SIT = MaskFastIce(SIT, Time(i), 1);
    OpenWater = OpenWater + double(SIT < 0.1);
    
    % get open water
    SIT = SIT' < 0.1;
    
    % remove open sea
    SITbw = bwlabel(SIT);
    OpenSea = regionprops(SITbw, 'Area');
    OpenSea = cat(1, OpenSea.Area);
    OpenSea = find(OpenSea == max(OpenSea), 1);
    SIT(SITbw == OpenSea) = false;
    
    % RSP
    temp = SIT(287 : 348, 198 : 222);
    OhshimaAreaMajor(i, 1) = sum(temp(:));
    % TNBP
    temp = SIT(344 : 360, 182 : 197);
    OhshimaAreaMajor(i, 2) = sum(temp(:));
    % AP
    temp = SIT(172 : 191, 251 : 271);
    OhshimaAreaMajor(i, 3) = sum(temp(:));
    % BeP
    temp = SIT(157 : 176, 333 : 353);
    OhshimaAreaMajor(i, 4) = sum(temp(:));
    % CDP
    temp = SIT(492 : 509, 382 : 399);
    OhshimaAreaMajor(i, 5) = sum(temp(:));
    % MBP
    temp = SIT(486 : 503, 366 : 383);
    OhshimaAreaMajor(i, 6) = sum(temp(:));
    % BaP
    temp = SIT(504 : 543, 339 : 358);
    OhshimaAreaMajor(i, 7) = sum(temp(:));
    % SP
    temp = SIT(520 : 538, 288 : 306);
    OhshimaAreaMajor(i, 8) = sum(temp(:));
    % VBP
    temp = SIT(505 : 523, 240 : 256);
    OhshimaAreaMajor(i, 9) = sum(temp(:));
    % DaP
    temp = SIT(487 : 503, 203 : 222);
    OhshimaAreaMajor(i, 10) = sum(temp(:));
    % DiP
    temp = SIT(461 : 480, 161 : 180);
    OhshimaAreaMajor(i, 11) = sum(temp(:));
    % MP
    temp = SIT(427 : 447, 138 : 157);
    OhshimaAreaMajor(i, 12) = sum(temp(:));
    % RONP
    temp = SIT(197 : 233, 375 : 395);
    OhshimaAreaMajor(i, 13) = sum(temp(:));
    
end
OpenWater = OpenWater ./ (length(Time) - MissCounts);
OpenWater(~logical(LandMask')) = NaN;

OhshimaAreaMajor = OhshimaAreaMajor .* 12.5 .* 12.5;

clearvars -except OhshimaAreaMajor OhshimaAreaAll OpenWater

%% DEEP polynya
close all; clc;
SIC60Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d\';
SICFiles = dir(SIC60Path);
SICFiles = cat(1, SICFiles(3 : end - 3).name);
SIC60map = zeros(1328, 1264);
for i = 1 : length(SICFiles)
    disp(SICFiles(i, :));
    
    % read data
    try
    SIC60mapDaily = ncread([SIC60Path, SICFiles(i, :)], 'Map');
    catch
        continue
    end
    temp = SIC60mapDaily > 100;
    SIC60TotalArea(i) = sum(temp(:));
    SIC60map = SIC60map + double(temp);
    % RSP TNBP AP BeP CDP MBP BaP SP VBP DaP DiP MP RONP
    temp = SIC60mapDaily == 031774780;
    SIC60EachArea(i, 1) = sum(temp(:));
    temp = SIC60mapDaily == 031647750;
    SIC60EachArea(i, 2) = sum(temp(:));
    temp = SIC60mapDaily == 032485730;
    SIC60EachArea(i, 3) = sum(temp(:));
    temp = SIC60mapDaily == 032799720;
    SIC60EachArea(i, 4) = sum(temp(:));
    temp = SIC60mapDaily == 030676680;
    SIC60EachArea(i, 5) = sum(temp(:));
    temp = SIC60mapDaily == 030745700;
    SIC60EachArea(i, 6) = sum(temp(:));
    temp = SIC60mapDaily == 030789680;
    SIC60EachArea(i, 7) = sum(temp(:));
    temp = SIC60mapDaily == 030908672;
    SIC60EachArea(i, 8) = sum(temp(:));
    temp = SIC60mapDaily == 031076660;
    SIC60EachArea(i, 9) = sum(temp(:));
    temp = SIC60mapDaily == 031214670;
    SIC60EachArea(i, 10) = sum(temp(:));
    temp = SIC60mapDaily == 031345660;
    SIC60EachArea(i, 11) = sum(temp(:));
    temp = SIC60mapDaily == 031467660;
    SIC60EachArea(i, 12) = sum(temp(:));
    % manual RONP
    temp = ismember(SIC60mapDaily, [032998750, 033065770, 163042760, 113044760]);
    SIC60EachArea(i, 13) = sum(temp(:));
end
SIC60EachArea = SIC60EachArea .* 6.25 .* 6.25;

for i = 1 : 13
    temp = corrcoef(SIC60EachArea(:, i), OhshimaAreaMajor(:, i));
    OhshimavsDEEP(i) = temp(2);
end

%% plot
Lon = hdfread(...
    'G:\AMSR_SIT\LongitudeLatitudeGrid-s12500-Antarctic.hdf', ...
    'Longitudes');
Lat = hdfread(...
    'G:\AMSR_SIT\LongitudeLatitudeGrid-s12500-Antarctic.hdf', ...
    'Latitudes');

Lon2 = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Longitudes');
Lat2 = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Latitudes');


figure
m_proj('Azimuthal Equal-area', 'lon', 0, 'lat', -90, 'rad', 31)
% m_gshhs_h('patch', [0.8, 0.8, 0.8], 'LineStyle', 'None')
hold on
% h = m_pcolor(Lon, Lat, OpenWater);
% set(h, 'LineStyle', 'None');
m_grid('XaxisLocation', 'top', ...
    'ytick', [-80, -70, -60], 'yticklabels', ['', '', ''], 'FontSize', 8.5)
set(gca, 'CLim', [0, 1])
load('C:\Users\13098\Documents\MATLAB\Othertools\colorbar\MPL_Blues.rgb')
MPL_Blues = ColorbarRemap(MPL_Blues, 85);
MPL_Blues(1 : 5, :) = [];
colormap(MPL_Blues)

load('G:\DEEP-AAShare\SIC60_6.25km_20d\OverviewMap.mat')
OverviewMap = double(OverviewMap > 100);
hold on
[~, h] = m_contour(Lon, Lat, OpenWater, [0.2, 0.2]);
set(h, 'LineColor', 'r')

colorbar('horiz', 'Position', [0, 0.05, 0.5, 0.025])
ColorbarAligning
ColorbarArrowOuter('left', 0)