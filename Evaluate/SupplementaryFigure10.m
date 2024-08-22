clear; close all; clc;
%% read  DEEP polynyas
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
    
    [Polynyatemp, ~, ic] = unique(Polynyatemp);
    PolynyaAreatemp = accumarray(ic, 1);
    for j = 1 : length(Polynyatemp)
        if ~ismember(Polynyatemp(j), PolynyaIDs)
            PolynyaIDs = [PolynyaIDs; Polynyatemp(j)];
        end
        PolynyaArea(i, PolynyaIDs == Polynyatemp(j)) = PolynyaAreatemp(j);
    end
end
PolynyaArea(isnan(PolynyaArea(:, 1)), :) = NaN;
PolynyaArea(:, 1) = [];
PolynyaIDs(1) = [];
PolynyaArea = reshape(PolynyaArea, 214, 20, size(PolynyaArea, 2));
PolynyaArea = PolynyaArea .* 6.25 .* 6.25;

%%
PolynyaArea(PolynyaArea == 0) = NaN;
PolynyaAreaYearly = squeeze(nanmean(PolynyaArea, 1));
PolynyaAreaYearlyStd = squeeze(nanstd(PolynyaArea, 1));
PolynyaDaysYearly = squeeze(sum(double(~isnan(PolynyaArea)), 1));
PolynyaAreaYearlyWholeYear = PolynyaDaysYearly .* PolynyaAreaYearly ./ 214;

%%
clear Loacation_Lon MeanArea MeanDays
figure
FreqPolynyas = readtable('C:\Users\13098\Documents\冰间湖识别\Manuscript\DEEP-AA_ST2_0619_SD.xlsx');
for i = 1 : 18
    PolynyaIDtemp = FreqPolynyas.IDInDEEP_AA{i};
    PolynyaIDtemp = str2double(PolynyaIDtemp(2 : end));
    PolynyaIDtemp = find(PolynyaIDs == PolynyaIDtemp);
    subplot(18, 4, i * 4 - 2)
    yyaxis right
    Year = [2003 : 2010, 2013 : 2022];
    h = errorbar(Year, ...
        PolynyaAreaYearly([1 : 8, 11 : end], PolynyaIDtemp), ...
        PolynyaAreaYearlyStd([1 : 8, 11 : end], PolynyaIDtemp) ./ 2);
    set(h, 'LineStyle', 'None', 'LineWidth', 0.75, 'Color', 'k', ...
        'Marker', 'o', 'MarkerSize', 1.5, 'MarkerFaceColor', 'k', ...
        'CapSize', 1.8)
    set(gca, 'ycolor', 'k', 'Ylim', [0, Inf], ...
        'tickdir', 'out')
    ax1 = gca;
    ax1.YAxis(2).Exponent = 3;
    
    yyaxis left
    Year = [2003 : 2010, 2013 : 2022];
    h = bar(Year, PolynyaDaysYearly([1 : 8, 11 : end], PolynyaIDtemp));
    set(h, 'FaceColor', [0.55, 0.55, 0.55], 'LineStyle', 'None', 'BarWidth', 0.8)
    set(gca, 'ycolor', [0.3, 0.3, 0.3], 'Ylim', [0, 300], 'YTickLabel', {'0', '100', '200', ''}, ...
        'tickdir', 'out')
    
    subplot(18, 4, i * 4 - 3)
    set(gca, 'xtick', [], 'ytick', [])
    Loacationtemp.Lon = floor(mod(PolynyaIDs(PolynyaIDtemp), 10000000) ./ 10);
    Loacationtemp.Lat = [num2str(mod(Loacationtemp.Lon, 100)), '°S'];
    Loacationtemp.Lon = round(Loacationtemp.Lon / 1000);
    if Loacationtemp.Lon > 180
        Loacationtemp.Lon = [num2str(-(Loacationtemp.Lon - 360)), '°W'];
    else
        Loacationtemp.Lon = [num2str(Loacationtemp.Lon), '°E'];
    end
    title(['#', num2str(PolynyaIDs(PolynyaIDtemp), '%.9d'), newline, ...
        newline, ...
        Loacationtemp.Lon, ' ', Loacationtemp.Lat], 'FontSize', 8)
    
    PolynyaIDs_SF10(i) = PolynyaIDs(PolynyaIDtemp);
    
    Loacation_Lon(i) = str2double(Loacationtemp.Lon(1 : end - 2));
    Loacation_Lat(i) = str2double(Loacationtemp.Lat(1 : end - 2));
    
    temp = PolynyaAreaYearly([1 : 8, 11 : end], PolynyaIDtemp);
    temp(isnan(temp)) = 0;
    MeanArea(i) = nanmean(temp);
    temp = PolynyaDaysYearly([1 : 8, 11 : end], PolynyaIDtemp);
    temp(isnan(temp)) = 0;
    MeanDays(i) = nanmean(temp);
