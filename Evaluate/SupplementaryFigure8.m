close all; clear; clc;
%% read coastal DEEP polynyas
Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
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
    [Polynyatemp, ~, ic] = unique(Polynyatemp);
    PolynyaAreatemp = accumarray(ic, 1);
    for j = 1 : length(Polynyatemp)
        if mod(Polynyatemp(j), 2) == 1
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

%% calculate polynya numbers in different open days
clear PolynyaAreaMeanCunsum
PolynyaOccur = PolynyaArea > 0;
PolynyaOccur = reshape(PolynyaOccur, 214, 19, size(PolynyaOccur, 2));
PolynyaOccur(:, 8 : 9, :) = [];
PolynyaOccur = reshape(PolynyaOccur, 214 * 17, size(PolynyaOccur, 3));
PolynyaOccur = sum(double(PolynyaOccur)) ./ 17;
PolynyaOccurCounts = histcounts(PolynyaOccur, [0 : 10 : 200, 220]);

%% calculate weekly air condition in low- and high-frequency polynyas

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
figure
subplot(2, 2, 1)
PolynyaArea2 = PolynyaArea .* 6.25 .* 6.25;
PolynyaArea2 = reshape(PolynyaArea2, 214, 19, size(PolynyaArea2, 2));
PolynyaArea2(:, 8 : 9, :) = [];
PolynyaAreaAll = nanmean(sum(PolynyaArea2, 3), 2);
PolynyaArea120R = PolynyaArea2(:, :, PolynyaOccur >= 120);
PolynyaArea120R = sum(PolynyaArea120R, 3);
PolynyaArea120L = PolynyaArea2(:, :, PolynyaOccur < 120);
PolynyaArea120L = sum(PolynyaArea120L, 3);
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
ErrorBarPlot(6 : 7 : 214, PolynyaArea120LWe(1, :), PolynyaArea120LWe(2, :) ./ 2, ...
    'line', 'LineWidth', 1.5, 'Color', [0, 0, 0.7], ...
    'error', 'FaceAlpha', 0.1)
ylabel('Low-frequency (\times10^4 km^2)')
set(gca, 'YColor', [0, 0, 0.5], 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [9000, 60000], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)

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
ErrorBarPlot(6 : 7 : 214, PolynyaArea120RWe(1, :), PolynyaArea120RWe(2, :) ./ 2, ...
    'line', 'LineWidth', 1.5, 'Color', [0.7, 0, 0], ...
    'error', 'FaceAlpha', 0.1)
ylabel('High-frequency (\times10^5 km^2)')
set(gca, 'YColor', [0.5, 0, 0], 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [20000, 180000], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'YTick', 40000 : 40000 : 160000, ...
    'FontSize', 8)

%% weekly mean are per-polynya
subplot(2, 2, 2)
PolynyaArea2 = PolynyaArea .* 6.25 .* 6.25;
PolynyaArea2 = reshape(PolynyaArea2, 214, 19, size(PolynyaArea2, 2));
PolynyaArea2(:, 8 : 9, :) = [];
PolynyaArea120R = PolynyaArea2(:, :, PolynyaOccur >= 120);
PolynyaArea120R(PolynyaArea120R == 0) = NaN;
PolynyaArea120R = nanmean(PolynyaArea120R, 3);
PolynyaArea120L = PolynyaArea2(:, :, PolynyaOccur < 120);
PolynyaArea120L(PolynyaArea120L == 0) = NaN;
PolynyaArea120L = nanmean(PolynyaArea120L, 3);
temp = PolynyaArea120L;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
PolynyaArea120LMWe = [nanmean(temp); nanstd(temp)];
yyaxis left
ErrorBarPlot(6 : 7 : 214, PolynyaArea120LMWe(1, :), PolynyaArea120LMWe(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0, 0, 0.7], ...
    'error', 'FaceAlpha', 0.1)
ylabel('Low-frequency (\times10^3 km^2)')
set(gca, 'YColor', [0, 0, 0.5], 'XColor', 'k')
set(gca, 'XLim', [0, 215], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)
h = gca;
h.YAxis(1).Exponent = 3;

temp = PolynyaArea120R;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 17, 30);
PolynyaArea120RMWe = [nanmean(temp); nanstd(temp)];
yyaxis right
ErrorBarPlot(6 : 7 : 214, PolynyaArea120RMWe(1, :), PolynyaArea120RMWe(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0.7, 0, 0], ...
    'error', 'FaceAlpha', 0.1)
ylabel('High-frequency (\times10^3 km^2)')
set(gca, 'YColor', [0.5, 0, 0], 'XColor', 'k')
set(gca, 'XLim', [0, 215], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)
h = gca;
h.YAxis(2).Exponent = 3;

%% plot T2m
subplot(2, 2, 3)
yyaxis left
ErrorBarPlot(6 : 7 : 214, t2m_120L_We(1, :), t2m_120L_We(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0, 0, 0.7], ...
    'error', 'FaceAlpha', 0.1)
hold on
ErrorBarPlot(6 : 7 : 214, t2m_120R_We(1, :), t2m_120R_We(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0.7, 0, 0], ...
    'error', 'FaceAlpha', 0.1)
set(gca, 'YColor', 'k', 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [-20, -8],...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)
ylabel('Air temperature (℃)')
yyaxis right
set(gca, 'YColor', 'k', 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [-20, -8],...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)
ylabel('Air temperature (℃)')

%% plot winds
subplot(2, 2, 4)
yyaxis left
ErrorBarPlot(6 : 7 : 214, U_120L_We(1, :), U_120L_We(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0, 0, 0.7], ...
    'error', 'FaceAlpha', 0.1)
hold on
ErrorBarPlot(6 : 7 : 214, U_120R_We(1, :), U_120R_We(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0.7, 0, 0], ...
    'error', 'FaceAlpha', 0.1)
set(gca, 'YColor', 'k', 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [5, 10],...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)
ylabel('Wind speed (m s^{-1})')
yyaxis right
% h = errorbar(6 : 7 : 214, Dir_120L_We(1, :), Dir_120L_We(2, :),...
%     'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0, 0, 0.7]);
% hold on
% h = errorbar(6 : 7 : 214, Dir_120R_We(1, :), Dir_120L_We(2, :),...
%     'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0.7, 0, 0]);
set(gca, 'YColor', 'k', 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [5, 10],...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)
ylabel('Wind speed (m s^{-1})')