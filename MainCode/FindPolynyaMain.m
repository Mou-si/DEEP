function FindPolynyaMain(NameList_Name, varargin)
% the main code to identify, trace the polynya and create the DEEP-AA
% dataset.
% 
% Syntax
%   FindPolynyaMain(NameList)
%   FindPolynyaMain(___, 'clc', clcFlag)
%   FindPolynyaMain(___, 'close', closeFlag)
%   FindPolynyaMain(___, 'diary', diaryFlag)
% 
% Description
%   FindPolynyaMain(NameList) identified, trace the polynya and create a
%       dataset. The "NameList" here is a char of the name of the file 
%       recording parameters of the algorithm.
%   FindPolynyaMain(___, 'clc', clcFlag) the option to clear the commond
%       window. 'on' is defult.
%   FindPolynyaMain(___, 'close', closeFlag) the option to clear figures. 
%       'on' is defult.
%   FindPolynyaMain(___, 'diary', diaryFlag) the option to write the diary, 
%       which is shown on screen. 'off' is defult.
% 
% Examples
%   % Create a polynya dataset basing on the parameters in NameList.m
%   FindPolynyaMain('NameList')
%   % You can find the dataset in the directory of In.Save.Path recorded
%   in NameList.m
%   
%   % Create the dataset with a diary
%   FindPolynyaMain('NameList', 'diary', 'on')
% 
% Input Arguments
%   NameList - Parameter list of the algorithm
%       char | string (vector)
%       specified as a character vector or string indicating the name of
%       the parameter list file of the algorithm. The parameter list file
%       (name list file) should be a .m file and preferably in the same
%       path as this file.
%   clcFlag - on-off of clc
%       'on' (defult) | 'off'
%       the switch turing on/off of the clc command (clear the commond
%       window).
%   closeFlag - on-off of close
%       'on' (defult) | 'off'
%       the switch turing on/off of the close command (close all figures).
%   diaryFlag - on-off of diary
%       'on'|'off' (defult)
%       the switch turing on/off of the diary, which will record what shown
%       on screen and the output file will be named as 'Diary_'+NameList in
%       the path of this script.
% 
% Onput
%   This function will output 1) a dataset of daily edge of each polynya
%   in Antarctica (DEEP-AA dataset); 2) a .txt file recorded the parameters
%   input called 'Input.txt'; 3) a .mat file of the overview map of the
%   polynyas called 'OverviewMap.mat'.
% 
% Tips
%   Please specify only one NameList parameter file at a time. And the
%   warning is important here, so keep "warning on".

closeFlag = true;
clcFlag = true;
DiaryFlag = false;
for i = 1 : length(varargin)
    switch varargin{i}
        case 'close'
            closeFlag = varargin{i + 1};
            if isequal(closeFlag, 'off')
                closeFlag = false;
            end
        case 'clc'
            clcFlag = varargin{i + 1};
            if isequal(clcFlag, 'off')
                clcFlag = false;
            end
        case 'diary'
            DiaryFlag = varargin{i + 1};
            if isequal(DiaryFlag, 'on')
                DiaryFlag = true;
            end
    end
end
if closeFlag
    close all;
end
if clcFlag
    clc;
end
if DiaryFlag
    fprintf(['Diary: ON\nDiary path: ', ...
        fileparts(which(NameList_Name)), '\Diary_', NameList_Name, '\n\n'])
    diary([fileparts(which(NameList_Name)), '\Diary_', NameList_Name])
end
fprintf(['<strong>** ', NameList_Name, ' **</strong>\n\n'])
%% sets
disp(['[', datestr(now), ']   Loading parameters...'])
[path, ~] = fileparts(mfilename('fullpath'));
[path, ~] = fileparts(path);
addpath(genpath(path));
% NameList
In = InputParameters(NameList_Name);
% prepare
if In.StartTime ~= In.TimeTotal(1)
    StartTimestr = datestr(In.StartTime, 'yyyymmdd');
    load([In.RestartDir, '\restart', StartTimestr, '.mat']);
    In.StartTime = datetime(StartTimestr, 'InputFormat', 'yyyyMMdd');
    YearCircle = yeari;
    DayCircle = i;
    TimeBefore = Time(i) - days(In.SeriesLength * 2 + 1);
    TimeAdvance2 = TimeAdvance;
