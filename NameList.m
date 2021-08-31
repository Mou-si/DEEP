function [Time,...
    SICDir, SICFileName1, SICFileName2, SICLon, SICLat, ...
    Lim, ...
    SeriesLength, FrequencyThreshold, MapRange]...
    = NameList
% Name list of main
% you can run the function by FindPolyunyaMain.m

%% Time
Time = ... The time you want to identify polynyas
    datetime('2017-10-01') : datetime('2020-10-01');

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
    10000;
end
% run the function by FindPolyunyaMain.m