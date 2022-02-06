function [Time, StartTime,...
    SICDir, SICFileName1, SICFileName2, SICLon, SICLat, LandMask, ...
    Lim, ...
    SeriesLength, FrequencyThreshold, MapRange, ...
    HeatLossFlag, ...
    RestartDir, RestartStride]...
    = NameList
% Name list of main
% you can run the function by FindPolyunyaMain.m

%% Time
Time = ... The time you want to identify polynyas
    datetime('2016-04-15') : datetime('2017-03-01');
StartTime = Time(1);

%% Read Data
% we will read data as [SICDir \ SICFileName1 Timestr SICFileName2]
SICDir = ...
    'C:\Users\13098\Documents\Data\Antaratica_ASI_SIC(02-11_12-20)';
SICFileName1 = ...
    'asi-AMSR2-s3125-';
SICFileName2 = ...
    '-v5.4.hdf';
% read the Lon & Lat
SICLon = hdfread(...
    [SICDir, '\LongitudeLatitudeGrid-s3125-Antarctic3125.hdf'], 'Longitudes');
SICLat = hdfread(...
    [SICDir, '\LongitudeLatitudeGrid-s3125-Antarctic3125.hdf'], 'Latitudes');
% read land mask
LandMask = ncread([SICDir, '\LandMaskAMSR3125.nc'], 'LandMask');

%% Cut Open Sea
Lim = ... The threshold for the openwater/ice
    70;

%% Open Water Last
SeriesLength = ... The length of identify time series
    20;
% the FrequencyThreshold is calculated as FrequencyThreshold ./ SeriesLength
FrequencyThreshold = ... the threshold for frequent openwater. it is a 1*2 vector
    [14, 10];

MapRange = ... Remapping for membership of openwater
    [50, 85];

%% Match
global IDCpacity
IDCpacity = ... It is a constant for OverlapDye.m. If it 
    1000000;

%% Physical ID to Logical ID
global ReincarnationTol
ReincarnationTol = ... The tolerance for the Reincarnation
    4;

%% Warm Season
HeatLossFlag = HeatLossParms;

%% BreakPoint
RestartDir = 'C:\Users\13098\Documents\冰间湖识别\Scrip';
RestartStride = 30;
end
% run the function by FindPolyunyaMain.m