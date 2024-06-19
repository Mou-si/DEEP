function FastIceFlag = FastIceParameter
% The function is used to set the parameter of Land Fast Ice Mask mode.
% Now this functio is applied to the Fraser landfast-ice mask and NIC 
% landfast-ice. You can download it here (doi:10.26179/5d267d1ceb60c 
% and doi: 10.7265/46cc-3952) and some pretreatment is needed.

global FastIce

FastIce.TimeCover = {datetime('2000-01-01') : datetime('2018-02-28'), ...
    datetime('2018-03-01') : datetime('2022-12-31')};
FastIce.Dir = {'G:\FraserLandFastIce\nc_12500\', 'G:\NIC\SH\FastIce_12.5\'};
FastIce.Name1 = {'', 'sh_'};
FastIce.Name2 = {'.nc', '.nc'};
FastIce.VarName = {'LandFastIce', 'LandFastIce'};

for i = 1 : length(FastIce.TimeCover)
    TimeCovertemp(i, :) = [min(datenum(FastIce.TimeCover{i})), ...
        max(datenum(FastIce.TimeCover{i}))];
end
FastIce.TimeCover = TimeCovertemp;
clear TimeCovertemp
FastIceFlag = true;
end