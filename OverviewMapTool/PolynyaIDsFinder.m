close all; clear; clc;
%% read the overview map
RightPathFlag = false;
FileWarningFalg = false;
while ~RightPathFlag
    [Pathtemp1, Pathtemp2] = uigetfile({'*.mat'}, ['Select the overview map file (OverMap.mat) ', ...
        'or a folder with OverMap.mat']);
    Path = fullfile(Pathtemp2, Pathtemp1);
    FileNametemp = dir(Path);
    if ~isequal(FileNametemp.name, 'OverviewMap.mat')
        FileWarning = questdlg(['Warning: ', newline, ...
            'The file you selected is not OverMap.mat, ', ...
            'which may caused unexpected errors.', newline, ...
            'Do you still want to continue?', newline, ...
            'The selected file: ', Path], ...
            'Dessert Menu', ...
            'Still continue', 'Select again');
        uiwait()
        switch FileWarning
            case 'Still continue'
                RightPathFlag = true;
            case 'Select again'
                continue
        end
    else
        RightPathFlag = true;
    end
end

load(Path)
OverviewMap_NaN = OverviewMap;
OverviewMap_NaN = double(isnan(OverviewMap_NaN));
OverviewMap(isnan(OverviewMap)) = 0;
PolynyaIDs = unique(OverviewMap);
%% rename the polynya IDs
% get longitudes of polynyas
PolynyaLocation = PolynyaIDs(2 : end);
PolynyaLocation = mod(PolynyaLocation, 10000000);
PolynyaLocation = floor(PolynyaLocation ./ 1000) ./ 10;
% change the IDs in OverviewMap, so the adjacent will have different colors
% in the colormap lines
[~, PolynyaLocation_i] = sort(PolynyaLocation);
[~, ~, ic] = unique(OverviewMap);
PolynyaLocation_i = [0; PolynyaLocation_i];
OverviewMap_New = PolynyaLocation_i(ic);
OverviewMap_New = reshape(OverviewMap_New, ...
    size(OverviewMap, 1), size(OverviewMap, 2));
%% plot robust extent
global StopFlag PauseFlag
StopFlag = false;
PauseFlag = false;

OverviewMap_New(OverviewMap_New == 0) = NaN;
figure('visible', 'off')
image(repmat(1 - OverviewMap_NaN .* 0.1, 1, 1, 3));
hold on
h = pcolor(OverviewMap_New);
set(h, 'LineStyle', 'None')
colormap(lines(length(PolynyaLocation)));
set(gca, 'YDir', 'Normal')
dcm = datacursormode;
dcm.Enable = 'off';

AxPosition = gca;
AxPosition = AxPosition.Position;
btn = uicontrol('Style', 'pushbutton', 'String', 'See all selected IDs (double click)', ...
    'Units', 'normalized', ...
    'Position', [AxPosition(1), AxPosition(2)/5, AxPosition(3)/5*2, AxPosition(2)*0.6], ...
    'Enable', 'on', ...
    'Callback', @ShowIDsbtnCallback);

set(gca, 'XTick', [], 'YTick', [])
title(['Polynya robust extent map', ...
    newline, ...
    'Please click the polynya whose ID you need'])

set(gcf, 'visible', 'on')

%% get points
counts = 1;
while true
    
    waitforbuttonpress
    
    drawnow;
    if StopFlag
        break;
    end
    
    clickPositiontemp = get(gca, 'CurrentPoint');
    clickX = clickPositiontemp(1,1);
    clickY = clickPositiontemp(1,2);
    
    clickX = round(clickX);
    clickY = round(clickY);
    try
        IDstemp = OverviewMap(clickY, clickX);
    catch
        continue
    end
    if exist('IDTag', 'var')
        delete(IDTag)
    end
    if IDstemp < 100
       IDTag = text(clickPositiontemp(1, 1) + size(OverviewMap, 2) * 0.02, ...
            clickPositiontemp(1, 2) + size(OverviewMap, 1) * 0.03, ...
            'No polynyas', ...
            'Color', 'k', 'FontSize', 8);
        set(IDTag, 'BackgroundColor', 'w', ...
            'EdgeColor', [0.8, 0.8, 0.8], 'LineWidth', 0.3)
        continue
    else
        IDs(counts) = IDstemp;
        clickPositiont{counts} = clickPositiontemp(1, 1 : 2); 
        hold on
        plot(clickPositiontemp(1,1), clickPositiontemp(1,2), '+k')
        IDTag = text(clickPositiontemp(1, 1) + size(OverviewMap, 2) * 0.02, ...
            clickPositiontemp(1, 2) + size(OverviewMap, 1) * 0.03, ...
            ['\bf', num2str(counts), '\rm #', num2str(IDstemp, '%.9d')], ...
            'Color', 'k', 'FontSize', 8);
        set(IDTag, 'BackgroundColor', 'w', ...
            'EdgeColor', [0.8, 0.8, 0.8], 'LineWidth', 0.3)
        counts = counts + 1;
   end
   
   clear IDstemp
   
end

if length(IDs) > 1 && IDs(end - 1) == IDs(end)
    IDs = IDs(1 : end - 1);
    clickPositiont = clickPositiont(1 : end - 1);
end

delete(IDTag)
for i = 1 : length(clickPositiont)
    text(clickPositiont{i}(1) + 10, clickPositiont{i}(2) + 10, ...
        ['\bf', num2str(i), ')\rm #', num2str(IDs(i), '%.9d')], ...
        'Color', 'k', 'FontSize', 8)
end
annotation('textbox', ...
    'String', 'The selected IDs has been copied', ...
    'LineStyle', 'None', ...
    'BackgroundColor', [0.98, 0.98, 0.98], ...
    'Units', 'normalized', ...
    'Position', [AxPosition(1) + AxPosition(3)/2, AxPosition(2) * 0.2, ...
    AxPosition(3)/2, AxPosition(2)*0.6])
IDs = num2str(IDs', '%.9d');
IDs_str = [];
for i = 1 : size(IDs, 1)
    IDs_str = [IDs_str, num2str(i), ') #', IDs(i, :), '   '];
end
IDs_str = IDs_str(1 : end - 3);
clipboard('copy', IDs_str)

clear StopSelectPolynyaFlag PauseFlag

%%
function WindowsCallback(~, ~)
    global PauseFlag
    PauseFlag = true;
end

function ShowIDsbtnCallback(~, ~)
    global StopFlag
    StopFlag = true;
end