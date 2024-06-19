function In = InputParameters(NameList_Name)
In = eval(NameList_Name);

%% check and print
CheckParameters(In)
PrintIn(In)

%% set
In.MapRange = ... Remapping for membership of openwater
    [In.Lim, In.Lim];

% for OverlapDye.m.
global IDCpacity
IDCpacity = 1000000;

% Season Judgement mode
global T_DiffThreshold
T_DiffThreshold  = 3;

%% 
% Lon to [0-360]
In.SICLon(In.SICLon < 0) = In.SICLon(In.SICLon < 0) + 360;

% RestartDir
if In.RestartDir(end) ~= '\'
    In.RestartDir = [In.RestartDir, '\'];
end

% FrequencyThres to ratio
if In.FrequencyThres(1) > 1
    In.FrequencyThres = In.FrequencyThres ./ (In.SeriesLength + 1);
end
In.FrequencyThres = sort(In.FrequencyThres, 'descend');

% SeriesLength
In.SeriesLength = In.SeriesLength - 1;
end