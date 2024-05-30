function FastIceFlag = FastIceParameter
% The function is used to set the parameter of Land Fast Ice Mask mode.
% Now this functio is applied to the Fraser land fast-ice mask. You can 
% download it here (doi:10.26179/5d267d1ceb60c) and some pretreatment is
% needed.

global FastIce

FastIce.TimeCover = datetime('2000-01-01') : datetime('2018-02-28');
FastIce.Dir = 'G:\FraserLandFastIce\nc_25000\';
FastIce.Name1 = '';
FastIce.Name2 = '.nc';
FastIce.VarName = 'LandFastIce';

FastIce.TimeCover = [min(datenum(FastIce.TimeCover)), max(datenum(FastIce.TimeCover))];
FastIceFlag = true;
end