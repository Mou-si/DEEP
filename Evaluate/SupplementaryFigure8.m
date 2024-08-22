close all; clear; clc;
%% read data
SIC60Path = 'G:\DEEP-AAShare\SIC60_6.25km_20d\';
PSSMPath = 'G:\DEEP-AAShare\PSSM85_12.5km_14d\';
PSSMFiles = dir(PSSMPath);
PSSMFiles = cat(1, PSSMFiles(3 : end - 3).name);
SIC60map = zeros(1328, 1264);
PSSMmap = zeros(664, 632);
for i = 1 : length(PSSMFiles)
    disp(PSSMFiles(i, :));
    SIC60Files = ['DEEP_s6250_AMSR_SIC_', PSSMFiles(i, 23 : end)];
    try
    SIC60mapDaily = ncread([SIC60Path, SIC60Files], 'Map');
    catch
        continue
    end
    PSSMmapDaily = ncread([PSSMPath, PSSMFiles(i, :)], 'Map');
    
    % SIC 60
    temp = SIC60mapDaily > 100;
    SIC60TotalArea(i) = sum(temp(:));
    SIC60map = SIC60map + double(temp);
    % RSP TNBP AP BeP CDP MBP BaP SP VBP DaP DiP MP RONP
    temp = SIC60mapDaily == 031774780;
    SIC60EachArea(i, 1) = sum(temp(:));
    temp = SIC60mapDaily == 031647750;
    SIC60EachArea(i, 2) = sum(temp(:));
    temp = SIC60mapDaily == 032485730;
    SIC60EachArea(i, 3) = sum(temp(:));
    temp = SIC60mapDaily == 032799720;
    SIC60EachArea(i, 4) = sum(temp(:));
    temp = SIC60mapDaily == 030676680;
    SIC60EachArea(i, 5) = sum(temp(:));
    temp = SIC60mapDaily == 030745700;
    SIC60EachArea(i, 6) = sum(temp(:));
    temp = SIC60mapDaily == 030789680;
    SIC60EachArea(i, 7) = sum(temp(:));
    temp = SIC60mapDaily == 030908672;
    SIC60EachArea(i, 8) = sum(temp(:));
    temp = SIC60mapDaily == 031076660;
    SIC60EachArea(i, 9) = sum(temp(:));
    temp = SIC60mapDaily == 031214670;
    SIC60EachArea(i, 10) = sum(temp(:));
    temp = SIC60mapDaily == 031345660;
    SIC60EachArea(i, 11) = sum(temp(:));
    temp = SIC60mapDaily == 031467660;
    SIC60EachArea(i, 12) = sum(temp(:));
    % manual RONP
    temp = ismember(SIC60mapDaily, [032998750, 033065770, 163042760, 113044760]);
    SIC60EachArea(i, 13) = sum(temp(:));
    
    % PSSM
    temp = PSSMmapDaily > 100;
    PSSMTotalArea(i) = sum(temp(:));
    PSSMmap = PSSMmap + double(temp);
    temp = PSSMmapDaily == 031760780;
    PSSMEachArea(i, 1) = sum(temp(:));
    temp = PSSMmapDaily == 031647750;
    PSSMEachArea(i, 2) = sum(temp(:));
    temp = PSSMmapDaily == 032487730;
    PSSMEachArea(i, 3) = sum(temp(:));
    temp = PSSMmapDaily == 032799720;
    PSSMEachArea(i, 4) = sum(temp(:));
    temp = PSSMmapDaily == 030684680;
    PSSMEachArea(i, 5) = sum(temp(:));
    temp = PSSMmapDaily == 030748690;
    PSSMEachArea(i, 6) = sum(temp(:));
    temp = PSSMmapDaily == 030811660;
    PSSMEachArea(i, 7) = sum(temp(:));
    temp = PSSMmapDaily == 030948660;
    PSSMEachArea(i, 8) = sum(temp(:));
    temp = PSSMmapDaily == 031092670;
    PSSMEachArea(i, 9) = sum(temp(:));
    temp = PSSMmapDaily == 031210670;
    PSSMEachArea(i, 10) = sum(temp(:));
    temp = PSSMmapDaily == 031342660;
    PSSMEachArea(i, 11) = sum(temp(:));
    temp = PSSMmapDaily == 031469660;
    PSSMEachArea(i, 12) = sum(temp(:));
    % manual RONP
    temp = ismember(PSSMmapDaily, [032998750, 133050760]);
    PSSMEachArea(i, 13) = sum(temp(:));
end
PSSMTotalArea = PSSMTotalArea .* 12.5 .* 12.5;
SIC60TotalArea = SIC60TotalArea .* 6.25 .* 6.25;
PSSMEachArea = PSSMEachArea .* 12.5 .* 12.5;
SIC60EachArea = SIC60EachArea .* 6.25 .* 6.25;

%% correlate
for i = 1 : 13
    temp = corrcoef(PSSMEachArea(:, i), SIC60EachArea(:, i));
    PSSMvsSICCorr(i) = temp(2);
end
PSSMvsSICCorr = PSSMvsSICCorr(1 : 12);

%% plot
figure
axes('Position', [0.13, 0.5, 0.24, 0.24])
binscatter(PSSMTotalArea, SIC60TotalArea, [50, 50])
set(gca, 'Position', [0.08, 0.55, 0.38, 0.38], ...
'XLim', [0, 350000], 'YLim', [0, 350000], 'CLim', [0, 40], ...
'PlotBoxAspectRatio', [1, 1, 1], ...
'LineWidth', 0.75, 'TickDir', 'Out', 'TickLength', [0.02, 0.05])
xlabel(['Total extent from PSSM', ...
newline, '(\times10^5 km^2)'])
ylabel(['Total extent from', newline, 'SIC threshold (6.25 km)', ...
newline, '(\times10^5 km^2)'])
f = gca;
f.XLabel.FontSize = 9;
f.YLabel.FontSize = 9;
hold on
h = line([0, 350000], [0, 350000]);
set(h, 'Color', 'k', 'LineWidth', 0.75);
colorbar off

axes('Position', [0.13, 0.1, 0.75, 0.24])
h = bar(PSSMvsSICCorr);
set(gca, 'xTickLabel', {'RSP' 'TNBP' 'AP' 'BeP' 'CDP' 'MBP' 'BaP' ...
    'SP' 'VBP' 'DaP' 'DiP' 'MP'}, ...
    'XTickLabelRotation', 45, ...
    'yTick', 0 : 0.2 : 1, ...
    'LineWidth', 0.8);
set(h, 'BarWidth', 0.5, 'LineStyle', 'None');
ylabel('Correlation')
f = gca;
f.XLabel.FontSize = 8;
f.YLabel.FontSize = 8;
set(gcf, 'units', 'centimeters', 'position', [5, 5, 12, 11])