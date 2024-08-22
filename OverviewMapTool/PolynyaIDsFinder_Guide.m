close all; clear; clc;
%% read the overview map
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'none';
[icondata, iconcmap] = imread('yellowlily-segmented.png');

f = Mymsgbox(['\fontsize{15}\bfWelcome to the polynya ID finder for DEEP-AA!', newline, newline, ...
    '\fontsize{10}\rmThis tool is used to help you quick search the ID of the polynyas.', newline, newline, ...
    'Only two things you need to do, and now I''ll tell you the first:', newline, newline, ...
    '    1) Click OK below and select the polynya overview file, ', ...
    'which is usually named OverviewMap.mat and put with the other dataset output files', newline, newline, ...
    'Let''s do it'], ...
    'Polynya ID finder', ...
    'custom', icondata, iconcmap, ...
    CreateStruct);
set(f, 'Units', 'normalized', 'Position', [0.25, 0.3, 0.43, 0.4])
f.Children(1).Units = 'normalized';
f.Children(1).Position(1) = 0.5 - f.Children(1).Position(3) ./ 2;
f.Children(3).Children.Units = 'normalized';
f.Children(3).Children.Position = ...
    [1 - f.Children(3).Children.Extent(3) - 0.01, ...
    0.54 - f.Children(3).Children.Extent(4) / 2, 0];
f.Children(2).Units = 'normalized';
f.Children(2).Position = ...
    [0.01, 0.54 - f.Children(3).Children.Extent(4) / 2, ...
    f.Children(3).Children.Position(1) - 0.04, f.Children(3).Children.Extent(4)];
f.Visible = 'on';
uiwait(f)
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

f = Mymsgbox(['\fontsize{15}\bfGood Job! Let''s go to the next step!', newline, newline, ...
    '\fontsize{10}\rmIn the next step, we will map the extent of all polynyas. Different polynyas will be in different colors', newline, newline, ...
    'You can click the polynyas to query their IDs.', newline, newline, ...
    'When you click on all the concerned polynyas, you should double-click the the button of "See all selected IDs", all selected IDs will be plotted on the map and also copied to clipboard', newline, newline, ...
    'Let''s do it'], ...
    'Polynya ID finder', ...
    'custom', icondata, iconcmap, ...
    CreateStruct);
set(f, 'Units', 'normalized', 'Position', [0.25, 0.3, 0.43, 0.4])
f.Children(1).Units = 'normalized';
f.Children(1).Position(1) = 0.5 - f.Children(1).Position(3) ./ 2;
f.Children(3).Children.Units = 'normalized';
f.Children(3).Children.Position = ...
    [1 - f.Children(3).Children.Extent(3) - 0.01, ...
    0.54 - f.Children(3).Children.Extent(4) / 2, 0];
f.Children(2).Units = 'normalized';
f.Children(2).Position = ...
    [0.01, 0.54 - f.Children(3).Children.Extent(4) / 2, ...
    f.Children(3).Children.Position(1) - 0.04, f.Children(3).Children.Extent(4)];
f.Visible = 'on';

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
figure('visible', 'off');
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

