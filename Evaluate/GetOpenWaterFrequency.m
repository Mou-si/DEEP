clear; close all; clc;

Time = datetime('2004-04-01') : datetime('2022-10-31');
Timetemp = str2double(string(datestr(Time, 'mmdd')));
Time(Timetemp < 400 | Timetemp > 1100) = [];
clear Timetemp
FastIceParameter_125km;

Path = 'G:\AMSR_SIT\36GHz\';
LandMask = ncread('G:\AMSR_SIT\landmask_Antarctic_12.500km.nc', 'z');
OpenWater = zeros(size(LandMask'));
MissCounts = 0;
Timemo = month(Time);
TimemoChange = Timemo(2 : end) - Timemo(1 : end - 1);
TimemoChange = [find(TimemoChange ~= 0), length(Time)];
OpenWatermo = cell(length(TimemoChange), 1);
OpenWatermo{1} = zeros(size(LandMask'));
molength = diff([0, TimemoChange]);
moCount = 1;

for i = 1 : length(Time)
    disp(datestr(Time(i), 'yyyymmdd'))
    try
        SIT = load([Path, datestr(Time(i), 'yyyymmdd'), '.mat']);
    catch
        disp([datestr(Time(i), 'yyyymmdd'), '   MISS'])
        MissCounts = MissCounts + 1;
        molength(moCount) = molength(moCount) - 1;
        continue
    end
    SIT = SIT.h;
    SIT(~logical(LandMask')) = NaN;
    SIT = MaskFastIce(SIT, Time(i), 1);
    OpenWater = OpenWater + double(SIT < 0.1);
    if i > TimemoChange(moCount)
        OpenWatermo{moCount} = OpenWatermo{moCount} ./ molength(moCount);
        moCount = moCount + 1;
        OpenWatermo{moCount} = zeros(size(OpenWater));
    end
    OpenWatermo{moCount} = OpenWatermo{moCount} + double(SIT < 0.1);
end
OpenWatermo{moCount} = OpenWatermo{moCount} ./ molength(moCount);

OpenWater = OpenWater ./ (length(Time) - MissCounts);
OpenWater(~logical(LandMask')) = NaN;

save('C:\Users\13098\Documents\冰间湖识别\DataTrans\SITOpenWaterFrequence.mat', ...
    'OpenWater')