else
    TimeYear = In.TimeTotal - (datetime(['2017-', In.NewYear]) - datetime('2017-01-01'));
    TimeYear = find(diff(year(TimeYear)) > 0) + 1;
    TimeYear = [1, TimeYear(TimeYear > 1); ...
        TimeYear(TimeYear > 1) - 1, length(In.TimeTotal)];
    YearCircle = 1;
    DayCircle = 1;
    TimeBefore = In.TimeTotal(1) - days(In.SeriesLength * 2 + 1); % Where before start read SIC
end
disp(['[', datestr(now), ']   Done'])
Membership.Data = zeros(size(In.SICLat, 1), size(In.SICLat, 2), ...
    In.SeriesLength * 2 + 1, 1, 'single');
Membership.i = [];
MoveMeanSIC.Data = zeros(size(In.SICLat, 1), size(In.SICLat, 2), ...
    In.SeriesLength + 1, 'single');
MoveMeanSIC.i = [];

%% YearCicle
for yeari = YearCircle : size(TimeYear, 2)
    Time = In.TimeTotal(TimeYear(1, yeari) : TimeYear(2, yeari));
    OpenWaterYear = zeros(size(In.SICLon));
if In.StartTime == In.TimeTotal(1)
    % Initial RAM Allocation
    DayCircle = 1;
    LossSIC = 0;
    LossData = false(length(Time), 1);
    LastOpenWater = cell(2, 1);
%     MatchOpenWaterInt = zeros(size(In.SICLat, 1), size(In.SICLat, 2));
%     OpenWaterMergeQuan = 0;
    OpenWaterMergeIDnum = cell(length(Time), 1);
%     OpenWaterApartQuan = 0;
    OpenWaterApartIDnum = cell(length(Time), 1);
%     DeathBook = zeros(size(In.SICLat));
    TotalDeathID = [];
    MaxOpenWater = zeros(2, 1);
    MachineIDSeries = [];
    OpenWaterCurrent = cell(size(TimeYear, 2), 1);
    TotalLastOpenWater.i = [];
end

%%
for i = DayCircle : length(Time)
    %% disp & restart
    if mod(i - 1, In.RestartStride) == 0 && i ~= DayCircle
        disp(['[', datestr(now), ...
            ']   Saving Restart File of ', datestr(Time(i - 1)), '...'])
        RestartFiles = dir([In.RestartDir, 'restart*.mat']);
        RestartFile = ...
            [In.RestartDir, 'restart', datestr(Time(i - 1), 'yyyymmdd'), '.mat'];
        VarName = who;
        VarNameNotSave = [];
        for j = 1 : length(VarName)
            if isequal(VarName{j}, 'Membership') || ...
                    isequal(VarName{j}, 'MoveMeanSIC') || ...
                    isequal(VarName{j}, 'SICCurrent') || ...
                    isequal(VarName{j}, 'OpenWaterCurrenttemp')
                VarNameNotSave = [VarNameNotSave; j];
            end
        end
        VarName(VarNameNotSave) = [];
        save(RestartFile, VarName{:});
        clear VarName VarNameNotSave
        disp(['[', datestr(now), ']   Done.', newline, 'Restart File Path: ', RestartFile])
