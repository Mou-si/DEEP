close all; clear all; clc;
%% sets
% NameList
[Time, StartTime,...
    SICDir, SICFileName1, SICFileName2, SICLon, SICLat, LandMask,...
    Lim, ...
    SeriesLength, FrequencyThreshold, MapRange, ...
    HeatLossFlag, ...
    RestartDir, RestartStride]...
    = NameList;
% initialization
if RestartDir(end) ~= '\'
    RestartDir = [RestartDir, '\'];
end
if StartTime ~= Time(1)
    StartTime = datestr(StartTime, 'yyyymmdd');
    load([RestartDir, '\restart', StartTime, '.mat']);
    CircleStart = i;
else
    CircleStart = 1;
    SeriesLength = SeriesLength - 1;
    TimeBefore = Time(1) - days(SeriesLength * 2 + 1); % Where before start read SIC
    FrequencyThreshold = FrequencyThreshold ./ (SeriesLength + 1);
    FrequencyThreshold = sort(FrequencyThreshold, 'descend');
    % Initial RAM Allocation
    Membership.Data = zeros(size(SICLat, 1), size(SICLat, 2), ...
        SeriesLength * 2 + 1, 1);
    Membership.i = [];
    LastOpenWater = cell(2, 1);
    MoveMeanSIC.Data = zeros(size(SICLat, 1), size(SICLat, 2), ...
        SeriesLength + 1);
    MoveMeanSIC.i = [];
    MatchOpenWater = cell(2, 1);
    MatchOpenWaterInt = zeros(size(SICLat, 1), size(SICLat, 2));
    OpenWaterMergeQuan = 0;
    OpenWaterMergeIDnum = cell(length(Time), 1);
    OpenWaterApartQuan = 0;
    OpenWaterApartIDnum = cell(length(Time), 1);
    DeathBook = zeros(size(SICLat));
    TotalDeathID = [];
    MaxOpenWater = zeros(2, 1);
    MachineIDSeries = [];
    if (max(SICLat(:)) > -50 && min(SICLat(:)) < -80) || ...
            (min(SICLat(:)) < 50 && max(SICLat(:)) > 80) && ...
            abs(max(SICLon(:)) - min(SICLon(:))) > 350 && ...
            median(SICLon(:)) > 160 && median(SICLon(:)) < 200
        CircumPolar = true;
    else
        CircumPolar = false;
    end
end

%%
for i = CircleStart : length(Time)
    %% Prepare Surround Time SIC Series
    % TimeAdvance means compare with the before Time, now, how much we need
    % to calculate
    TimeAdvance = datenum(Time(i)) - datenum(TimeBefore);
    TimeBefore = Time(i);
    % read needed data and cut open seas
    Membership = ReadAndCut(Membership, TimeAdvance, ...
        Time(i) - days(SeriesLength) : Time(i) + days(SeriesLength), ...
        SICDir, SICFileName1, SICFileName2, LandMask, Lim, CircumPolar, MapRange);
    
    %% Open Water Last
    % save the yesterday OpenWater
    LastOpenWater{1} = LastOpenWater{2};
    % calculate the SICFrequency
    [LastOpenWater{2}, MoveMeanSIC] = OpenWaterFrequency...
        (Membership, SeriesLength, TimeAdvance, FrequencyThreshold, ...
        MoveMeanSIC);
    
    %% Arrange Adjacent Time Open Water Into Same Order
    if i ~= 1
        MaxOpenWater(1) = MaxOpenWater(2);
        [LastOpenWater{2}, IDnumMatch, MaxOpenWater(2), IDnumBye] = ...
            OverlapDye(LastOpenWater{2}, LastOpenWater{1}, 1, MaxOpenWater(1));
    else
        MaxOpenWater(2) = max(LastOpenWater{2}, [], "all");
    end
    
    %% Physical ID to Logical ID
    if i ~= 1
        [ReincarnationBooktemp, DeathBook] = Reincarnation( ...
            IDnumBye, DeathBook, LastOpenWater{2}, LastOpenWater{1});
    end
    
    %% Match Current Open Water To Long-lasting Open Water
    SICNow = 1 - Membership.Data(:, :, Membership.i == SeriesLength + 1);
    SICNow = (SICNow + min(MapRange) ./ ...
        abs(diff(MapRange))) .* abs(diff(MapRange));
    % here SICNow is in the range of MapRange, NOT [0, 100] or [0, 1]
    SICCurrent = bwlabel(SICNow < 70);
    MatchOpenWater{1} = MatchOpenWater{2};
    MatchOpenWater{2} = OverlapDye(SICCurrent, LastOpenWater{2});
    LastOpen = LastOpenWater{2};
    OpenWater = MatchOpenWater{2};
%     save(".\test14\"+datestr(Time(i), 'yyyymmdd')+"OpenWater.mat",'OpenWater');
%     save(".\test14\"+datestr(Time(i), 'yyyymmdd')+"LastOpenWater.mat",'LastOpen');
    
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
    if i <= 30
        TotalLastOpenWater(:, :, i) = LastOpen;
    else
        TotalLastOpenWater = TotalLastOpenWater(:, :, 2 : end);
        TotalLastOpenWater = cat(3, TotalLastOpenWater, LastOpen);
    end
    if i ~= 1
        [MapStateApart,ReinState] = ...
            DetectMatchState(TotalLastOpenWater,ApartIDnum,ReincarnationBooktemp);
    end
    
    %% Process the Open Water Series along the Time
    if i == 1
        MachineIDSeries(1, :) = 1 : MaxOpenWater(2);
    else
        MachineIDSeries(i, :) = MachineIDSeries(i - 1, :); % Copy the ID of the last day
        [MachineIDSeries, TotalDeathID, TotalAppend] = ProcessSeries(MachineIDSeries, MergeIDnum, ApartIDnum, ...
            MapStateApart, MaxOpenWater, nonzeros(DeathBook), TotalDeathID, ReincarnationBooktemp, ReinState);
        % TotalAppend contain the information of append column, first row
        % is the column copy from, the second row is the column copy to
    end
    
    %% judge season
    MachineIDList = unique(LastOpenWater{2}, 'stable');
    MachineIDList = MachineIDList(2 : end);
    if HeatLossFlag
        MaxHeatFlux = HeatLoss(LastOpenWater{2}, ...
            MachineIDList, SICLon, SICLat, Time(i));
        if i == 1
            HeatFluxMat = HeatLossSeries...
                (i, MaxHeatFlux, MachineIDSeries(end, :), MachineIDList,...
                LastOpenWater{2}, SICLon, SICLat, Time);
        else
            HeatFluxMat = HeatLossSeries...
                (i, MaxHeatFlux, MachineIDSeries(end, :), MachineIDList,...
                HeatFluxMat, TotalAppend);
        end
    end
    
    %% disp & restart
    if mod(i, RestartStride) == 0
        RestartFiles = dir([RestartDir, 'restart*.mat']);
        save([RestartDir, 'restart', datestr(Time(i), 'yyyymmdd'), '.mat'])
        delete([repmat(RestartDir, size(RestartFiles, 1), 1),cat(1, RestartFiles.name)])
    end
    disp(datestr(Time(i)))
    
    %%
    if day(Time(i), 'dayofyear') == 31 % 01-31
        if HeatLossFlag
            WarmSeasonMat = isWarmSeason(Time(end), ...
                LastOpenWater, MachineIDList, SICLon, SICLat, ...
                length(Time), MachineIDSeries(end, :), HeatFluxMat);
        end
    end
    %% Output Open Water Properties
    %Open Water Area
%     Area = cell2mat(struct2cell(regionprops(MatchOpenWater{2}, 'Area')));
%     OpenWaterArea(i, 1 : length(Area)) = Area;
%     Open Water Centroid
%     OpenWaterCentroid = cell2mat(struct2cell(regionprops(MatchOpenWater{2}, 'Centroid')));
%     y = round(OpenWaterCentroid(2:2:end));
%     x = round(OpenWaterCentroid(1:2:end));
%     OpenWaterNum = unique(MatchOpenWater{2});
%     CenLon = zeros(1,length(y));
%     CenLat = zeros(1,length(y));
%     OpenWaterNum = OpenWaterNum(2 : end);
%     for k = 1 : length(OpenWaterNum)
%         CenLon(OpenWaterNum(k)) = SICLon(y(OpenWaterNum(k)), x(OpenWaterNum(k)));
%         CenLat(OpenWaterNum(k)) = SICLat(y(OpenWaterNum(k)), x(OpenWaterNum(k)));
%     end
%     OpenWaterCenLon(i, 1 : length(y)) = CenLon;
%     OpenWaterCenLat(i, 1 : length(y)) = CenLat;
%     clear CenLon CenLat x y;
%     %% Plot The Matched Open Water
%     figure(i);
%     m_proj('azimuthal equal-area','latitude',-90,'radius',50,'rectbox','on');
%     m_grid('box','on','xaxislocation','top','xtick',[-180:30:180],...
%         'yticklabels',[ ; ],'ytick',[-80 -70 -60],'linewi',1,'tickdir',...
%         'out','FontSize',8,'FontName','times new roman');
%     m_coast('color','k');%内部没有填充，只有海岸线轮廓
%     hold on
%     
%     MatchOpenWaterInt = MatchOpenWater;
%     MatchOpenWaterInt(MatchOpenWaterInt == 0) = nan;
%     h = m_pcolor(SICLon,SICLat,MatchOpenWaterInt);
%     set(h, 'LineStyle', 'None')
%     m_contour(SICLon,SICLat,LastOpenWater(:, :, 2),[1 1],'LineWidth',0.3);
%     hold off
% 
%     print(i,".\compare\test1\"+datestr(Time(i), 'yyyymmdd')+"_test1_20",'-dpng','-r1000');
%     close(i);
end
% save test15_Centroid OpenWaterCenLon OpenWaterCenLat;
% save test15_Area OpenWaterArea;
% save test15_MA OpenWaterMergeIDnum OpenWaterApartIDnum;
% save test15_Final Result