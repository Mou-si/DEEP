close all; clear; clc;
%% read the overview map
Path = inputdlg('Enter the path of OverviewMap.mat', ...
    'DEEP-AA Polynya ID finder', [1 100]);
load(Path{1})
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
dcm.Enable = 'on';
dcm.UpdateFcn = @displayCoordinates;

AxPosition = gca;
AxPosition = AxPosition.Position;
btn = uicontrol('Style', 'pushbutton', 'String', 'See all IDs (double click)', ...
    'Units', 'normalized', ...
    'Position', [AxPosition(1), AxPosition(2)/5, AxPosition(3)/3, AxPosition(2)*0.6], ...
    'Enable', 'on', ...
    'Callback', @btnCallback);

set(gca, 'XTick', [], 'YTick', [])
title(['Polynya robust extent map', newline, ...
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
   IDstemp = OverviewMap(clickY, clickX);
   if IDstemp < 100
        continue
    else
        IDs(counts) = IDstemp;
        clickPositiont{counts} = clickPositiontemp(1, 1 : 2); 
        hold on
        plot(clickPositiontemp(1,1), clickPositiontemp(1,2), '+k')
        counts = counts + 1;
   end
   
end

dt = findobj('Type','datatip');
delete(dt)
for i = 1 : length(clickPositiont)
    text(clickPositiont{i}(1) + 10, clickPositiont{i}(2) + 10, ...
        ['\bf', num2str(i), ')\rm #', num2str(IDs(i), '%d9')], ...
        'Color', 'k', 'FontSize', 8)
end
annotation('textbox', ...
    'String', 'The selected IDs has been copied', ...
    'LineStyle', 'None', ...
    'BackgroundColor', [0.98, 0.98, 0.98], ...
    'Units', 'normalized', ...
    'Position', [AxPosition(1) + AxPosition(3)/2, AxPosition(2) * 0.2, ...
    AxPosition(3)/2, AxPosition(2)*0.6])
clipboard('copy', IDs)

clear StopFlag PauseFlag

%%
function txt = displayCoordinates(~,info)
    global OverviewMap
    x = info.Position(1);
    y = info.Position(2);
    x = round(x);
    y = round(y);
    txt = OverviewMap(y, x);
    if txt < 100
        txt = 'No polynya';
    else
        txt = num2str(txt, '%d9');
    end
end

function WindowsCallback(~, ~)
    global PauseFlag
    PauseFlag = true;
end

function btnCallback(~, ~)
    global StopFlag
    StopFlag = true;
end