end

for i = 19 : height(FreqPolynyas)
    PolynyaIDtemp = FreqPolynyas.IDInDEEP_AA{i};
    PolynyaIDtemp = str2double(PolynyaIDtemp(2 : end));
    PolynyaIDtemp = find(PolynyaIDs == PolynyaIDtemp);
    subplot(18, 4, (i - 18) * 4)
    yyaxis right
    Year = [2003 : 2010, 2013 : 2022];
    h = errorbar(Year, ...
        PolynyaAreaYearly([1 : 8, 11 : end], PolynyaIDtemp), ...
        PolynyaAreaYearlyStd([1 : 8, 11 : end], PolynyaIDtemp) ./ 2);
    set(h, 'LineStyle', 'None', 'LineWidth', 0.75, 'Color', 'k', ...
        'Marker', 'o', 'MarkerSize', 1.5, 'MarkerFaceColor', 'k', ...
        'CapSize', 1.8)
    set(gca, 'ycolor', 'k', 'Ylim', [0, Inf], ...
        'tickdir', 'out')
    ax1 = gca;
    ax1.YAxis(2).Exponent = 3;
    
    yyaxis left
    Year = [2003 : 2010, 2013 : 2022];
    h = bar(Year, PolynyaDaysYearly([1 : 8, 11 : end], PolynyaIDtemp));
    set(h, 'FaceColor', [0.55, 0.55, 0.55], 'LineStyle', 'None', 'BarWidth', 0.8)
    set(gca, 'ycolor', [0.3, 0.3, 0.3], 'Ylim', [0, 300], 'YTickLabel', {'0', '100', '200', ''}, ...
        'tickdir', 'out')
    
    subplot(18, 4, (i - 18) * 4 - 1)
    set(gca, 'xtick', [], 'ytick', [])
    Loacationtemp.Lon = floor(mod(PolynyaIDs(PolynyaIDtemp), 10000000) ./ 10);
    Loacationtemp.Lat = [num2str(mod(Loacationtemp.Lon, 100)), '°S'];
    Loacationtemp.Lon = round(Loacationtemp.Lon / 1000);
    if Loacationtemp.Lon > 180
        Loacationtemp.Lon = [num2str(-(Loacationtemp.Lon - 360)), '°W'];
    else
        Loacationtemp.Lon = [num2str(Loacationtemp.Lon), '°E'];
    end
    title(['#', num2str(PolynyaIDs(PolynyaIDtemp), '%.9d'), newline, ...
        newline, ...
        Loacationtemp.Lon, ' ', Loacationtemp.Lat], 'FontSize', 8)
    
    PolynyaIDs_SF10(i) = PolynyaIDs(PolynyaIDtemp);
    
    Loacation_Lon(i) = str2double(Loacationtemp.Lon(1 : end - 2));
    Loacation_Lat(i) = str2double(Loacationtemp.Lat(1 : end - 2));
    
    temp = PolynyaAreaYearlyWholeYear([1 : 8, 11 : end], PolynyaIDtemp);
    temp(isnan(temp)) = 0;
    MeanArea(i) = nanmean(temp);
    temp = PolynyaDaysYearly([1 : 8, 11 : end], PolynyaIDtemp);
    temp(isnan(temp)) = 0;
    MeanDays(i) = nanmean(temp);
end
AxShareTick('Gap', [1/3, 1/2], 'YLackTick', 0)
PrintEPS('Size', [21, 20.5])