uiwait(f)

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
       IDTag = text(clickPositiontemp(1, 1), ...
            clickPositiontemp(1, 2), ...
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
        IDTag = text(clickPositiontemp(1, 1), ...
            clickPositiontemp(1, 2), ...
            ['\bf', num2str(counts), ')\rm #', num2str(IDstemp, '%.9d')], ...
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
    text(clickPositiont{i}(1), clickPositiont{i}(2), ...
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

%%
function varargout=Mymsgbox(varargin)
% Copied from msgbox


%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%
narginchk(1,6);
nargoutchk(0,1);

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

inputStr = varargin{1};
% BodyTextString = dialogCellstrHelper(inputStr);

% setup defaults
TitleString=' ';
IconString ='none';
IconData   =[];
IconCMap   =[];


createArg = '';
if nargin > 1
    createArg = varargin{nargin};
end

[Flag,CreateMode,Interpreter]=InternalCreateFlag(createArg);

% Do a check on the Interpreter property upfront.
if (any(strcmpi(Interpreter, {'latex', 'tex', 'none'})) ~= 1)
    error(message('MATLAB:msgbox:interpreter'));
end


switch nargin
    case 2
        if ~Flag
            TitleString=varargin{2};
        end
    case 3
        TitleString=varargin{2};
        if ~Flag
            IconString=varargin{3};
        end
    case 4
        TitleString=varargin{2};
        IconString=varargin{3};
        if ~Flag
            IconData = varargin{4};
        end
    case 5
        if Flag
            error(message('MATLAB:msgbox:colormap'));
        end
        TitleString=varargin{2};
        IconString=varargin{3};
        if ~strcmpi(IconString,'custom')
            warning(message('MATLAB:msgbox:customicon'));
            IconString='custom';
        end
        IconData=varargin{4};
        IconCMap=varargin{5};
    case 6
        TitleString=varargin{2};
        IconString=varargin{3};
        IconData=varargin{4};
        IconCMap=varargin{5};
end

IconString=lower(IconString);
switch(IconString)
    case {'custom'}
        % check for icon data
        if isempty(IconData)
            error(message('MATLAB:msgbox:icondata'))
        end
        if ~isnumeric(IconData)
            error(message('MATLAB:msgbox:IncorrectIconDataType'))
        end
        if ~isnumeric(IconCMap)
            error(message('MATLAB:msgbox:IncorrectIconColormap'))
        end
    case {'none','help','warn','error'}
        % icon String OK
    otherwise
        warning(message('MATLAB:msgbox:iconstring'));
        IconString='none';
end

Black = [0 0 0];

%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefFigPos=get(0,'DefaultFigurePosition');

MsgOff=7;
IconWidth = 32 * 72/get(groot,'ScreenPixelsPerInch');
IconHeight = 32 * 72/get(groot,'ScreenPixelsPerInch');

if strcmp(IconString,'none')
    FigWidth=125;
    if(~isunix)
        % Figure width for windows
        FigWidth=150;
    end
    MsgTxtWidth=FigWidth-2*MsgOff;
else
    FigWidth=190;
    MsgTxtWidth=FigWidth-2*MsgOff-IconWidth;
end
FigHeight=50;
DefFigPos(3:4)=[FigWidth FigHeight];

OKWidth=40;
OKHeight=17;
OKXOffset=(FigWidth-OKWidth)/2;
OKYOffset=MsgOff;


MsgTxtXOffset=MsgOff;
MsgTxtYOffset=MsgOff+OKYOffset+OKHeight;
MsgTxtHeight=FigHeight-MsgOff-MsgTxtYOffset;
MsgTxtForeClr=Black;

IconXOffset=MsgTxtXOffset;
IconYOffset=FigHeight-MsgOff-IconHeight;

%%%%%%%%%%%%%%%%%%%%%
%%% Create MsgBox %%%
%%%%%%%%%%%%%%%%%%%%%

figureHandle=[];

% See if a modal or replace dialog already exists and delete all of its
% children
MsgboxTag = ['Msgbox_', TitleString];
if ~strcmp(CreateMode,'non-modal')
    TempHide=get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on');
    OldFig=findobj(0,'Type','figure','Tag',MsgboxTag,'Name',TitleString);
    set(0,'ShowHiddenHandles',TempHide);
    if ~isempty(OldFig)
        figureHandle=OldFig;
        if length(OldFig)>1
            figureHandle=OldFig(1);
            close(OldFig(2:end));
            OldFig(2:end)=[];  %#ok
        end % if length
        CurPos=get(figureHandle,'Position');
        CurPos(3:4)=[FigWidth FigHeight];
        set(figureHandle,'Position',CurPos);
        BoxChildren=get(figureHandle,'Children');
        delete(BoxChildren);
        figure(figureHandle);
    end
end

if strcmpi(CreateMode,'modal')
    WindowStyle='modal';
else
    WindowStyle='normal';
end

if isempty(figureHandle)
    figureHandle=dialog(                                ...
        'Name'            ,TitleString             , ...
        'Pointer'         ,'arrow'                 , ...
        'Units'           ,'points'                , ...
        'Visible'         ,'off'                   , ...
        'KeyPressFcn'     ,@doKeyPress             , ...
        'WindowStyle'     ,WindowStyle             , ...
        'Toolbar'         ,'none'                  , ...
        'HandleVisibility','on'                    , ...
        'Tag'             ,MsgboxTag                 ...
        );
    % should this be 'on' to match the case below?
    %'HandleVisibility','callback'              , ...

else
    set(figureHandle,   ...
        'WindowStyle'     ,WindowStyle, ...
        'HandleVisibility','on'         ...
        );
end 

FigColor=get(figureHandle,'Color');

MsgTxtBackClr=FigColor;

Font.FontUnits='points';
Font.FontSize=get(0,'FactoryUicontrolFontSize');
Font.FontName=get(0,'FactoryUicontrolFontName');
Font.FontWeight=get(figureHandle,'DefaultUicontrolFontWeight');

StFont = Font;
StFont.FontWeight=get(figureHandle, 'DefaultTextFontWeight');

okPos = [ OKXOffset OKYOffset OKWidth OKHeight ];
OKHandle=uicontrol(figureHandle                             , ...
    Font                                                    , ...
    'Style'              ,'pushbutton'                      , ...
    'Units'              ,'points'                          , ...
    'Position'           , okPos                            , ...
    'Callback'           ,'delete(gcbf)'                    , ...
    'KeyPressFcn'        ,@doKeyPress                       , ...
    'String'             ,getString(message('MATLAB:uistring:popupdialogs:OK'))                              , ...
    'HorizontalAlignment','center'                          , ...
    'Tag'                ,'OKButton'                          ...
    );

msgPos = [ MsgTxtXOffset MsgTxtYOffset MsgTxtWidth MsgTxtHeight ];
MsgHandle=uicontrol(figureHandle         , ...
    StFont                               , ...
    'Style'              ,'text'         , ...
    'Units'              ,'points'       , ...
    'Position'           , msgPos        , ...
    'String'             ,' '            , ...
    'Tag'                ,'MessageBox'   , ...
    'HorizontalAlignment','left'         , ...
    'BackgroundColor'    ,MsgTxtBackClr  , ...
    'ForegroundColor'    ,MsgTxtForeClr    ...
    );


[WrapString,NewMsgTxtPos]=textwrap(MsgHandle,{inputStr},75);
delete(MsgHandle);

% place an axes for the messge string (use an axes so we can get
% latex interpreter if required
AxesHandle=axes( ...
    'Parent'             ,figureHandle  , ...
    'Position'           ,[0 0 1 1]     , ...
    'Visible'            ,'off'           ...
    );

texthandle = text( ...
    'Parent'              ,AxesHandle                        , ...
    'Units'               ,'points'                          , ...
    'String'              ,WrapString                        , ...
    'Color'               ,get(OKHandle,'ForegroundColor')   , ...
    StFont                                                   , ...
    'HorizontalAlignment' ,'left'                            , ...
    'VerticalAlignment'   ,'bottom'                          , ...
    'Interpreter'         ,Interpreter                       , ...
    'Tag'                 ,'MessageBox'                        ...
    );

textExtent = get(texthandle, 'Extent');

%textExtent and extent from uicontrol are not the same. For window, extent from uicontrol is larger
%than textExtent. But on Mac, it is reverse. Pick the max value.
MsgTxtWidth=max([MsgTxtWidth NewMsgTxtPos(3) textExtent(3)]);
MsgTxtHeight=max([MsgTxtHeight NewMsgTxtPos(4) textExtent(4)]);

if ~strcmp(IconString,'none')
    MsgTxtXOffset=IconXOffset+IconWidth+MsgOff;
    FigWidth=MsgTxtXOffset+MsgTxtWidth+MsgOff;
    % Center Vertically around icon
    if IconHeight>MsgTxtHeight
        IconYOffset=OKYOffset+OKHeight+MsgOff;
        MsgTxtYOffset=IconYOffset+(IconHeight-MsgTxtHeight)/2;
        FigHeight=IconYOffset+IconHeight+MsgOff;
        % center around text
    else
        MsgTxtYOffset=OKYOffset+OKHeight+MsgOff;
        IconYOffset=MsgTxtYOffset+(MsgTxtHeight-IconHeight)/2;
        FigHeight=MsgTxtYOffset+MsgTxtHeight+MsgOff;
    end

else
    FigWidth=MsgTxtWidth+2*MsgOff;
    MsgTxtYOffset=OKYOffset+OKHeight+MsgOff;
    FigHeight=MsgTxtYOffset+MsgTxtHeight+MsgOff;
end % if ~strcmp

OKXOffset=(FigWidth-OKWidth)/2;
% if there is a figure out there and it's modal, we need to be modal too
if ~isempty(gcbf) && strcmp(get(gcbf,'WindowStyle'),'modal')
    set(figureHandle,'WindowStyle','modal');
end

set(OKHandle,'Position',[OKXOffset OKYOffset OKWidth OKHeight]);

txtPos = [ MsgTxtXOffset MsgTxtYOffset 0 ];
set(texthandle, 'Position'            ,txtPos);

if ~strcmp(IconString,'none')
    % create an axes for the icon
    iconPos = [IconXOffset IconYOffset IconWidth IconHeight];
    IconAxes=axes(                                   ...
        'Parent'          ,figureHandle               , ...
        'Units'           ,'points'                , ...
        'Position'        ,iconPos                 , ...
        'Tag'             ,'IconAxes'                ...
        );

    if ~strcmp(IconString,'custom')
        % Cases where IconString will be one of 'help','warn' or 'error'
        Img = setupStandardIcon(IconAxes, IconString);        
    else
        % place the icon - if this fails, rethrow the error
        % after deleting the figure
        try
            Img=image('CData',IconData,'Parent',IconAxes);
            set(figureHandle, 'Colormap', IconCMap);
        catch ex
            delete(figureHandle);
            rethrow(ex);
        end
    end
    if ~isempty(get(Img,'XData')) && ~isempty(get(Img,'YData'))
        set(IconAxes          , ...
            'XLim'            ,get(Img,'XData')+[-0.5 0.5], ...
            'YLim'            ,get(Img,'YData')+[-0.5 0.5]  ...
            );
    end

    set(IconAxes          , ...
        'Visible'         ,'off'       , ...
        'YDir'            ,'reverse'     ...
        );

end % if ~strcmp

% make sure we are on screen
movegui(figureHandle)

set(figureHandle,'HandleVisibility','callback');

if nargout==1
    varargout{1}=figureHandle;
end

end

%%%%% InternalCreateFlag
function [Flag,CreateMode,Interpreter]=InternalCreateFlag(mode)
    Flag=0;
    CreateMode='non-modal';
    Interpreter='none';

    if isempty(mode)
        return;
    end

    if iscell(mode)
        mode=mode{:};
    end

    if isstruct(mode)

        if ~isfield(mode,'Interpreter') || ~isfield(mode,'WindowStyle')
            error(message('MATLAB:msgbox:InvalidInput'));
        end
        
        Interpreter=mode.Interpreter;
        mode=mode.WindowStyle;
    end

    if ~ischar(mode)
        return;
    end

    mode=lower(mode);
    switch(mode)
        case {'non-modal','modal','replace'}
         CreateMode = mode;
         Flag=1;
    end
end

%%%%% doKeyPress
function doKeyPress(obj, evd)
    switch(evd.Key)
        case {'return','space','escape'}
            delete(ancestor(obj,'figure'));
    end
end

function Img = setupStandardIcon(ax, iconName)
[iconData, alphaData] = matlab.ui.internal.dialog.DialogUtils.imreadDefaultIcon(iconName);  
Img=image('CData',iconData,'Parent',ax);
if ~isempty(alphaData)
    set(Img, 'AlphaData', alphaData)
end
end