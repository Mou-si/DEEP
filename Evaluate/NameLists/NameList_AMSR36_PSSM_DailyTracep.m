function In = NameList_AMSR36_PSSM
% Name list of main function
% you can run the function by FindPolyunyaMain.m
% Var Name
%  TIME
%   TimeTotal                   total time needs to detect polynyas
%   StartTime                   time start to detect polynyas, default is
%                               the fisrt of TimeTotal NewYear
%  READ SIC FILES
%   SICFile                     a struct storing the information of SIC
%   |                           files need to be read
%   |-SICFile.Dir               the path of the folder storing SIC files
%   |-SICFile.Name1             name of SIC files before the timestamp
%   |-SICFile.Name2             name of SIC files after the timestamp
%   |-SICFile.LandMask          land mask for SIC files
%   SICLon                      longitude for SIC
%   SICLat                      latitude for SIC
%  DETECT OPEN SEA & ICE
%   Lim                         the threshold for the openwater/ice
%  LASTING OPEN WATER
%   SeriesLength                the length of time series to detect lasting
%                               openwater
%   FrequencyThreshold          the threshold for detecting lasting
%                               openwater
%   MapRange                    remapping to get membership of openwater
%  WARM SEASON
%   HeatLossFlag                is the HeatLoss Mode for judging warm
%                               season on
%  RESTART
%   RestartDir                  path of the folder to store restart files
%   RestartStride               the stride to store a restart file

%%
clear all;
cd C:\Users\13098\Documents\冰间湖识别\Scrip
addpath ./AirTemperatureJudge

%% Time
In.TimeTotal = ... The time you want to identify polynyas
    [datetime('2003-02-01') : datetime('2003-10-15'), ...
    datetime('2004-02-01') : datetime('2011-08-31'), ...
    datetime('2013-04-01') : datetime('2023-01-31')];
% In.TimeTotal = ... The time you want to identify polynyas
%     datetime('2017-02-01') : datetime('2018-01-31');
TimeTotalmmdd = str2double(string(datestr(In.TimeTotal, 'mmdd')));
In.TimeTotal = In.TimeTotal(TimeTotalmmdd >= 0401 & TimeTotalmmdd <= 1031);
% In.TimeTotal = [In.TimeTotal(1 : 2813), datetime('2017-11-01') : datetime('2017-11-15'), In.TimeTotal(2814 : end)];
%     datetime('2014-02-01') : datetime('2015-01-31');

In.TimeGap = [datetime('2003-12-01'), datetime('2012-07-01')];
In.StartTime = In.TimeTotal(1);
In.NewYear = '02-01';

%% Read Data
% we will read data as [SICDir \ SICFileName1 Timestr SICFileName2]
In.SICFile.Dir = ...
    'G:\AMSR36_PSSM';
In.SICFile.Name1 = ...
    {'', '', ''};
In.SICFile.Name2 = ...%     {'-v5.4.hdf'};
    {'-PSSM-AMSR-36.mat', '-PSSM-AMSR-36.mat', '-PSSM-AMSR-36.mat'};
In.SICFile.VarName = ...
    'Polynya';
% read the Lon & Lat
In.SICLon = hdfread(...
    [In.SICFile.Dir, '\LongitudeLatitudeGrid-s12500-Antarctic.hdf'], 'Longitudes');
In.SICLat = hdfread(...
    [In.SICFile.Dir, '\LongitudeLatitudeGrid-s12500-Antarctic.hdf'], 'Latitudes');
% read land mask
In.SICFile.LandMask = ncread([In.SICFile.Dir, '\LandMaskAMSR12500.nc'], 'LandMask');
% set the resolution
In.Resolution = 12.5;

%% Land Fast Ice
In.FastIceFlag = FastIceParameter_125km;

%% Detect Opensea & Ice
In.Lim = ... The threshold for the openwater/ice
    0.5;

%% Lasting Open Water
In.SeriesLength = ... The length of identify time series
    14;
% the FrequencyThreshold is calculated as FrequencyThreshold ./ SeriesLength
In.FrequencyThres = ... the threshold for frequent openwater. it is a 1*2 vector
    [10, 7];

In.MapRange = ... Remapping for membership of openwater
    [0.5, 0.5];

%% Match
global IDCpacity
IDCpacity = ... It is a constant for OverlapDye.m. If it 
    1000000;

%% Physical ID to Logical ID
global ReincarnationTol
ReincarnationTol = ... The tolerance for the Reincarnation
    4;
In.CombineMergeThres = 0.5;
In.MinPolynyaArea = 1;

%% Rebirth
In.RebirthOverlapThres = ...
    0.2 + 0.1;
In.RebirthOverlapThresYear = ...
    0.3;
In.TimeFilterAfter = ...
    14;

%% Warm Season
% In.HeatLossFlag = HeatLossParms;

%% Air Temperature Judge
In.TempeJudgeFlag = AirTemperatureParameter;

%% Cross Year Track
In.CrossYearOverlapThres = ...
    0.2;
In.SeriesLengthThres = ...
    0.3 + 0.1;
In.SeriesLengthThresYear = ...
    0.15;

%% Restart
In.RestartDir = ...
    'C:\Users\13098\Documents\冰间湖识别\Data\tempData';
In.RestartStride = ...
    120;

%% CacheFile
In.Cache = ...
    'C:\Users\13098\Documents\冰间湖识别\Data\tempData';

%% SaveResults
In.Save.Path = ...
    'G:\DEEP-AAShare\PSSM85_12.5km_14d_DailyTracep';
In.Save.FileName1 = ...
    'DEEP_s12500_AMSR_PSSM_';
In.Save.FileName2 = ...
    '_v1.0.nc';

end
% run the function by FindPolyunyaMain.m
