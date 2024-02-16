clear; clc; close all
Path = 'G:\Antaratica_ASI_SIC_6250\';
Landmask = ncread([Path, 'landmask_Antarctic_6.250km.nc'], ...
    'z');
Landmask = 1 - Landmask;
Landmask = Landmask';
% % Landmask(813 : 910, 1 : 72) = 1;
% % Landmask(961 : 1002, 24 : 51) = 1;
% Landmask(1 : 18, 1 : 23) = 1;
% Landmask = Landmask > 10;
L = bwlabel(~Landmask);
for i = 2 : length(L)
    Landmask(L == i) = 1;
end
Landmask = double(Landmask);
FileName = 'LandMaskAMSR6250.nc';
disp(['Create the LandMask file', newline, ...
    'Path: ' Path, FileName])
try
    nccreate([Path, FileName], 'LandMask', ...
        'Dimensions', {'x', size(Landmask, 1), 'y', size(Landmask, 2)}, ...
        'Datatype', 'double', ...
        'DeflateLevel', 5);
catch NCCreateError
    if strcmp(NCCreateError.identifier, ...
            'MATLAB:imagesci:netcdf:unableToOpenforWrite')
        rethrow(NCCreateError)
    elseif strcmp(NCCreateError.identifier, ...
            'MATLAB:imagesci:netcdf:variableExists')
        warning('The old data in the file will be <strong>OVERWRITTEN</strong>')
    else
        disp(['<strong>UNKNOW ERROR: </strong>', NCCreateError.message]);
        disp(NCCreateError.stack)
    end
end
ncwrite([Path, FileName], 'LandMask', Landmask);