%       % when you don't have enough disk, delete some RestartFiles
%         for RestartFilei = 1 : length(RestartFiles)
%             if isequal(RestartFiles(RestartFilei).name, 'restartLastTime.mat')
%                 continue
%             end
%             delete([In.RestartDir, ...
%                 cat(1, RestartFiles(RestartFilei).name)])
%         end
    end
    disp(['[', datestr(now), ']   ', ...
        num2str(i + TimeYear(1, yeari) - 1), '/', num2str(length(In.TimeTotal)), ...
        '   ', datestr(Time(i))])
    
    %% Prepare Surround Time SIC Series
    % TimeAdvance means compare with the before Time, now, how much we need
    % to calculate
    TimeAdvance = datenum(Time(i)) - datenum(TimeBefore);
    % TimeAdvance should less than the length of time dim of DataAll
    if TimeAdvance > size(Membership.Data, 3)
        TimeAdvance = size(Membership.Data, 3);
    end
    TimeBefore = Time(i);
    % read needed data and cut open seas
    [Membership, LossSIC] = ReadAndCut(Membership, TimeAdvance, ...
        Time(i) - days(In.SeriesLength) : Time(i) + days(In.SeriesLength), ...
        In.TimeGap, LossSIC, In.SICFile, In.Lim, In.MapRange, In.FastIceFlag);
    if LossSIC ~= 0
        LossData(i) = true;
    end
    
    %% Open Water Last
    % save the yesterday OpenWater
    LastOpenWater{1} = LastOpenWater{2};
    % calculate the SICFrequency
    [LastOpenWater{2}, MoveMeanSIC] = OpenWaterFrequency...
        (Membership, In.SeriesLength, TimeAdvance, In.FrequencyThres, ...
        MoveMeanSIC);
    
    %% Arrange Adjacent Time Open Water Into Same Order
    if i ~= 1
        MaxOpenWater(1) = MaxOpenWater(2);
        [LastOpenWater{2}, IDnumMatch, MaxOpenWater(2), IDnumBye] = ...
            OverlapDye(LastOpenWater{2}, LastOpenWater{1}, 1, MaxOpenWater(1));
    else
        MaxOpenWater(2) = max(LastOpenWater{2}, [], "all");
        IDnumMatch.Give = unique(LastOpenWater{2});
    end
    
    %% Match Current Open Water To Long-lasting Open Water
    if diff(In.MapRange) > 0
        SICCurrent = 1 - Membership.Data(:, :, Membership.i == In.SeriesLength + 1);
        SICCurrent = (SICCurrent + min(In.MapRange) ./ ...
            abs(diff(In.MapRange))) .* abs(diff(In.MapRange));
        % here SICNow is in the range of MapRange, NOT [0, 100] or [0, 1]
        SICCurrent = bwlabel(SICCurrent < In.Lim);
    else
        SICCurrent = ...
            bwlabel(Membership.Data(:, :, Membership.i == In.SeriesLength + 1));
    end
    OpenWaterCurrenttemp = OverlapDye(SICCurrent, LastOpenWater{2});
    OpenWaterYear = OpenWaterYear + double(OpenWaterCurrenttemp ~= 0);
    LastOpenwaterSparse = sparse(LastOpenWater{2});
    OpenWaterCurrenttemp = sparse(OpenWaterCurrenttemp);
    AllIndexIndex = cell(1, MaxOpenWater(2));
    for k = 1 : MaxOpenWater(2)
        AllIndexIndex{1, k} = find(LastOpenwaterSparse == k);
        OpenWaterCurrent{i, k} = find(OpenWaterCurrenttemp == k);
    end
    TotalLastOpen(i, 1 : MaxOpenWater(2)) = AllIndexIndex;
%     save(StoragePath + datestr(Time(i), 'yyyymmdd') + "OpenWater.mat", 'OpenWater');
    
    %% Detect Merging and Seperating of Open Water
    if i ~= 1
        [MergeIDnum, ApartIDnum] = ...
            MergeAndApart(IDnumMatch);
        % Get Merge And Apart Information
        OpenWaterMergeIDnum{i} = MergeIDnum; 
        % OpenWaterMergeIDnum: First row is the open water merge into, the
        % other are the merged open water.
        OpenWaterApartIDnum{i} = ApartIDnum;
        % OpenWaterApartIDnum: First row is the ID of the seperated open
        % water, the other are the open water seperating into.
    end
    
    %% Match Seperating and Reinranation Open Water to Previous Open Water
    if exist('TimeAdvance2', 'var')
        TimeAdvance = TimeAdvance2;
        clear TimeAdvance2
    end
    if i <= 30
        TotalLastOpenWater.i = [i, TotalLastOpenWater.i];
    else
        TotalLastOpenWater.i = TotalLastOpenWater.i + TimeAdvance;
        TotalLastOpenWater.i = mod(TotalLastOpenWater.i - 0.5, 30) + 0.5;
    end
    if i == 1
        TotalLastOpenWater.Data(:, :, i) = LastOpenWater{2};
    else
        for j = TimeAdvance : -1 : 1
            TotalLastOpenWater.Data(:, :, TotalLastOpenWater.i == j) = ...
                LastOpenWater{2};
        end
    end
    if i ~= 1
        [MapStateApart] = ... ,ReinState
            DetectMatchState(TotalLastOpenWater,ApartIDnum); % ,ReincarnationBooktemp
    end
    
    %% Process the Open Water Series along the Time
    if i == 1
        MachineIDSeries(1, :) = 1 : MaxOpenWater(2);
    else
        MachineIDSeries(i, :) = MachineIDSeries(i - 1, :); % Copy the ID of the last day
        [MachineIDSeries, TotalDeathID, TotalAppend] = ...
            ProcessSeries(MachineIDSeries, MergeIDnum, ApartIDnum, ...
            MapStateApart, MaxOpenWater, IDnumBye.Death, TotalDeathID);
        % TotalAppend contain the information of append column, first row
        % is the column copy from, the second row is the column copy to
    end
    
    %% judge season
    if i == 1
        MachineIDList = unique(LastOpenwaterSparse);
        SkipNum = find(~ismember(MachineIDSeries, MachineIDList));
    end
    MachineIDList = MachineIDSeries(i, :);
    MachineIDList(SkipNum) = [];
    MachineIDList = unique(MachineIDList)';
    MachineIDList(isnan(MachineIDList)) = [];
    if In.TempeJudgeFlag
        MeanTempeDiff = TemperatureDiff(LastOpenWater{2}, ...
            MachineIDList, In.SICLon, In.SICLat, Time(i));
        if i == 1
            TempeDiffMat = TemperatureDiffSeries...
                (i, MeanTempeDiff, MachineIDSeries(end, :), MachineIDList);
        else
            TempeDiffMat = TemperatureDiffSeries...
                (i, MeanTempeDiff, MachineIDSeries(end, :), MachineIDList,...
                TempeDiffMat, TotalAppend);
        end
    end
