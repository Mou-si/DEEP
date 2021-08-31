close all; clear; clc;
%% sets
% NameList
[Time,...
    SICDir, SICFileName1, SICFileName2, SICLon, SICLat, ...
    Lim, ...
    SeriesLength, FrequencyThreshold, MapRange]...
    = NameList;
% prepare
SeriesLength = SeriesLength - 1;
TimeBefore = Time(1) - days(SeriesLength * 2 + 1); % Where before start read SIC
FrequencyThreshold = FrequencyThreshold ./ (SeriesLength + 1);
FrequencyThreshold = sort(FrequencyThreshold, 'descend');
% Initial RAM Allocation
Membership = zeros(size(SICLat, 1), size(SICLat, 2), SeriesLength * 2 + 1, 1);
LastOpenWater = cell(2, 1);
MoveMeanSIC = zeros(size(SICLat, 1), size(SICLat, 2), SeriesLength + 1);
MatchOpenWater = cell(2, 1);
MatchOpenWaterInt = zeros(size(SICLat, 1), size(SICLat, 2));
OpenWaterMergeQuan = 0;
OpenWaterMergeIDnum = [];
OpenWaterApartQuan = 0;
OpenWaterApartIDnum = [];
DeathBook = zeros(size(SICLat));
ReincarnationBook = {[]};
%%
for i = 1 : 5
    %% Prepare Surround Time SIC Series
    % TimeAdvance means compare with the before Time, now, how much we need
    % to calculate
    TimeAdvance = datenum(Time(i)) - datenum(TimeBefore);
    TimeBefore = Time(i);
    % read needed data and cut open sea
    % we use IncrementalCal to calculate incremental data only to save
    % source
    Membership = IncrementalCal(Membership, TimeAdvance, ...
        @ReadAndCut, Time(i) - days(SeriesLength) : Time(i) + days(SeriesLength), ...
        SICDir, SICFileName1, SICFileName2, Lim, MapRange);
    
    %% Open Water Last
    % save the yesterday OpenWater
    LastOpenWater{1} = LastOpenWater{2};
    % calculate the SICFrequency
    [LastOpenWater{2}, MoveMeanSIC] = OpenWaterFrequency...
        (Membership, SeriesLength, TimeAdvance, FrequencyThreshold, ...
        MoveMeanSIC);
    
    %% Arrange Adjacent Time Open Water Into Same Order
    if i ~= 1
        [LastOpenWater{2}, IDnumMatch, MaxOpenWater, IDnumBye] = ...
            OverlapDye(LastOpenWater{2}, LastOpenWater{1}, 1, MaxOpenWater);
    else
        MaxOpenWater = max(LastOpenWater{2}, [], "all");
    end
    
    %% Logical ID to Physical ID
    if i ~= 1
        [ReincarnationBooktemp, DeathBook] = Reincarnation(...
            IDnumBye, DeathBook, LastOpenWater{2}, LastOpenWater{1});
        ReincarnationBook = [ReincarnationBook; ReincarnationBooktemp];
    end
    
    %% Match Current Open Water To Long-lasting Open Water
    SICNow = 1 - Membership(:, :, SeriesLength + 1);
    SICNow = (SICNow + min(MapRange) ./ ...
        abs(diff(MapRange))) .* abs(diff(MapRange));
    % here SICNow is in the range of MapRange, NOT [0, 100] or [0, 1]
    SICCurrent = bwlabel(SICNow < 70);
    MatchOpenWater{1} = MatchOpenWater{2};
    MatchOpenWater{2} = OverlapDye(SICCurrent, LastOpenWater{2});
    LastOpen = LastOpenWater{2};
    OpenWater = MatchOpenWater{2};
%     save(".\test9_20\"+datestr(Time(i), 'yyyymmdd')+"OpenWater.mat",'OpenWater');
%     save(".\test9_20\"+datestr(Time(i), 'yyyymmdd')+"LastOpenWater.mat",'LastOpen');
    
    %% Detect Merging and Seperating of Open Water
    if i ~= 1
        [MergeIDnum, ApartIDnum] = ...
            MergeAndApart(IDnumMatch);
        % Get Merge And Apart Information
        OpenWaterMergeIDnum = {OpenWaterMergeIDnum; MergeIDnum}; 
        % OpenWaterMergeIDnum: First row is the open water merge into, the
        % other are the merged open water.
        OpenWaterApartIDnum = {OpenWaterApartIDnum; ApartIDnum};
        % OpenWaterApartIDnum: First row is the ID of the seperated open
        % water, the other are the open water seperating into.
    end
    
    %% Output Open Water Properties
%     %Open Water Area
%     Area = cell2mat(struct2cell(regionprops(MatchOpenWater(:, :, 2), 'Area')));
%     OpenWaterArea(i, 1 : length(Area)) = Area;
%     %Open Water Centroid
%     OpenWaterCentroid = cell2mat(struct2cell(regionprops(MatchOpenWater(:, :, 2), 'Centroid')));
%     y = round(OpenWaterCentroid(2:2:end));
%     x = round(OpenWaterCentroid(1:2:end));
%     OpenWaterNum = unique(MatchOpenWater(:, :, 2));
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