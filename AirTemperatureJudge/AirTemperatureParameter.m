function TempeJudgeFlag = AirTemperatureParameter
% Parameters for HeatLoss Mode.
% You should call this function in the NameList.m. If not, the heat loss
% mode will be considered off.
% 
% Output
%   TempeJudgeFlag    a logical value represent if hte heat loss mode is
%                   turned on.
%
% % Ranalysis file path, name and variable name
%   T2m_FileDir     : path of the folder with reanalysis data.
%   T2m_Files1      : the part before the time of the reanalysis data file
%                     name. The full file name is 
%                     [Heat_Files1 Time Heat_Files2].
%   T2m_TimeForm    : format of Date in the name of reanalysis data file.
%                     See more in the formatOut of datestr.
%   T2m_Files2      : the part after the time of the reanalysis data file 
%                     name. The full file name is 
%                     [Heat_Files1 Time Heat_Files2].
%   T2m_Name        : the variable name for 2m air temperature in the
%                     reanalysis data.                                 (K)
% % Parameters
%   T_Ocean         : The surface temperature of ocean. In polar, it can be
%                     setted as a constant of freezing temperature     (K)
%   T_DiffThreshold : The Threshold for the difference between the ocean
%                     and air temperature                              (K)

global T2m_FileDir     T2m_Files1     T2m_TimeForm     T2m_Files2   T2m_Name
global T_Ocean        T_DiffThreshold

T2m_FileDir     = 'G:\ERA5Data_NH';
T2m_Files1      = 'ERA5-SignalLevel-T2m';
T2m_TimeForm	= 'yyyymmdd';
T2m_Files2      = '.nc';
T2m_Name        = 't2m';

T_Ocean         = 273.15 - 1.86;
T_DiffThreshold  = 5;

%% get axis
ReanalysisLonLat;

%% Flag for turn on the HeatLoss
% if this function (HeatLossParms) is run, the HeatLossFlag will be true,
% and the main function will know the heat loss is turned on.
TempeJudgeFlag = true;

%% subfunction for axis of reanalysis data
function ReanalysisLonLat
% % the longitude and latitude of reanalysis data
%   LonTempe             : a vector for the longitude of reanalysis data
%   LonTempe             : a vector for the latitude of reanalysis data
% % Make the range longitude to [0, 360]
%   TempeReArrange   : where is the meridian

global LonTempe          LatTempe
global TempeReArrange

% read lon and lat
if ~isequal(T2m_Files2(end - 2 : end), '.nc')
    error('Input reanalysis data should be in .nc format');
end
OneFile = dir(fullfile(T2m_FileDir, [T2m_Files1, '*', T2m_Files2]));
try
    FileDirtemp = fullfile(T2m_FileDir, OneFile(1).name);
catch
    error(['The <strong>reanalysis data file</strong> for WarmSeason Mode hasn''t be found.', ...
        newline, 'Path: ', T2m_FileDir, ['\', T2m_Files1, '*', T2m_Files2]])
end
LonTempe = ncread(FileDirtemp, 'longitude');
LatTempe = ncread(FileDirtemp, 'latitude');

% make range of lon 0 to 360
if min(LonTempe) < 0
    LonTempe(LonTempe < 0) = 360 + LonTempe(LonTempe < 0);
end

% find the position of meridian and make the first lon 0.
[~, PositionMinLon] = min(LonTempe);
[~, PositionMaxLon] = max(LonTempe);
if abs(PositionMaxLon - PositionMinLon) == 1
    LonTempe = [LonTempe(PositionMinLon : end); LonTempe(1 : PositionMaxLon)];
    TempeReArrange = PositionMaxLon;
else
    TempeReArrange = 0;
end
LonTempe = [LonTempe; 360];

% meshgrid the lon and lat
[LatTempe, LonTempe] = meshgrid(LatTempe, LonTempe);
end

end