end

disp(['[', datestr(now), ...
    ']   Doing seasonal judgment and linking Machine ID to Manual ID in ', ...
    num2str(year(In.TimeTotal(TimeYear(2, yeari)))), '...'])

% if In.HeatLossFlag
%     WarmSeasonMat = isWarmSeason(MachineIDSeries(end, :), HeatFluxMat);
% else
%     WarmSeasonMat = month(Time) <= 3 | month(Time) >= 11;
%     WarmSeasonMat = repmat(WarmSeasonMat, size(MachineIDSeries, 2), 1);
% end
% MachineIDSeries2 = MachineIDSeries;
% MachineIDSeries2(WarmSeasonMat') = NaN;

if In.TempeJudgeFlag
    GreatTempeDiffMat = isGreatTempeDiff(MachineIDSeries(end, :), TempeDiffMat);
    MachineIDSeries(:, ~GreatTempeDiffMat) = NaN;
else
    GreatTempeDiffMat = false(1, size(MachineIDSeries, 2));
    disp('DO NOT judge whether the difference between the air and ocean temperature.')
end

MachineIDSeries(LossData, :) = NaN;
MachineIDSeries(MachineIDSeries == 0) = NaN;
isOpenWaterCurrent{yeari} = ~cellfun(@isempty, OpenWaterCurrent);
[AllIndex, LogIncludePhy, isOpenWaterCurrent{yeari}] = ...
    PhysicalToLogical(MachineIDSeries, TotalLastOpen, isOpenWaterCurrent{yeari},...
    In.SICLon, In.RebirthOverlapThres, In.SeriesLengthThres, ...
    In.TimeFilterAfter, In.CombineMergeThres, In.MinPolynyaArea);

if yeari ~= 1
    [MachineIDSeriesYear, TotalLastOpenYear, MaxOpenWaterYear, TotalLastOpenWaterYear, ...
        IDYeartoCrossYear, isOpenWaterCurrent{yeari}] = ...
        CrossYearSeries(MaxOpenWaterYear, AllIndex, TotalLastOpenYear,...
        TotalLastOpenWaterYear, MachineIDSeriesYear, isOpenWaterCurrent{yeari}, ...
        In.CrossYearOverlapThres);
else
    TotalLastOpenWaterYear.i = 1;
    TotalLastOpenWaterYear.Data = AllIndex;
    MachineIDSeriesYear = unique(AllIndex)';
    MaxOpenWaterYear(2) = max(MachineIDSeriesYear);
    AllIndexSparse = sparse(AllIndex);
    AllIndexIndex = cell(1, MaxOpenWaterYear(2));
    for k = 1 : MaxOpenWaterYear(2)
        AllIndexIndex{1, k} = find(AllIndexSparse == k);
    end
    TotalLastOpenYear(1, 1 : MaxOpenWaterYear(2)) = AllIndexIndex;
    IDYeartoCrossYear.Give = unique(AllIndexSparse);
    IDYeartoCrossYear.Give = full(IDYeartoCrossYear.Give);
    IDYeartoCrossYear.Give = IDYeartoCrossYear.Give(2 : end);
    IDYeartoCrossYear.Get = unique(AllIndexSparse);
    IDYeartoCrossYear.Get = full(IDYeartoCrossYear.Get);
    IDYeartoCrossYear.Get = IDYeartoCrossYear.Get(2 : end);
    for i = 1 : size(IDYeartoCrossYear.Give, 1)
        isOpenWaterCurrent_temp(IDYeartoCrossYear.Get(i), :) = ...
            isOpenWaterCurrent{yeari}(IDYeartoCrossYear.Give(i), :);
    end
    isOpenWaterCurrent{yeari} = isOpenWaterCurrent_temp;
    clear isOpenWaterCurrent_temp
end

if str2double(datestr(In.TimeTotal(TimeYear(2, yeari)), 'mmdd')) <= ...
        str2double(In.NewYear([1 : 2, 4 : 5]))
    save([In.Cache, '\AAPSCacheforYear', ...
        num2str(year(In.TimeTotal(TimeYear(2, yeari)))-1), '.mat'], ...
        'LogIncludePhy', 'OpenWaterCurrent', 'IDYeartoCrossYear', ...
        'GreatTempeDiffMat');
else
    save([In.Cache, '\AAPSCacheforYear', ...
        num2str(year(In.TimeTotal(TimeYear(2, yeari)))), '.mat'], ...
        'LogIncludePhy', 'OpenWaterCurrent', 'IDYeartoCrossYear', ...
        'GreatTempeDiffMat');
end

clearvars -except CircumPolar DayCircle In LastOpenWater Membership MoveMeanSIC ...
    OpenWaterCurrent path TimeBefore TimeYear YearCircle yeari ...
    MachineIDSeriesYear MaxOpenWaterYear TotalLastOpenYear ...
    TotalLastOpenWaterYear isOpenWaterCurrent DiaryFlag

VarName = who;
save(['C:\Users\13098\Documents\±ù¼äºþÊ¶±ð\Data\tempData', ...
    num2str(yeari + 2003), '.mat'], VarName{:});

In.StartTime = In.TimeTotal(1);
disp(['[', datestr(now), ']   Done']);
end

%% Last Restart
disp(['[', datestr(now), ...
    ']   Saving Restart File of LastTime...'])
RestartFile = ...
    [In.RestartDir, 'restartLastTime.mat'];
VarName = who;
save(RestartFile, VarName{:});
clear VarName
disp(['[', datestr(now), ']   Done.', newline, 'Restart File Path: ', RestartFile])

%% CrossYear
disp(['[', datestr(now), ']   Doing cross year tracking...'])
[IDSeriesYear, AllIndexYear] = CrossYearSeriesCombine...
    (MachineIDSeriesYear, TotalLastOpenYear, isOpenWaterCurrent, ...
    In.SICLon, In.RebirthOverlapThresYear, In.SeriesLengthThresYear, ...
    In.CombineMergeThres, In.SICFile.LandMask, In.Resolution, In.TimeFilterAfter);
disp(['[', datestr(now), ']   Done'])

% disp(['[', datestr(now), ']   Getting years of polynyas'])
% PolynyasYear = GetPolynyasYear(IDSeriesYear);
% disp(['[', datestr(now), ']   Done'])

disp(['[', datestr(now), ']   Detecting coastal polynyas'])
CoastalPolynyas = DetectCoastalPolynyas(AllIndexYear, ...
    In.SICFile.LandMask, In.Resolution);
disp(['[', datestr(now), ']   Done'])

%% Save & last check
disp(['[', datestr(now), ']   Saving results...'])
[PolynyaLoc, IDs] = ...
    SaveResults(TimeYear, In, IDSeriesYear, AllIndexYear, CoastalPolynyas);
disp(['[', datestr(now), ']   Done'])

disp(['[', datestr(now), ']   Saving a overview map...'])
OverviewOverlap = SaveOverviewMap(IDs, PolynyaLoc, ...
    In.SICFile.LandMask, In.SeriesLengthThresYear, In.RebirthOverlapThresYear, ...
    In.Save);
disp(['[', datestr(now), ']   Done'])

disp(['[', datestr(now), ']   Adding the other open waters...'])
SaveOpenWater(In.SICFile, In.TimeGap, In.Save, In.Lim, In.FastIceFlag, ...
    OverviewOverlap)
disp(['[', datestr(now), ']   Done'])

fprintf('\n<strong>** ALL DONE **</strong>\n')
disp(['Output files'' path: ', In.Save.Path, '\'])
fprintf('Using the FindPolynyaIDs.m in \\OverviewMapTool to view the overview map.\n')
load chirp
sound(y,Fs)
diary off
if DiaryFlag
    fprintf(['Diary path: ', ...
        fileparts(which(NameList_Name)), '\Diary_', NameList_Name, '\n'])
end
end