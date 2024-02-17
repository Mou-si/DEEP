close all; clear; clc;
%% read coastal DEEP polynyas
Path = 'G:\AAPSResults\AMSR_SIC60_6.25km_20d\AAPS_s3125_AMSR_SIC_';
Time = datetime('2004-04-01') : datetime('2022-10-31');
MMDD = str2double(string(datestr(Time, 'mmdd')));
Time = Time(MMDD > 400 & MMDD < 1100);
PolynyaIDs = [];
for i = 1 : length(Time)
    try
        Polynyatemp = ncread([Path, datestr(Time(i), 'yyyymmdd'), '_v0.4.nc'], ...
            'PolynyaIDMap');
    catch
        PolynyaArea(i, :) = NaN;
        continue
    end
    Polynyatemp(Polynyatemp < 100) = 0;
    Polynyatemp(isnan(Polynyatemp)) = 0;
    
    % only need coastal polynyas
    % it will be easier to use the tag in polynya IDs
    CoastalFlag = ncread([Path, datestr(Time(i), 'yyyymmdd'), '_v0.4.nc'], ...
        'CoastalPolynyaFlag');
    PolynyaIDtemp = ncread([Path, datestr(Time(i), 'yyyymmdd'), '_v0.4.nc'], ...
        'PolynyaIDs');
    CoastalFlag = PolynyaIDtemp(~logical(CoastalFlag));
    [Polynyatemp, ~, ic] = unique(Polynyatemp);
    PolynyaAreatemp = accumarray(ic, 1);
    for j = 1 : length(Polynyatemp)
        if ismember(Polynyatemp(j), CoastalFlag)
            continue
        end
        if ~ismember(Polynyatemp(j), PolynyaIDs)
            PolynyaIDs = [PolynyaIDs; Polynyatemp(j)];
        end
        PolynyaArea(i, PolynyaIDs == Polynyatemp(j)) = PolynyaAreatemp(j);
    end
end
PolynyaArea(isnan(PolynyaArea(:, 1)), :) = NaN;
PolynyaArea(:, 1) = [];

%% Read air condision
% at least, it was not plotted
load('C:\Users\13098\Documents\冰间湖识别\DataTrans\ERA5Mask.mat')
ERA5Path = 'G:\ERA5Data\ERA5-SignalLevel-TPDUShortWaveCloud-';
for i = 1 : length(Time)
    
    % T2m
    t2mtemp = ncread([ERA5Path, datestr(Time(i), 'yyyymmdd'), '.nc'], 't2m');
    t2mtemp_120R = t2mtemp(PolynyaMask_120R > 0.5);
    t2mtemp_120R = mean(t2mtemp_120R);
    t2m_120R(i) = t2mtemp_120R;
    t2mtemp_120L = t2mtemp(PolynyaMask_120L > 0.5);
    t2mtemp_120L = mean(t2mtemp_120L);
    t2m_120L(i) = t2mtemp_120L;
    
    % wind speed
    utemp = ncread([ERA5Path, datestr(Time(i), 'yyyymmdd'), '.nc'], 'u10');
    utemp_120R = utemp(PolynyaMask_120R > 0.5);
    vtemp = ncread([ERA5Path, datestr(Time(i), 'yyyymmdd'), '.nc'], 'v10');
    vtemp_120R = vtemp(PolynyaMask_120R > 0.5);
    Utemp_120R = sqrt(utemp_120R .^ 2 + vtemp_120R .^ 2);
    U_120R(i) = mean(Utemp_120R);
    utemp_120L = utemp(PolynyaMask_120L > 0.5);
    vtemp_120L = vtemp(PolynyaMask_120L > 0.5);
    Utemp_120L = sqrt(utemp_120L .^ 2 + vtemp_120L .^ 2);
    U_120L(i) = mean(Utemp_120L);
end

%% plot hist of polynya numbers and area in different open days

% calculate polynya numbers in different open days
clear PolynyaAreaMeanCunsum
PolynyaOccur = PolynyaArea > 0;
PolynyaOccur = reshape(PolynyaOccur, 214, 19, size(PolynyaOccur, 2));
PolynyaOccur(:, 8 : 9, :) = [];
PolynyaOccur = reshape(PolynyaOccur, 214 * 17, size(PolynyaOccur, 3));
PolynyaOccur = sum(double(PolynyaOccur)) ./ 17;
PolynyaOccurCounts = histcounts(PolynyaOccur, [0 : 10 : 200, 220]);

