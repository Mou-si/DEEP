clear; close all; clc;
Time = datetime('2003-01-01') : datetime('2022-12-31');
MMDD = str2double(string(datestr(Time, 'mmdd')));
Time = Time(MMDD > 400 & MMDD < 1100);
YearLength = 214;
SavePath = 'C:\Users\13098\Documents\冰间湖识别\DataTrans\SensitiveAanlysis2\';

%% PSSM
if 1
%%
Path = 'G:\DEEP-AAShare\PSSM85_12.5km_14d\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_85_14d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM70_12.5km_14d\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_70_14d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM75_12.5km_14d\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_75_14d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM80_12.5km_14d\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_80_14d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM85_12.5km_10d\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_85_10d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM85_12.5km_20d\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_85_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM85_12.5km_14d_DailyTracem\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_85_14d_DailyTracem.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM85_12.5km_14d_DailyTracep\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_85_14d_DailyTracep.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM85_12.5km_14d_YearlyTracem\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_85_14d_YearlyTracem.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM85_12.5km_14d_YearlyTracep\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_85_14d_YearlyTracep.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM85_12.5km_14d_NoFastIce\DEEP_s12500_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'PSSM_12.5km_85_14d_NoFastIce.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\PSSM85_25km_14d\DEEP_s25000_AMSR_PSSM_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 25 * 25;
Area_U = Area_U * 25 * 25;
save([SavePath, 'PSSM_25km_85_14d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');
end

%% SIC
if 1
%%
Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_60_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC30_6.25km_20d\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_30_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC40_6.25km_20d\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_40_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC50_6.25km_20d\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_50_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC70_6.25km_20d\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_70_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC80_6.25km_20d\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_80_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC60_6.25km_10d\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_60_10d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC60_6.25km_14d\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_60_14d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d_DailyTrace-0.1\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_60_20d_DailyTracem.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d_DailyTrace+0.1\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_60_20d_DailyTracep.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d_YearlyTrace-0.1\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_60_20d_YearlyTracem.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d_YearlyTrace+0.1\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_60_20d_YearlyTracep.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d_NoFastIce\DEEP_s6250_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 6.25 * 6.25;
Area_U = Area_U * 6.25 * 6.25;
save([SavePath, 'SIC_6.25km_60_20d_NoFastIce.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC60_3.125km_20d\DEEP_s3125_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 3.125 .* 3.125;
Area_U = Area_U * 3.125 .* 3.125;
save([SavePath, 'SIC_3.125km_60_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');

%%
Path = 'G:\DEEP-AAShare\SIC60_12.5km_20d\DEEP_s12500_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 12.5 * 12.5;
Area_U = Area_U * 12.5 * 12.5;
save([SavePath, 'SIC_12.5km_60_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');
%%
Path = 'G:\DEEP-AAShare\SIC60_25km_20d\DEEP_s25000_AMSR_SIC_';
[Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength);
Area_U = bootstrp(length(Area), @mean, Area);
Area_U = [prctile(Area_U, 2.5), prctile(Area_U, 97.5)];
Area = Area * 25 * 25;
Area_U = Area_U * 25 * 25;
save([SavePath, 'SIC_25km_60_20d.mat'], ...
   'Area', 'Area_U', 'IDs_d', 'IDs_y', 'IDs');
end

%%
function [Area, IDs_d, IDs_y, IDs] = GetAreaNum(Time, Path, YearLength)
Area = nan(size(Time, 2), 1);
IDs_d = cell(size(Time, 1), 1);
for i = 1 : length(Time)
    if mod(i, YearLength) == 1
        IDs_y_temp = [];
    end
    try
        PolynyaMap = ncread([Path, datestr(Time(i), 'yyyymmdd'), '_v1.0.nc'], 'Map');
    catch
        continue
    end
    PolynyaMap = double(PolynyaMap > 100);
    Area(i) = sum(PolynyaMap(:));
    
    PolynyaIDs = ncread([Path, datestr(Time(i), 'yyyymmdd'), '_v1.0.nc'], 'IDs');
    CoastalFlag = ncread([Path, datestr(Time(i), 'yyyymmdd'), '_v1.0.nc'], 'CoastalPolynyaFlag');
    IDs_d{i, 1} = PolynyaIDs(logical(CoastalFlag));
    IDs_d{i, 2} = PolynyaIDs(~logical(CoastalFlag));
    IDs_y_temp = [IDs_y_temp; i];
    if mod(i, YearLength) == 0
        IDs_y{i / YearLength, 1} = unique(cat(1, IDs_d{IDs_y_temp, 1}));
        IDs_y{i / YearLength, 2} = unique(cat(1, IDs_d{IDs_y_temp, 2}));
    end
end
IDs{1} = cat(1, IDs_y{:, 1});
IDs{1} = IDs{1}(~isnan(IDs{1}));
IDs{1} = unique(IDs{1});
IDs{2} = cat(1, IDs_y{:, 2});
IDs{2} = IDs{2}(~isnan(IDs{2}));
IDs{2} = unique(IDs{2});
end