%%
clear Loacation_Lon MeanArea MeanDays
IDinFig = [043575671, 030364671, 030769631, 041852661, 061638760, 032696690, 031640670];
figure
for i = 1 : 18 * 4
    subplot(18, 4, i);
end
for i = 1 : 7
    PolynyaIDtemp = find(PolynyaIDs == IDinFig(i));
    subplot(18, 4, i * 4 - 2)
    yyaxis right
    Year = [2003 : 2010, 2013 : 2022];
    h = errorbar(Year, ...
        PolynyaAreaYearly([1 : 8, 11 : end], PolynyaIDtemp), ...
        PolynyaAreaYearlyStd([1 : 8, 11 : end], PolynyaIDtemp) ./ 2);
    set(h, 'LineStyle', 'None', 'LineWidth', 0.75, 'Color', 'k', ...
        'Marker', 'o', 'MarkerSize', 1.5, 'MarkerFaceColor', 'k', ...
        'CapSize', 1.8)
    set(gca, 'ycolor', 'k', 'Ylim', [0, Inf], ...
        'tickdir', 'out')
    ax1 = gca;
    ax1.YAxis(2).Exponent = 3;
    
    yyaxis left
    Year = [2003 : 2010, 2013 : 2022];
    h = bar(Year, PolynyaDaysYearly([1 : 8, 11 : end], PolynyaIDtemp));
    set(h, 'FaceColor', [0.55, 0.55, 0.55], 'LineStyle', 'None', 'BarWidth', 0.8)
    set(gca, 'ycolor', [0.3, 0.3, 0.3], 'Ylim', [0, 300], 'YTickLabel', {'0', '100', '200', ''}, ...
        'tickdir', 'out')
    
    subplot(18, 4, i * 4 - 3)
    set(gca, 'xtick', [], 'ytick', [])
    Loacationtemp.Lon = floor(mod(PolynyaIDs(PolynyaIDtemp), 10000000) ./ 10);
    Loacationtemp.Lat = [num2str(mod(Loacationtemp.Lon, 100)), '°S'];
    Loacationtemp.Lon = round(Loacationtemp.Lon / 1000);
    if Loacationtemp.Lon > 180
        Loacationtemp.Lon = [num2str(-(Loacationtemp.Lon - 360)), '°W'];
    else
        Loacationtemp.Lon = [num2str(Loacationtemp.Lon), '°E'];
    end
    title(['#', num2str(PolynyaIDs(PolynyaIDtemp), '%.9d'), newline, ...
        newline, ...
        Loacationtemp.Lon, ' ', Loacationtemp.Lat], 'FontSize', 8)
    
    PolynyaIDs_SF10 = [PolynyaIDs_SF10, PolynyaIDs(PolynyaIDtemp)];
    
    Loacation_Lon(i) = str2double(Loacationtemp.Lon(1 : end - 2));
    Loacation_Lat(i) = str2double(Loacationtemp.Lat(1 : end - 2));
    
    temp = PolynyaAreaYearlyWholeYear([1 : 8, 11 : end], PolynyaIDtemp);
    temp(isnan(temp)) = 0;
    MeanArea(i) = nanmean(temp);
    temp = PolynyaDaysYearly([1 : 8, 11 : end], PolynyaIDtemp);
    temp(isnan(temp)) = 0;
    MeanDays(i) = nanmean(temp);
end
AxShareTick('Gap', [1/3, 1/2], 'YLackTick', 0)
PrintEPS('Size', [21, 20.5])

%%
PolynyaIDs_ST2 = [PolynyaIDs_SF10'; PolynyaIDs];
PolynyaIDs_ST2 = unique(PolynyaIDs_ST2, 'stable');
for i = 1 : length(PolynyaIDs_ST2)
    PolynyaArea_Days(i * 2 - 1, :) = ...
        PolynyaAreaYearlyWholeYear(:, PolynyaIDs == PolynyaIDs_ST2(i));
    PolynyaArea_Days(i * 2, :) = ...
        PolynyaDaysYearly(:, PolynyaIDs == PolynyaIDs_ST2(i));
end
PolynyaArea_Days(isnan(PolynyaArea_Days)) = 0;
PolynyaArea_Days = [mean(PolynyaArea_Days(:, [1 : 8, 11 : end]), 2), PolynyaArea_Days];