% calculate polynya area in different open days
PolynyaAreaMean = PolynyaArea;
PolynyaAreaMean = reshape(PolynyaAreaMean, 214, 19, size(PolynyaAreaMean, 2));
PolynyaAreaMean(:, 8 : 9, :) = [];
PolynyaAreaMean = reshape(PolynyaAreaMean, 214 * 17, size(PolynyaAreaMean, 3));
PolynyaAreaMean = nanmean(double(PolynyaAreaMean));
PolynyaAreaMean = PolynyaAreaMean .* 6.25 .* 6.25;
for i = 10 : 10 : 200
    PolynyaAreaMeanCunsum(i / 10) = sum(PolynyaAreaMean(PolynyaOccur <= i));
end
PolynyaAreaMeanCunsum = [PolynyaAreaMeanCunsum, sum(PolynyaAreaMean)];

figure
subplot(2, 2, 1)

% plot numbers
yyaxis left
h = bar(5 : 10 : 205, PolynyaOccurCounts,'FaceColor','flat');
% low-frequency blue, high red
set(h, 'BarWidth', 1, 'LineWidth', 1, ...
    'CData', [repmat([0, 0, 0.8], 12, 1); repmat([0.8, 0, 0], 9, 1)], 'FaceAlpha', 0.25)
set(gca, 'XColor', 'k', 'YColor', 'k', 'FontSize', 8, ...
    'YLim', [0, 35])
ylabel('Polynya Numbers')

% plot area
yyaxis right
h = plot(5 : 10 : 205, PolynyaAreaMeanCunsum);
set(h, 'Marker', 'o', 'MarkerFaceColor', 'k', 'MarkerSize', 2.5, ...
    'LineWidth', 1.5, 'Color', 'k')
hold on
h = plot([120, 120], [0, 120000]);
set(h, 'LineStyle', '--', 'Color', [0.35, 0.35, 0.35], 'LineWidth', 1.5)
set(gca, 'XColor', 'k', 'YColor', 'k', ...
    'YLim', [0, 120000], 'FontSize', 8)
ylabel('Cumulative Area (\times10^5 km^2)', 'FontSize', 8)
h = gca;
h.YAxis(2).Exponent = 5; % 10^5

%% calculate weekly air condition in low- and high-frequency polynyas
% not used

% T2m
t2m_120L_We = reshape(t2m_120L, 214, 19, size(t2m_120L, 1));
t2m_120L_We(:, 8 : 9, :) = [];
temp = t2m_120L_We;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
t2m_120L_We = [nanmean(temp); nanstd(temp)];
t2m_120R_We = reshape(t2m_120R, 214, 19, size(t2m_120R, 1));
t2m_120R_We(:, 8 : 9, :) = [];
temp = t2m_120R_We;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
t2m_120R_We = [nanmean(temp); nanstd(temp)];

% wind speed
U_120L_We = reshape(U_120L, 214, 19, size(U_120L, 1));
U_120L_We(:, 8 : 9, :) = [];
temp = U_120L_We;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
U_120L_We = [nanmean(temp); nanstd(temp)];
U_120R_We = reshape(U_120R, 214, 19, size(U_120R, 1));
U_120R_We(:, 8 : 9, :) = [];
temp = U_120R_We;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
U_120R_We = [nanmean(temp); nanstd(temp)];

%% weekly polynya area
PolynyaArea2 = PolynyaArea .* 6.25 .* 6.25;
PolynyaArea2 = reshape(PolynyaArea2, 214, 19, size(PolynyaArea2, 2));
PolynyaArea2(:, 8 : 9, :) = [];
PolynyaAreaAll = nanmean(sum(PolynyaArea2, 3), 2);
PolynyaArea120R = PolynyaArea2(:, :, PolynyaOccur >= 120);
PolynyaArea120R = sum(PolynyaArea120R, 3); % high
PolynyaArea120L = PolynyaArea2(:, :, PolynyaOccur < 120);
PolynyaArea120L = sum(PolynyaArea120L, 3); % low

subplot(2, 2, 2)

% low
temp = PolynyaArea120L;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
PolynyaArea120LWe = [nanmean(temp); nanstd(temp)];
f=@(a,x)a(1)*cos(2*pi/52*x+a(2))+a(3);
PolynyaArea120LWrfit = ...
    nlinfit(1 : length(PolynyaArea120LWe), PolynyaArea120LWe(1, :), ...
    @(a,x)f(a,x), [250, -10, 500]);
yyaxis left
ErrorBarPolt(6 : 7 : 214, PolynyaArea120LWe(1, :), PolynyaArea120LWe(2, :) ./ 2, ...
    'line', 'LineWidth', 1.5, 'Color', [0, 0, 0.7], ...
    'error', 'FaceAlpha', 0.1)
