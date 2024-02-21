close all; clear; clc;
%% read data
SIC60Path = 'G:\AAPSResults\AMSR_SIC60_6.25km_20d\';
PSSMPath = 'G:\AAPSResults\AMSR36_PSSM\';
PSSMFiles = dir(PSSMPath);
PSSMFiles = cat(1, PSSMFiles(3 : end - 1).name);
SIC60map = zeros(1328, 1264);
PSSMmap = zeros(664, 632);
for i = 1 : length(PSSMFiles)
    disp(PSSMFiles(i, :));
    SIC60Files = ['AAPS_s3125_AMSR_SIC_', PSSMFiles(i, 23 : end)];
    try
    SIC60mapDaily = ncread([SIC60Path, SIC60Files], 'PolynyaIDMap');
    catch
        continue
    end
    PSSMmapDaily = ncread([PSSMPath, PSSMFiles(i, :)], 'PolynyaIDMap');
    
    % SIC 60
    temp = SIC60mapDaily > 100;
    SIC60TotalArea(i) = sum(temp(:));
    SIC60map = SIC60map + double(temp);
    % RSP TNBP AP BeP CDP MBP BaP SP VBP DaP DiP MP E.LP HBP WGP
    temp = SIC60mapDaily == 41915780;
    SIC60EachArea(i, 1) = sum(temp(:));
    temp = SIC60mapDaily == 41660750;
    SIC60EachArea(i, 2) = sum(temp(:));
    temp = SIC60mapDaily == 42489740;
    SIC60EachArea(i, 3) = sum(temp(:));
    temp = SIC60mapDaily == 42803730;
    SIC60EachArea(i, 4) = sum(temp(:));
    temp = SIC60mapDaily == 40652680;
    SIC60EachArea(i, 5) = sum(temp(:));
    temp = SIC60mapDaily == 40741700;
    SIC60EachArea(i, 6) = sum(temp(:));
    temp = SIC60mapDaily == 40763690;
    SIC60EachArea(i, 7) = sum(temp(:));
    temp = SIC60mapDaily == 40938660;
    SIC60EachArea(i, 8) = sum(temp(:));
    temp = SIC60mapDaily == 41092670;
    SIC60EachArea(i, 9) = sum(temp(:));
    temp = SIC60mapDaily == 41212660;
    SIC60EachArea(i, 10) = sum(temp(:));
    temp = SIC60mapDaily == 41341660;
    SIC60EachArea(i, 11) = sum(temp(:));
    temp = SIC60mapDaily == 41479660;
    SIC60EachArea(i, 12) = sum(temp(:));
    temp = SIC60mapDaily == 40043700;
    SIC60EachArea(i, 13) = sum(temp(:));
    temp = SIC60mapDaily == 42273740;
    SIC60EachArea(i, 14) = sum(temp(:));
    temp = SIC60mapDaily == 42331720;
    SIC60EachArea(i, 15) = sum(temp(:));
    
    % PSSM
    temp = PSSMmapDaily > 100;
    PSSMTotalArea(i) = sum(temp(:));
    PSSMmap = PSSMmap + double(temp);
    temp = PSSMmapDaily == 41750770;
    PSSMEachArea(i, 1) = sum(temp(:));
    temp = PSSMmapDaily == 41665760;
    PSSMEachArea(i, 2) = sum(temp(:));
    temp = PSSMmapDaily == 42495740;
    PSSMEachArea(i, 3) = sum(temp(:));
    temp = PSSMmapDaily == 42808730;
    PSSMEachArea(i, 4) = sum(temp(:));
    temp = PSSMmapDaily == 40692680;
    PSSMEachArea(i, 5) = sum(temp(:));
    temp = PSSMmapDaily == 40744690;
    PSSMEachArea(i, 6) = sum(temp(:));
    temp = PSSMmapDaily == 40813680;
    PSSMEachArea(i, 7) = sum(temp(:));
    temp = PSSMmapDaily == 40948660;
    PSSMEachArea(i, 8) = sum(temp(:));
    temp = PSSMmapDaily == 41090670;
    PSSMEachArea(i, 9) = sum(temp(:));
    temp = PSSMmapDaily == 41211660;
    PSSMEachArea(i, 10) = sum(temp(:));
    temp = PSSMmapDaily == 41344660;
    PSSMEachArea(i, 11) = sum(temp(:));
    temp = PSSMmapDaily == 41479670;
    PSSMEachArea(i, 12) = sum(temp(:));
    temp = PSSMmapDaily == 40112700;
    PSSMEachArea(i, 13) = sum(temp(:));
    temp = PSSMmapDaily == 42279740;
    PSSMEachArea(i, 14) = sum(temp(:));
    temp = PSSMmapDaily == 42332730;
    PSSMEachArea(i, 15) = sum(temp(:));
end
PSSMTotalArea = PSSMTotalArea .* 12.5 .* 12.5;
SIC60TotalArea = SIC60TotalArea .* 6.25 .* 6.25;
PSSMEachArea = PSSMEachArea .* 12.5 .* 12.5;
SIC60EachArea = SIC60EachArea .* 6.25 .* 6.25;

%% correlate
for i = 1 : 15
    temp = corrcoef(PSSMEachArea(:, i), SIC60EachArea(:, i));
    PSSMvsSICCorr(i) = temp(2);
end
PSSMvsSICCorr = PSSMvsSICCorr([2, 1, 14, 15, 3 : 4, 13, 5 : 12]);

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
set(gca, 'xTickLabel', {'RSP' 'TNBP' 'HBP' 'WGP' 'AP' 'BeP' 'CDP' 'MBP' 'BaP' ...
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