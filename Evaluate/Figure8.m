close all; clear; clc;
Path = 'C:\Users\13098\Documents\冰间湖识别\DataTrans\SensitiveAanlysis2\';
FileName = dir(Path);
for i = 3 : length(FileName)
    temp = FileName(i).name(1 : end - 4);
    temp(temp == '.') = [];
    eval([temp, ' = load(''', Path, FileName(i).name, ''');']);
end

%%
figure
axes('Position', [0.1, 0.62, 0.342, 0.37])
yyaxis left
h = errorbar((1 : 3) + 0.22, ...
    [nanmean(PSSM_125km_85_20d.Area), ...
    nanmean(PSSM_125km_85_14d.Area), ...
    nanmean(PSSM_125km_85_10d.Area)], ...
    [nanstd(PSSM_125km_85_20d.Area), ...
    nanstd(PSSM_125km_85_14d.Area), ...
    nanstd(PSSM_125km_85_10d.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0, 0 ,0.6], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
hold on
h = errorbar((1 : 3) - 0.22, ...
    [nanmean(SIC_625km_60_20d.Area), ...
    nanmean(SIC_625km_60_14d.Area), ...
    nanmean(SIC_625km_60_10d.Area)], ...
    [nanstd(SIC_625km_60_20d.Area), ...
    nanstd(SIC_625km_60_14d.Area), ...
    nanstd(SIC_625km_60_10d.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0.6, 0 ,0], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
set(gca, 'XLim', [0.2, 3.8], 'YLim', [0, 20e4], ...
    'xtick', 1 : 3, 'xticklabel', {'20 days', '14 days', '10 days'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')
ylabel('Area (\times10^5 km^2)', 'FontSize', 8)

yyaxis right
h = bar((1 : 3) - 0.22, ...
    [length(SIC_625km_60_20d.IDs{1}), ...
    length(SIC_625km_60_14d.IDs{1}), ...
    length(SIC_625km_60_10d.IDs{1}); ...
    length(SIC_625km_60_20d.IDs{2}), ...
    length(SIC_625km_60_14d.IDs{2}), ...
    length(SIC_625km_60_10d.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.9, 0.1, 0.1]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.8, 0.1, 0.1]);
h = bar((1 : 3) + 0.22, ...
    [length(PSSM_125km_85_20d.IDs{1}), ...
    length(PSSM_125km_85_14d.IDs{1}), ...
    length(PSSM_125km_85_10d.IDs{1}); ...
    length(PSSM_125km_85_20d.IDs{2}), ...
    length(PSSM_125km_85_14d.IDs{2}), ...
    length(PSSM_125km_85_10d.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.9]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.8]);
set(gca, 'XLim', [0.2, 3.8], 'YLim', [0, 250], ...
    'xtick', 1 : 3, 'xticklabel', {'20 days', '14 days', '10 days'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')

%%
axes('Position', [0.462, 0.62, 0.438, 0.37])
yyaxis left
h = errorbar((3 : 4) + 0.22, ...
    [nanmean(PSSM_125km_85_14d.Area), ...
    nanmean(PSSM_25km_85_14d.Area)], ...
    [nanstd(PSSM_125km_85_14d.Area), ...
    nanstd(PSSM_25km_85_14d.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0, 0 ,0.6], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
hold on
h = errorbar((1 : 4) - 0.22, ...
    [nanmean(SIC_3125km_60_20d.Area), ...
    nanmean(SIC_625km_60_20d.Area), ...
    nanmean(SIC_125km_60_20d.Area), ...
    nanmean(SIC_25km_60_20d.Area)], ...
    [nanstd(SIC_3125km_60_20d.Area), ...
    nanstd(SIC_625km_60_20d.Area), ...
    nanstd(SIC_125km_60_20d.Area), ...
    nanstd(SIC_25km_60_20d.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0.6, 0 ,0], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
set(gca, 'XLim', [0.2, 4.8], 'YLim', [0, 20e4], ...
    'xtick', 1 : 4, 'xticklabel', {'3.125 km', '6.25 km', '12.5 km', '25 km'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')

yyaxis right
h = bar((1 : 4) - 0.22, ...
    [length(SIC_3125km_60_20d.IDs{1}), ...
    length(SIC_625km_60_20d.IDs{1}), ...
    length(SIC_125km_60_20d.IDs{1}), ...
    length(SIC_25km_60_20d.IDs{1}); ...
    length(SIC_3125km_60_20d.IDs{2}), ...
    length(SIC_625km_60_20d.IDs{2}), ...
    length(SIC_125km_60_20d.IDs{2}), ...
    length(SIC_25km_60_20d.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.9, 0.1, 0.1]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.8, 0.1, 0.1]);
h = bar((3 : 4) + 0.22, ...
    [length(PSSM_125km_85_14d.IDs{1}), ...
    length(PSSM_125km_85_14d.IDs{2}); ...
    length(PSSM_25km_85_14d.IDs{1}), ...
    length(PSSM_25km_85_14d.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.9]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.8]);
set(gca, 'XLim', [0.2, 4.8], 'YLim', [0, 250], ...
    'xtick', 1 : 4, 'xticklabel', {'3.125 km', '6.25 km', '12.5 km', '25 km'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')
ylabel('Polynya Numbers', 'FontSize', 8)

%%
axes('Position', [0.1, 0.12, 0.47, 0.38])
yyaxis left
h = errorbar((7 : 10), ...
    [nanmean(PSSM_125km_85_14d.Area), ...
    nanmean(PSSM_125km_80_14d.Area), ...
    nanmean(PSSM_125km_75_14d.Area), ...
    nanmean(PSSM_125km_70_14d.Area)], ...
    [nanstd(PSSM_125km_85_14d.Area), ...
    nanstd(PSSM_125km_80_14d.Area), ...
    nanstd(PSSM_125km_75_14d.Area), ...
    nanstd(PSSM_125km_70_14d.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0, 0 ,0.6], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
hold on
h = errorbar((1 : 6), ...
    [nanmean(SIC_625km_30_20d.Area), ...
    nanmean(SIC_625km_40_20d.Area), ...
    nanmean(SIC_625km_50_20d.Area), ...
    nanmean(SIC_625km_60_20d.Area), ...
    nanmean(SIC_625km_70_20d.Area), ...
    nanmean(SIC_625km_80_20d.Area)], ...
    [nanstd(SIC_625km_30_20d.Area), ...
    nanstd(SIC_625km_40_20d.Area), ...
    nanstd(SIC_625km_50_20d.Area), ...
    nanstd(SIC_625km_60_20d.Area), ...
    nanstd(SIC_625km_70_20d.Area), ...
    nanstd(SIC_625km_80_20d.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0.6, 0 ,0], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
set(gca, 'XLim', [0.2, 10.8], 'YLim', [0, 350000], ...
    'xtick', 1 : 10, ...
    'xticklabel', {'SIC30', 'SIC40', 'SIC50', 'SIC60', 'SIC70', 'SIC80', ...
    'PSSM85', 'PSSM80', 'PSSM75', 'PSSM70'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')
ylabel('Area (\times10^5 km^2)', 'FontSize', 8)

yyaxis right
h = bar((1 : 6), ...
    [length(SIC_625km_30_20d.IDs{1}), ...
    length(SIC_625km_40_20d.IDs{1}), ...
    length(SIC_625km_50_20d.IDs{1}), ...
    length(SIC_625km_60_20d.IDs{1}), ...
    length(SIC_625km_70_20d.IDs{1}), ...
    length(SIC_625km_80_20d.IDs{1}); ...
    length(SIC_625km_30_20d.IDs{2}), ...
    length(SIC_625km_40_20d.IDs{2}), ...
    length(SIC_625km_50_20d.IDs{2}), ...
    length(SIC_625km_60_20d.IDs{2}), ...
    length(SIC_625km_70_20d.IDs{2}), ...
    length(SIC_625km_80_20d.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.7, 'FaceColor', [0.9, 0.1, 0.1]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.7, 'FaceColor', [0.8, 0.1, 0.1]);
h = bar((7 : 10), ...
    [length(PSSM_125km_85_14d.IDs{1}), ...
    length(PSSM_125km_80_14d.IDs{1}), ...
    length(PSSM_125km_75_14d.IDs{1}), ...
    length(PSSM_125km_70_14d.IDs{1}); ...
    length(PSSM_125km_85_14d.IDs{2}), ...
    length(PSSM_125km_80_14d.IDs{2}), ...
    length(PSSM_125km_75_14d.IDs{2}), ...
    length(PSSM_125km_70_14d.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.7, 'FaceColor', [0.1, 0.1, 0.9]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.7, 'FaceColor', [0.8, 0.1, 0.1]);
set(gca, 'XLim', [0.2, 10.8], 'Ylim', [0, 250], ...
    'xtick', 1 : 10, ...
    'xticklabel', ...
    {'SIC30', 'SIC40', 'SIC50', 'SIC60', 'SIC70', 'SIC80', ...
    'PSSM85', 'PSSM80', 'PSSM75', 'PSSM70'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')
ylabel('Polynya Numbers', 'FontSize', 8)

%%
figure
axes('Position', [0.1, 0.62, 0.288, 0.37])
yyaxis left
h = errorbar((1 : 3) + 0.22, ...
    [nanmean(PSSM_125km_85_14d_DailyTracem.Area), ...
    nanmean(PSSM_125km_85_14d.Area), ...
    nanmean(PSSM_125km_85_14d_DailyTracep.Area)], ...
    [nanstd(PSSM_125km_85_14d_DailyTracem.Area), ...
    nanstd(PSSM_125km_85_14d.Area), ...
    nanstd(PSSM_125km_85_14d_DailyTracep.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0, 0 ,0.6], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
hold on
h = errorbar((1 : 3) - 0.22, ...
    [nanmean(SIC_625km_60_20d_DailyTracem.Area), ...
    nanmean(SIC_625km_60_20d.Area), ...
    nanmean(SIC_625km_60_20d_DailyTracep.Area)], ...
    [nanstd(SIC_625km_60_20d_DailyTracem.Area), ...
    nanstd(SIC_625km_60_20d.Area), ...
    nanstd(SIC_625km_60_20d_DailyTracep.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0.6, 0 ,0], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
set(gca, 'XLim', [0.25, 3.75], 'YLim', [0, 20e4], ...
    'xtick', 1 : 3, 'xticklabel', {'+0.1', 'nomal', '-0.1'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')
ylabel('Area (\times10^5 km^2)', 'FontSize', 8)

yyaxis right
h = bar((1 : 3) - 0.22, ...
    [length(SIC_625km_60_20d_DailyTracem.IDs{1}), ...
    length(SIC_625km_60_20d.IDs{1}), ...
    length(SIC_625km_60_20d_DailyTracep.IDs{1}); ...
    length(SIC_625km_60_20d_DailyTracem.IDs{2}), ...
    length(SIC_625km_60_20d.IDs{2}), ...
    length(SIC_625km_60_20d_DailyTracep.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.9, 0.1, 0.1]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.8, 0.1, 0.1]);
h = bar((1 : 3) + 0.22, ...
    [length(PSSM_125km_85_14d_DailyTracem.IDs{1}), ...
    length(PSSM_125km_85_14d.IDs{1}), ...
    length(PSSM_125km_85_14d_DailyTracep.IDs{1}); ...
    length(PSSM_125km_85_14d_DailyTracem.IDs{2}), ...
    length(PSSM_125km_85_14d.IDs{2}), ...
    length(PSSM_125km_85_14d_DailyTracep.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.9]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.8]);
set(gca, 'XLim', [0.25, 3.75], 'YLim', [0, 250], ...
    'xtick', 1 : 3, 'xticklabel', {'+0.1', 'nomal', '-0.1'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')

%%
axes('Position', [0.396, 0.62, 0.288, 0.37])
yyaxis left
h = errorbar((1 : 3) + 0.22, ...
    [nanmean(PSSM_125km_85_14d_YearlyTracem.Area), ...
    nanmean(PSSM_125km_85_14d.Area), ...
    nanmean(PSSM_125km_85_14d_YearlyTracep.Area)], ...
    [nanstd(PSSM_125km_85_14d_YearlyTracem.Area), ...
    nanstd(PSSM_125km_85_14d.Area), ...
    nanstd(PSSM_125km_85_14d_YearlyTracep.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0, 0 ,0.6], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
hold on
h = errorbar((1 : 3) - 0.22, ...
    [nanmean(SIC_625km_60_20d_YearlyTracem.Area), ...
    nanmean(SIC_625km_60_20d.Area), ...
    nanmean(SIC_625km_60_20d_YearlyTracep.Area)], ...
    [nanstd(SIC_625km_60_20d_YearlyTracem.Area), ...
    nanstd(SIC_625km_60_20d.Area), ...
    nanstd(SIC_625km_60_20d_DailyTracep.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0.6, 0 ,0], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
set(gca, 'XLim', [0.25, 3.75], 'YLim', [0, 20e4], ...
    'xtick', 1 : 3, 'xticklabel', {'+0.1', 'nomal', '-0.1'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')
ylabel('Area (\times10^5 km^2)', 'FontSize', 8)

yyaxis right
h = bar((1 : 3) - 0.22, ...
    [length(SIC_625km_60_20d_YearlyTracem.IDs{1}), ...
    length(SIC_625km_60_20d.IDs{1}), ...
    length(SIC_625km_60_20d_YearlyTracep.IDs{1}); ...
    length(SIC_625km_60_20d_YearlyTracem.IDs{2}), ...
    length(SIC_625km_60_20d.IDs{2}), ...
    length(SIC_625km_60_20d_YearlyTracep.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.9, 0.1, 0.1]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.8, 0.1, 0.1]);
h = bar((1 : 3) + 0.22, ...
    [length(PSSM_125km_85_14d_YearlyTracem.IDs{1}), ...
    length(PSSM_125km_85_14d.IDs{1}), ...
    length(PSSM_125km_85_14d_YearlyTracep.IDs{1}); ...
    length(PSSM_125km_85_14d_YearlyTracem.IDs{2}), ...
    length(PSSM_125km_85_14d.IDs{2}), ...
    length(PSSM_125km_85_14d_YearlyTracep.IDs{2})], ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.9]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.8]);
set(gca, 'XLim', [0.25, 3.75], 'YLim', [0, 250], ...
    'xtick', 1 : 3, 'xticklabel', {'+0.1', 'nomal', '-0.1'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')

%%
axes('Position', [0.692, 0.62, 0.208, 0.37])
yyaxis left
h = errorbar((1 : 2) + 0.22, ...
    [nanmean(PSSM_125km_85_14d.Area), ...
    nanmean(PSSM_125km_85_14d_NoFastIce.Area)], ...
    [nanstd(PSSM_125km_85_14d.Area), ...
    nanstd(PSSM_125km_85_14d_NoFastIce.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0, 0 ,0.6], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
hold on
h = errorbar((1 : 2) - 0.22, ...
    [nanmean(SIC_625km_60_20d.Area), ...
    nanmean(SIC_625km_60_20d_NoFastIce.Area)], ...
    [nanstd(SIC_625km_60_20d.Area), ...
    nanstd(SIC_625km_60_20d_NoFastIce.Area)] ./ 2);
set(h, 'LineStyle', 'None', 'Color', [0.6, 0 ,0], 'LineWidth', 1.5, ...
    'Marker', 'o', 'MarkerSize', 5);
set(gca, 'XLim', [0.25, 3.75], 'YLim', [0, 20e4], ...
    'xtick', 1 : 3, 'xticklabel', {'Mask fast-ice', 'No Mask'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')

yyaxis right
h = bar((1 : 2) - 0.22, ...
    [length(SIC_625km_60_20d.IDs{1}), ...
    length(SIC_625km_60_20d_NoFastIce.IDs{1}); ...
    length(SIC_625km_60_20d.IDs{2}), ...
    length(SIC_625km_60_20d_NoFastIce.IDs{2})]', ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.9, 0.1, 0.1]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.8, 0.1, 0.1]);
h = bar((1 : 2) + 0.22, ...
    [length(PSSM_125km_85_14d.IDs{1}), ...
    length(PSSM_125km_85_14d_NoFastIce.IDs{1}); ...
    length(PSSM_125km_85_14d.IDs{2}), ...
    length(PSSM_125km_85_14d_NoFastIce.IDs{2})]', ...
    'stacked');
set(h(1), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.9]);
set(h(2), 'LineStyle', 'None', 'BarWidth', 0.36, 'FaceColor', [0.1, 0.1, 0.8]);
set(gca, 'XLim', [0.25, 2.75], 'YLim', [0, 250], ...
    'xtick', 1 : 3, 'xticklabel', {'With', 'Without'}, ...
    'XTickLabelRotation', 45, ...
    'FontSize', 8, ...
    'YColor', 'k', 'XColor', 'k')