ylabel('Low-frequency (\times10^4 km^2)')
set(gca, 'YColor', [0, 0, 0.5], 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [9000, 60000], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)

% high
temp = PolynyaArea120R;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
PolynyaArea120RWe = [nanmean(temp); nanstd(temp)];
f=@(a,x)a(1)*cos(2*pi/52*x+a(2))+a(3);
PolynyaArea120RWrfit = ...
    nlinfit(1 : length(PolynyaArea120RWe), PolynyaArea120RWe(1, :), ...
    @(a,x)f(a,x), [1500, -10, 3000]);
yyaxis right
ErrorBarPolt(6 : 7 : 214, PolynyaArea120RWe(1, :), PolynyaArea120RWe(2, :) ./ 2, ...
    'line', 'LineWidth', 1.5, 'Color', [0.7, 0, 0], ...
    'error', 'FaceAlpha', 0.1)
ylabel('High-frequency (\times10^5 km^2)')
set(gca, 'YColor', [0.5, 0, 0], 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [20000, 180000], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'YTick', 40000 : 40000 : 160000, ...
    'FontSize', 8)

%% weekly mean are per-polynya
PolynyaArea2 = PolynyaArea .* 6.25 .* 6.25;
PolynyaArea2 = reshape(PolynyaArea2, 214, 19, size(PolynyaArea2, 2));
PolynyaArea2(:, 8 : 9, :) = [];
PolynyaArea120R = PolynyaArea2(:, :, PolynyaOccur >= 120);
PolynyaArea120R(PolynyaArea120R == 0) = NaN;
PolynyaArea120R = nanmean(PolynyaArea120R, 3); % high
PolynyaArea120L = PolynyaArea2(:, :, PolynyaOccur < 120);
PolynyaArea120L(PolynyaArea120L == 0) = NaN;
PolynyaArea120L = nanmean(PolynyaArea120L, 3); % low

subplot(2, 2, 4)
temp = PolynyaArea120L;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
PolynyaArea120LMWe = [nanmean(temp); nanstd(temp)];
yyaxis left
ErrorBarPolt(6 : 7 : 214, PolynyaArea120LMWe(1, :), PolynyaArea120LMWe(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0, 0, 0.7], ...
    'error', 'FaceAlpha', 0.1)
ylabel('Low-frequency (\times10^3 km^2)')
set(gca, 'YColor', [0, 0, 0.5], 'XColor', 'k')
set(gca, 'XLim', [0, 215], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)
h = gca;
h.YAxis(1).Exponent = 3;  % 10^3

temp = PolynyaArea120R;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
PolynyaArea120RMWe = [nanmean(temp); nanstd(temp)];
yyaxis right
ErrorBarPolt(6 : 7 : 214, PolynyaArea120RMWe(1, :), PolynyaArea120RMWe(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0.7, 0, 0], ...
    'error', 'FaceAlpha', 0.1)
ylabel('High-frequency (\times10^3 km^2)')
set(gca, 'YColor', [0.5, 0, 0], 'XColor', 'k')
set(gca, 'XLim', [0, 215], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)
h = gca;
h.YAxis(2).Exponent = 3; % 10^3

%% weekly polynya number
subplot(2, 2, 3)
yyaxis left

% low
h = plot(6 : 7 : 214, PolynyaArea120LWe(1, :) ./ PolynyaArea120LMWe(1, :));
set(h, 'LineWidth', 1.25, 'LineStyle', '-', 'Color', [0, 0, 0.75], ...
    'Marker', 's', 'MarkerFaceColor', 'auto', 'MarkerSize', 4.5)

% high
hold on
h = plot(6 : 7 : 214, PolynyaArea120RWe(1, :) ./ PolynyaArea120RMWe(1, :));
set(h, 'LineWidth', 1.25, 'LineStyle', '-', 'Color', [0.75, 0, 0], ...
    'Marker', 's', 'MarkerFaceColor', 'auto', 'MarkerSize', 4.5)

set(gca, 'XLim', [0, 215], 'YLim', [12, 35], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8, ...
    'XColor', 'k', 'YColor', 'k')
ylabel('Polynya numbers')

% just for beauty
yyaxis right
set(gca, 'XLim', [0, 215], 'YLim', [12, 35], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8, ...
    'XColor', 'k', 'YColor', 'k')

set(gcf, 'Units', 'centimeters', 'Position', [5, 5, 17, 11.7])