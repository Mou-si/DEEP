function HeatLossFlag = HeatLossParms
% Parameters for HeatLoss Mode.
% You should call this function in the NameList.m. If not, the heat loss
% mode will be considered off.
% 
% Output
%   HeatLossFlag    a logical value represent if hte heat loss mode is
%                   turned on.

%% Read reanalysis data
% % Ranalysis file name and path
%   Heat_FileDir    : path of the folder with reanalysis data.
%   Heat_Files1     : the part before the time of the reanalysis data file
%                     name. The full file name is 
%                     [Heat_Files1 Time Heat_Files2].
%   Heat_TimeForm   : format of Date in the name of reanalysis data file.
%                     See more in the formatOut of datestr.
%   Heat_Files2     : the part after the time of the reanalysis data file 
%                     name. The full file name is 
%                     [Heat_Files1 Time Heat_Files2].
% % Ranalysis variable name
%   Heat_SRDName    : the variable name for downward shortwave radiation in
%                     the reanalysis data.                      (J/hour)
%   Heat_CloudName  : the variable name fortotal cloud cover in the
%                     reanalysis data.                          ([0, 1])
%   Heat_u10mName   : the variable name for 10m U wind component in the
%                     reanalysis data.                          (m/s)
%   Heat_v10mName   : the variable name for 10m V wind component in the
%                     reanalysis data.                          (m/s)
%   Heat_T2mName    : the variable name for 2m air temperature in the
%                     reanalysis data.                          (K)
%   Heat_D2mName    : the variable name for 2m dewpoint temperature in the
%                     reanalysis data.                          (K)
%   Heat_P0Name     : the variable name for surface pressure in the
%                     reanalysis data.                          (Pa)
% % The parameters for ncread
%   Heat_Stride     : space between the variable indices. See more in
%                     ncread.

global Heat_FileDir     Heat_Files1     Heat_Files2     Heat_TimeForm
global Heat_SRDName     Heat_CloudName  Heat_u10mName   Heat_v10mName ...
       Heat_T2mName     Heat_D2mName    Heat_P0Name

Heat_FileDir	= 'D:\ERA5Data';
Heat_Files1     = 'ERA5-SignalLevel-TPDUShortWaveCloud-';
Heat_TimeForm	= 'yyyymmdd';
Heat_Files2     = '.nc';
Heat_SRDName	= 'ssrdc';
Heat_CloudName	= 'tcc';
Heat_u10mName	= 'u10';
Heat_v10mName	= 'v10';
Heat_T2mName	= 't2m';
Heat_D2mName	= 'd2m';
Heat_P0Name     = 'sp';

%% Parameters for calculating sea surface heat flux
% % Shortwave radiation
%   Heat_alpha      : sea surface albedo                        ([0, 1])
% % Longwave radiation
%   Heat_epsilon    : longwave ocean-surface surface emissivity
%   Heat_sigma      : Stefan-Boltzmann constant
% % Turbulence heat flux
%   Heat_rho_a      : density of air                            (kg/m^3)
%   Heat_c_p        : heat capacity of air                      (J/kg K)
%   Heat_L          : enthalpy of vaporization for water        (J/kg)
%   Heat_Ch_a       : the parameter a for Kondo (1975) scheme to calculate
%                     bulk trasfer coefficient of latent heat 
%   Heat_Ch_b       : the parameter b for Kondo (1975) scheme to calculate
%                     bulk trasfer coefficient of latent heat 
%   Heat_Ch_c       : the parameter c for Kondo (1975) scheme to calculate
%                     bulk trasfer coefficient of latent heat 
%   Heat_Ce_a       : the parameter a for Kondo (1975) scheme to calculate
%                     bulk trasfer coefficient of sensible heat 
%   Heat_Ce_b       : the parameter b for Kondo (1975) scheme to calculate
%                     bulk trasfer coefficient of sensible heat 
%   Heat_Ce_c       : the parameter c for Kondo (1975) scheme to calculate
%                     bulk trasfer coefficient of sensible heat 
%   Heat_Ts         : the freezing point of sea water           (K)

global Heat_alpha
global Heat_epsilon     Heat_sigma
global Heat_rho_a       Heat_c_p        Heat_L          Heat_Ch_a...
       Heat_Ch_b        Heat_Ch_c       Heat_Ce_a       Heat_Ce_b...
       Heat_Ce_c        Heat_Ts

Heat_alpha  	= 0.06;
Heat_epsilon    = 0.97;
Heat_sigma      = 5.67 * 1e-8;
Heat_rho_a      = 1.3;
Heat_c_p        = 1004;
Heat_L          = 2.52 * 1e6;
Heat_Ch_a       = 1.15;
Heat_Ch_b       = 0.01;
Heat_Ch_c       = 0;
Heat_Ce_a       = 1.18;
Heat_Ce_b       = 0.01;
Heat_Ce_c       = 0;
Heat_Ts         = 273.15 - 1.86;

%% judge warm season
%   Heat_Threshold      : the threshold to judge if the hear loss on that
%                         day is low.                           (W/m^2)
%   Heat_MovingMeanDays	: the number of days for smoothing mean the hear
%                         loss
%   Heat_MovingMaxDays  : the number of consecutive days of low hear loss
%                         as the Judgment conditions for winter.

global Heat_Threshold

Heat_Threshold  = 6;  % < oceanic heat flux Ackley et al., 2015

%% get axis
ReanalysisLonLat;

%% Flag for turn on the HeatLoss
% if this function (HeatLossParms) is run, the HeatLossFlag will be true,
% and the main function will know the heat loss is turned on.
HeatLossFlag = true;

%% subfunction for axis of reanalysis data
function ReanalysisLonLat
% % the longitude and latitude of reanalysis data
%   LonHeat             : a vector for the longitude of reanalysis data
%   LatHeat             : a vector for the latitude of reanalysis data
% % Make the range longitude to [0, 360]
%   HeatFluxReArrange   : where is the meridian

global LonHeat          LatHeat 
global HeatFluxReArrange

% read lon and lat
if ~isequal(Heat_Files2(end - 2 : end), '.nc')
    error('Input reanalysis data should be in .nc format');
end
OneFile = dir(fullfile(Heat_FileDir, [Heat_Files1, '*', Heat_Files2]));
try
    FileDirtemp = fullfile(Heat_FileDir, OneFile(1).name);
catch
    error(['The <strong>reanalysis data file</strong> for WarmSeason Mode hasn''t be found.', ...
        newline, 'Path: ', Heat_FileDir, ['\', Heat_Files1, '*', Heat_Files2]])
end
LonHeat = ncread(FileDirtemp, 'longitude');
LatHeat = ncread(FileDirtemp, 'latitude');

% make range of lon 0 to 360
if min(LonHeat) < 0
    LonHeat(LonHeat < 0) = 360 + LonHeat(LonHeat < 0);
end

% find the position of meridian and make the first lon 0.
[~, PositionMinLon] = min(LonHeat);
[~, PositionMaxLon] = max(LonHeat);
if abs(PositionMaxLon - PositionMinLon) == 1
    LonHeat = [LonHeat(PositionMinLon : end); LonHeat(1 : PositionMaxLon)];
    HeatFluxReArrange = PositionMaxLon;
else
    HeatFluxReArrange = 0;
end
LonHeat = [LonHeat; 360];

% meshgrid the lon and lat
[LatHeat, LonHeat] = meshgrid(LatHeat, LonHeat);
end

end
