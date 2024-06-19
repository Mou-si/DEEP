close all; clear; clc;
%% read coastal DEEP polynyas
Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d\DEEP_s6250_AMSR_SIC_';
Time = datetime('2003-04-01') : datetime('2022-10-31');
MMDD = str2double(string(datestr(Time, 'mmdd')));
Time = Time(MMDD > 400 & MMDD < 1100);
PolynyaIDs = [];
for i = 1 : length(Time)
    try
        Polynyatemp = ncread([Path, datestr(Time(i), 'yyyymmdd'), '_v1.0.nc'], ...
            'Map');
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

%% plot hist of polynya numbers and area in different open days

% calculate polynya numbers in different open days
clear PolynyaAreaMeanCunsum
PolynyaOccur = PolynyaArea > 0;
PolynyaOccur = reshape(PolynyaOccur, 214, 20, size(PolynyaOccur, 2));
PolynyaOccur(:, 9 : 10, :) = [];
PolynyaOccur = reshape(PolynyaOccur, 214 * 18, size(PolynyaOccur, 3));
PolynyaOccur = sum(double(PolynyaOccur)) ./ 18;
PolynyaOccurCounts = histcounts(PolynyaOccur, [0 : 10 : 200, 220]);

% calculate polynya area in different open days
PolynyaAreaMean = PolynyaArea;
PolynyaAreaMean = reshape(PolynyaAreaMean, 214, 20, size(PolynyaAreaMean, 2));
PolynyaAreaMean(:, 9 : 10, :) = [];
PolynyaAreaMean = reshape(PolynyaAreaMean, 214 * 18, size(PolynyaAreaMean, 3));
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
% Infrequent blue, high red
set(h, 'BarWidth', 1, 'LineWidth', 1, ...
    'CData', [repmat([0, 0, 0.8], 12, 1); repmat([0.8, 0, 0], 9, 1)], 'FaceAlpha', 0.25)
set(gca, 'XColor', 'k', 'YColor', 'k', 'FontSize', 8, ...
    'YLim', [0, 40])
ylabel('Polynya numbers')

% plot area
yyaxis right
h = plot(5 : 10 : 205, PolynyaAreaMeanCunsum);
set(h, 'Marker', 'o', 'MarkerFaceColor', 'k', 'MarkerSize', 2.5, ...
    'LineWidth', 1.5, 'Color', 'k')
hold on
h = plot([120, 120], [0, 100000]);
set(h, 'LineStyle', '--', 'Color', [0.35, 0.35, 0.35], 'LineWidth', 1.5)
set(gca, 'XColor', 'k', 'YColor', 'k', ...
    'YLim', [0, 100000], 'FontSize', 8)
ylabel('Cumulative area (\times10^5 km^2)', 'FontSize', 8)
h = gca;
h.YAxis(2).Exponent = 5; % 10^5

%% weekly polynya area
PolynyaArea2 = PolynyaArea .* 6.25 .* 6.25;
PolynyaArea2 = reshape(PolynyaArea2, 214, 20, size(PolynyaArea2, 2));
PolynyaArea2(:, 9 : 10, :) = [];
PolynyaAreaAll = nanmean(sum(PolynyaArea2, 3), 2);
PolynyaArea120R = PolynyaArea2(:, :, PolynyaOccur >= 120);
PolynyaArea120R = sum(PolynyaArea120R, 3); % high
PolynyaArea120L = PolynyaArea2(:, :, PolynyaOccur < 120);
PolynyaArea120L = sum(PolynyaArea120L, 3); % low

Mo = [30, 31, 30, 31, 31, 30, 31];
Mo = cumsum(Mo);
Mo = [1, Mo(1 : end - 1) + 1; Mo];

subplot(2, 2, 2)

% low
temp = PolynyaArea120L;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 18, 30);
PolynyaArea120LWe = [nanmean(temp); nanstd(temp)];
f=@(a,x)a(1)*cos(2*pi/52*x+a(2))+a(3);
PolynyaArea120LWrfit = ...
    nlinfit(1 : length(PolynyaArea120LWe), PolynyaArea120LWe(1, :), ...
    @(a,x)f(a,x), [250, -10, 500]);
yyaxis left
ErrorBarPlot(6 : 7 : 214, PolynyaArea120LWe(1, :), PolynyaArea120LWe(2, :) ./ 2, ...
    'line', 'LineWidth', 1.5, 'Color', [0, 0, 0.7], ...
    'error', 'FaceAlpha', 0.1)
ylabel('Infrequent (\times10^4 km^2)')
set(gca, 'YColor', [0, 0, 0.5], 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [8000, 40000], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)

% high
temp = PolynyaArea120R;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 18, 30);
PolynyaArea120RWe = [nanmean(temp); nanstd(temp)];
f=@(a,x)a(1)*cos(2*pi/52*x+a(2))+a(3);
PolynyaArea120RWrfit = ...
    nlinfit(1 : length(PolynyaArea120RWe), PolynyaArea120RWe(1, :), ...
    @(a,x)f(a,x), [1500, -10, 3000]);
yyaxis right
ErrorBarPlot(6 : 7 : 214, PolynyaArea120RWe(1, :), PolynyaArea120RWe(2, :) ./ 2, ...
    'line', 'LineWidth', 1.5, 'Color', [0.7, 0, 0], ...
    'error', 'FaceAlpha', 0.1)
ylabel('Frequent (\times10^5 km^2)')
set(gca, 'YColor', [0.5, 0, 0], 'XColor', 'k')
set(gca, 'XLim', [0, 215], 'YLim', [20000, 180000], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'YTick', 40000 : 40000 : 160000, ...
    'FontSize', 8)

%% weekly mean are per-polynya
PolynyaArea2 = PolynyaArea .* 6.25 .* 6.25;
PolynyaArea2 = reshape(PolynyaArea2, 214, 20, size(PolynyaArea2, 2));
PolynyaArea2(:, 9 : 10, :) = [];
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
temp = reshape(temp, 7 * 18, 30);
PolynyaArea120LMWe = [nanmean(temp); nanstd(temp)];
yyaxis left
ErrorBarPlot(6 : 7 : 214, PolynyaArea120LMWe(1, :), PolynyaArea120LMWe(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0, 0, 0.7], ...
    'error', 'FaceAlpha', 0.1)
ylabel('Infrequent (\times10^3 km^2)')
set(gca, 'YColor', [0, 0, 0.5], 'XColor', 'k')
set(gca, 'XLim', [0, 215], ...
    'XTick', Mo(1, 1 : 2 : end), 'XTickLabel', {'Apr', 'Jun', 'Aug', 'Oct'}, ...
    'FontSize', 8)
h = gca;
h.YAxis(1).Exponent = 3;  % 10^3

temp = PolynyaArea120R;
temp = reshape(temp(3 : end - 2, :), 7, 30, size(temp, 2));
temp = permute(temp, [1, 3, 2]);
temp = reshape(temp, 7 * 18, 30);
PolynyaArea120RMWe = [nanmean(temp); nanstd(temp)];
yyaxis right
ErrorBarPlot(6 : 7 : 214, PolynyaArea120RMWe(1, :), PolynyaArea120RMWe(2, :) ./ 2, ...
    'line', 'LineStyle', '-', 'LineWidth', 1.5, 'Color', [0.7, 0, 0], ...
    'error', 'FaceAlpha', 0.1)
ylabel('Frequent (\times10^3 km^2)')
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