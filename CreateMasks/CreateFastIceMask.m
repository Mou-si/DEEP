clear; close all; clc;
Lon_FastIce = ncread('C:\Users\13098\Downloads\FastIce_70_2014.nc', 'longitude');
Lon_FastIce = double(MergePixel(Lon_FastIce, 4));
Lon_FastIce(Lon_FastIce < 0) = Lon_FastIce(Lon_FastIce < 0) + 360;
Lat_FastIce = ncread('C:\Users\13098\Downloads\FastIce_70_2014.nc', 'latitude');
Lat_FastIce = double(MergePixel(Lat_FastIce, 4));
Lon_PSSM = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Longitudes');
Lon_PSSM = double(Lon_PSSM);
Lat_PSSM = hdfread(...
    ['G:\Antaratica_ASI_SIC_6250\', ...
    'LongitudeLatitudeGrid-s6250-Antarctic.hdf'], 'Latitudes');
Lat_PSSM = double(Lat_PSSM);
Path_FastIce = 'G:\FraserLandFastIce\fastice_v2_2\FastIce_70_';
SavePath = 'G:\FraserLandFastIce\nc_6250\';
Yr = 2000 : 2018;
for i = 1 : length(Yr)
    disp([Path_FastIce, num2str(Yr(i)), '.nc'])
    LandFastIceRow = ncread([Path_FastIce, num2str(Yr(i)), '.nc'], ...
        'Fast_Ice_Time_series');
    LandFastIceRow = LandFastIceRow > 0;
    for j = 1 : size(LandFastIceRow, 3)
        LandFastIce1{j} = double(MergePixel(LandFastIceRow(:, :, j), 4));
    end
    
    for j = 1 : length(LandFastIce1)
        LandFastIce1{j} = griddata(Lon_FastIce, Lat_FastIce, LandFastIce1{j}, ...
            Lon_PSSM, Lat_PSSM);
        LandFastIce = LandFastIce1{j};
        LandFastIce = ceil(LandFastIce);
        FileName = [SavePath, ...
            num2str(Yr(i)), num2str(ceil(j / 2), '%.2d'), ...
            '_', num2str(ceil(mod(j - 0.5, 2))), '.nc'];
        nccreate(FileName, 'x', ...
            'Datatype', 'int16', ...
            'Dimensions', {'x', size(Lon_PSSM, 1)});
        nccreate(FileName, 'y', ...
            'Datatype', 'int16', ...
            'Dimensions', {'y', size(Lon_PSSM, 2)});
        nccreate(FileName, 'LandFastIce', ...
            'Dimensions', {'x', 'y'}, ...
            'DeflateLevel', 5);
        ncwrite(FileName, 'x', 1 : size(Lon_PSSM, 1));
        ncwrite(FileName, 'y', 1 : size(Lon_PSSM, 2));
        ncwrite(FileName, 'LandFastIce', LandFastIce);
    end
    
end