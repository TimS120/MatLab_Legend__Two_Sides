% The function is usable without any given parameters. In germany we would
% say: "Alles kann, nichts muss." Despite this, it's still possible to
% state a bunch of parameters.
% The following guide describes the parameters in the order they appear in
% the function funcValidation.
%
%Available inputs for funcCreateLegend(input):
%
%Parameter 'Text':
%   -The text which shall be written on the legend. (Whitespaces will be 
%   replaced with underscores)
%
%   Type: cell-array with strings/chars
%   
%   Options: Everything
%
%   Default: {"data1", "data2", "data3", "data4", "data5", "data6", "data7"}
%
%   Example: 'Text', {"Data1", "Data2", "Data3"}
%
%
%Prameter 'Location':
%   -The location where the legend has to be in respect to the current plot
%   -Very similar to the location of the normal legend, but with the
%   exception, that the options 'best', 'bestoutside', 'layout' and 'none' 
%   are not existing.
%
%   Type: String/char
%   
%   Options: 'north', 'south', 'west', 'east', 'northwest', 'northeast', 
%   'southwest', 'southeast', 'northoutside', 'southoutsid', 'westoutside',
%   'eastoutside'
%
%   Default: 'northeast'
%
%   Example: 'location', 'southwest'
%
%
%Parameter 'sides':
%   -The side(s) of the lines for indication of the y-axis
%
%   Type: String/char
%
%   Options: 'l', 'r', 'l+r' and 'r+l'
%
%   Default: 'l'
%
%   Example: 'sides', 'l+r'
%
%
%Parameter 'Fontname'
%   -Fontname of the text in the legend
%
%   Type: String/char
%
%   Options: Every name of standard font
%
%   Default: 'Arial'
%
%   Example: 'Fontname', 'Arial'
%
%
%Parameter 'Fontsize':
%   -Size of the text in the legend
%
%   Type: Numeric
%
%   Options: Everything bigger than 0
%
%   Default: 20
%
%   Example: 'Fontsize', 42
%
%
%Parameter 'Arrows':
%   -Arrows for indication which line is for which axis
%
%   Type: String/char
%
%   Options: 'on', 'off'
%
%   Default: 'off' for one side, 'on' for both sides
%
%   Example: 'Arrows', 'on'
%
%
%Parameter 'Linelength':
%   -Length of the lines for indication of the linestyle
%
%   Type: Numeric
%
%   Options: Every number > 0
%
%   Default: 26
%
%   Example: 'Linelength', 42
%
%
%Parameter 'Linewidth':
%   -Width of the lines/arrows in the legende for indication the
%   lines/sides
%
%   Type: Numeric
%
%   Options: Every number > 0
%
%   Default: 1
%
%   Example: 'Linewidth', 3.14
%
%
%Parameter 'Absoffset'/'Percoffset':
%   -Offset in absolute pixel or as percentage of the length/hight of the
%   current plot in x- and y-direction
%
%   Type: 2 numbers (numeric) as 1x2 vector
%
%   Options: Abs: Every number > 0, Perc: Every number between 0 and 100; 
%   it's not allowed to use both options simultanously
%
%   Default: 'AbsOffset', [15, 15]
%
%   Example: 'PercOffset', [50, 50] %The legend is with one corner
%   connected to the mid
%
%
%Parameter 'Linestyle':
%   -Linestyle of the indication lines in the legend
%
%   Type: Strings as 1x2 vector
%
%   Options: Every linestyle from matlab
%
%   Default: ["-", "--"] %Leftside fullline, rightside dashed
%
%   Example: 'Linestyle', ["--", "-"]
%
%
%Parameter 'Colors':
%   -The colors of the lines for for indication which dataset is which line
%
%   Type: Cell-array with color-vectors (1x3 number array)
%
%   Options: Every colorcode (three elements, each element between 0 and 1, both included)
%
%   Default: The default colors of the matlab 2-D-Plot
%
%   Example: 'Colors', {[1, 1, 1], [1, 1, 0], [1, 0, 0]} %Here for 3
%   Datasets
%
%
%Parameter 'DataNumber':
%   -Number of datasets
%
%   Type: Numeric
%
%   Options: Every Number > 0
%
%   Default: The Number of datasets plotted in the current plot
%
%   Example: 'DataNumber', 5


function hLeg = funcCreateLegend(varargin)
    % Arg1: Additional settings
    %
    % The function creates a legend with additional options which can't be
    % delivered by the normal legend() -function. The actual purpos of this
    % function was the visual presentation of two connected datasets on the two
    % y-axes and their different linetypes.

    %% Preparation
    nLineThickness = 0.5;  % Thickness of the legend frameline
    hAxis = gca;
    szUnit = get(hAxis, 'units');

    bNewUnit = false;  % Variable to check if the units of the plot are not 'pixels'
    if(~strcmp(szUnit, "pixels"))
        bNewUnit = true;
        set(hAxis, 'units', 'pixel');
    end
    nPlotPos = get(hAxis, 'Position');

    x = funcManageInput(varargin);  % Conditioning of the additional input (settings)
    nNumTests = x.nDataNumber;
    
    %% Creation of the legend
    % Textfield of the legend
    hA1 = annotation('textbox', 'String', x.szText, 'interpreter', 'none');
    set(hA1, "Tag", "CreateLegend_Text");
    set(hA1, 'BackgroundColor', 'white', 'HorizontalAlignment', 'left', 'LineStyle', 'none',...
        'Units', 'pixels', 'Fontname', x.szFontname, 'Fontsize', x.nFontsize);
    set(hA1, 'FitBoxToText', 'on');
    pause(0.1);  % This is necessary, because the last step wouldn't be executed without this
    nPos = get(hA1, 'Position');
    nPos(3) = nPos(3)-x.nFontsize;  % Delete the tiny void right next to the text
    nPos(4) = nPos(4)-4;  % Delete the tiny void under the text

    % Set the position of the legend
    if(x.nPixelOffset == 1)  % Offset in pixels
        nPixelShift = x.nAbsoffset;
    else  % Offset in percent
        nPixelShift(1) = nPlotPos(3)*x.nPercoffset(1)/100;
        nPixelShift(2) = nPlotPos(4)*x.nPercoffset(2)/100;
    end

    nPosTemp = funcDeterminePos(nPlotPos, nPos(3), nPos(4), x.nLinelength, nLineThickness, nPixelShift, x.szLocation, x.nAxisChoice);
    nPos = [nPosTemp(1), nPosTemp(2), nPos(3), nPos(4)];
    set(hA1, 'Position', nPos);
    
    x1 = [0, 0.5, 1];
    nCorrFactor = 0.65;
    nYLimitRange = nNumTests-1+2*nCorrFactor;

    % Lines of the leftside
    if(x.nAxisChoice == 1.0 || x.nAxisChoice == 1.1)
        pause(0.1);  % This is necessary, because the last step wouldn't be executed without this
        sLeft = axes();
        set(sLeft, "Tag", "CreateLegend_LeftAxes");
        leftLines = gobjects(1, nNumTests);
        arrowsLeft = gobjects(1, 0);  % may stay empty if arrows are off
        
        for i=1:nNumTests
            y = [nNumTests-i, nNumTests-i, nNumTests-i];
            p1 = plot(x1, y, x.szLinestyle(1));
            set(p1, 'color', x.nColors{1, i}, 'linewidth', x.nLinewidth);
            leftLines(i) = p1;
    
            % Arrows left
            if(x.bArrowsOn)
                a1 = annotation('textarrow');
                set(a1, "Tag", "CreateLegend_ArrowLeft", 'units', 'pixels', 'color', x.nColors{1, i});
                nHighFactor = ((0.65+(i-1))/nYLimitRange);
                nTempPos = [nPos(1)-x.nLinelength+5*x.nLinewidth, nPos(2)+nPos(4)-nHighFactor*nPos(4)+nLineThickness, -5*x.nLinewidth, 0];
                set(a1, 'pos', nTempPos);
                arrowsLeft(1, end+1) = a1; %#ok<AGROW>
            end
            hold on;
        end
        hold off;
    
        ylim([0-nCorrFactor, nNumTests-1+nCorrFactor]);
        set(sLeft, 'units', 'pixels', 'xTick', [], 'yTick', [], 'XColor', 'white', 'YColor', 'white', 'TickDir', 'out');
        set(sLeft, 'pos', [nPos(1)-x.nLinelength, nPos(2), x.nLinelength, nPos(4)]);
    end

    % Lines of the rightside
    if(x.nAxisChoice == 0.1 || x.nAxisChoice == 1.1)
        pause(0.1);  % This is necessary, because the last step wouldn't be executed without this
        sRight = axes();
        set(sRight, "Tag", "CreateLegend_RightAxes");
        rightLines = gobjects(1, nNumTests);
        arrowsRight = gobjects(1, 0);  % may stay empty if arrows are off
    
        for i=1:nNumTests
            y = [nNumTests-i, nNumTests-i, nNumTests-i];
            p1 = plot(x1,y, x.szLinestyle(2));
            set(p1, 'color', x.nColors{1, i}, 'linewidth', x.nLinewidth);
            rightLines(i) = p1;

            % Arrows right
            if(x.bArrowsOn)
                a1 = annotation('textarrow');
                set(a1, "Tag", "CreateLegend_ArrowRight", 'units', 'pixels', 'color', x.nColors{1, i});
                nHighFactor = ((0.65+(i-1))/nYLimitRange);
                nTempPos = [nPos(1)+nPos(3)+x.nLinelength-5*x.nLinewidth, nPos(2)+nPos(4)-nHighFactor*nPos(4)+nLineThickness, 5*x.nLinewidth, 0];
                set(a1, 'pos', nTempPos);
                arrowsRight(1, end+1) = a1; %#ok<AGROW>
            end
            hold on;
        end
        hold off;
        ylim([0-nCorrFactor, nNumTests-1+nCorrFactor]);
        set(sRight, 'units', 'pixels', 'xTick', [], 'yTick', [], 'XColor', 'white', 'YColor', 'white', 'TickDir', 'out');
        set(sRight, 'pos', [nPos(1)+nPos(3), nPos(2), x.nLinelength, nPos(4)]);
    end

    % Frame of the whole legend
    pause(0.1);  % This is necessary, because the last step wouldn't be executed without this
    hA2 = annotation('textbox');
    set(hA2, "Tag", "CreateLegend_Frame");
    set(hA2, 'units', 'pixels', 'BackgroundColor', 'none');

    if(x.nAxisChoice == 1.0)  % Left only
        set(hA2, 'pos', [nPos(1)-x.nLinelength-nLineThickness, nPos(2)-nLineThickness, nPos(3)+1*x.nLinelength+2*nLineThickness, nPos(4)+2*nLineThickness]);
    elseif(x.nAxisChoice == 0.1)  % Rights only
        set(hA2, 'pos', [nPos(1)-nLineThickness, nPos(2)-nLineThickness, nPos(3)+1*x.nLinelength+2*nLineThickness, nPos(4)+2*nLineThickness]);
    elseif(x.nAxisChoice == 1.1)  % Both sides
        set(hA2, 'pos', [nPos(1)-x.nLinelength-nLineThickness, nPos(2)-nLineThickness, nPos(3)+2*x.nLinelength+2*nLineThickness, nPos(4)+2*nLineThickness]);
    else
        error("Error side-choice!!");
    end

    if(bNewUnit)
        set(hAxis, 'units', szUnit);
    end
    hold off;

    % ---------- collect handles for external updates ----------
    hLeg = struct();
    hLeg.axes_handle    = hAxis;
    hLeg.text           = hA1;
    hLeg.frame          = hA2;
    if exist('sLeft', 'var'),  hLeg.left_axes  = sLeft;     else, hLeg.left_axes  = []; end
    if exist('sRight','var'),  hLeg.right_axes = sRight;    else, hLeg.right_axes = []; end
    if exist('leftLines','var'),  hLeg.left_lines  = leftLines;  else, hLeg.left_lines  = []; end
    if exist('rightLines','var'), hLeg.right_lines = rightLines; else, hLeg.right_lines = []; end
    if exist('arrowsLeft','var'),  hLeg.arrows_left  = arrowsLeft;  else, hLeg.arrows_left  = []; end
    if exist('arrowsRight','var'), hLeg.arrows_right = arrowsRight; else, hLeg.arrows_right = []; end
    % store layout state needed for recomputation
    hLeg.state          = x;
    hLeg.line_thickness = nLineThickness;

    % Store base metrics for optional auto-update
    hLeg.figure         = ancestor(hAxis,'figure');
    hLeg.auto.baseAxesWH     = [nPlotPos(3), nPlotPos(4)];
    hLeg.auto.baseFontsize   = x.nFontsize;
    hLeg.auto.baseLinelength = x.nLinelength;
    hLeg.auto.baseAbsoffset  = x.nAbsoffset;
    hLeg.auto.scaleAbs       = x.bScaleAbsOffset;

    % Keep a live copy of the legend struct on the text object
    setappdata(hLeg.text, 'CreateLegend_Handle', hLeg);

    % Attach resize listener if requested
    if isfield(x,'bAutoUpdate') && x.bAutoUpdate
        local_attach_autoupdate(hLeg);
    end
end

% =================== local helper: AutoUpdate wiring ======================
function local_attach_autoupdate(hLeg)
% Register this legend in the figure registry and hook SizeChangedFcn once.
    fig = hLeg.figure;
    if ~isgraphics(fig), return; end
    reg = getappdata(fig, 'CreateLegend_AutoRegistry');
    if isempty(reg)
        reg = struct('text', {}, 'baseAxesW', {}, 'baseAxesH', {}, ...
                     'baseFontsize', {}, 'baseLinelength', {}, ...
                     'baseAbsOffset', {}, 'scaleAbs', {});
    end
    % Append (handles inside hLeg are references; storing the struct is OK)
    entry.text          = hLeg.text;   % store handle, not struct
    entry.baseAxesW     = hLeg.auto.baseAxesWH(1);
    entry.baseAxesH     = hLeg.auto.baseAxesWH(2);
    entry.baseFontsize  = hLeg.auto.baseFontsize;
    entry.baseLinelength= hLeg.auto.baseLinelength;
    entry.baseAbsOffset = hLeg.auto.baseAbsoffset;
    entry.scaleAbs      = logical(hLeg.auto.scaleAbs);
    reg(end+1) = entry; %#ok<AGROW>
    setappdata(fig, 'CreateLegend_AutoRegistry', reg);

    % Install dispatcher only once; chain any existing callback
    if ~isappdata(fig,'CreateLegend_HookInstalled') || ~getappdata(fig,'CreateLegend_HookInstalled')
        prevHook = get(fig,'SizeChangedFcn');
        setappdata(fig,'CreateLegend_PrevSizeChangedFcn', prevHook);
        set(fig,'SizeChangedFcn', @CreateLegend_SizeChangedDispatcher);
        setappdata(fig,'CreateLegend_HookInstalled', true);
    end
end

function CreateLegend_SizeChangedDispatcher(src, ~)
% Dispatch figure resize to all registered legends (reflow + optional scale)
    % 1) Call any previous user hook first (best effort)
    prevHook = getappdata(src,'CreateLegend_PrevSizeChangedFcn');
    if ~isempty(prevHook)
        try
            if isa(prevHook,'function_handle')
                prevHook(src,[]);
            else
                feval(prevHook, src, []);
            end
        catch
            % swallow errors from foreign hooks
        end
    end
    % 2) Reflow registered legends
    reg = getappdata(src,'CreateLegend_AutoRegistry');
    if isempty(reg), return; end
    for k = 1:numel(reg)
        if ~isfield(reg(k),'text') || ~isgraphics(reg(k).text), continue; end
        % Always fetch the current legend struct (latest state)
        hL = getappdata(reg(k).text, 'CreateLegend_Handle');
        if isempty(hL) || ~isstruct(hL) || ~isgraphics(hL.axes_handle) || ~isgraphics(hL.text)
            continue;
        end
        % Current axes size in pixels
        oldU = get(hL.axes_handle,'Units');
        set(hL.axes_handle,'Units','pixels');
        ap = get(hL.axes_handle,'Position');
        set(hL.axes_handle,'Units', oldU);
        w = max(1, ap(3));
        % Scale factor (clamped for readability)
        r  = max(0.4, min(2.5, w / max(1, reg(k).baseAxesW)));
        ls = max(16, round(reg(k).baseLinelength * r));          % line length
        fs = max(8,  round(reg(k).baseFontsize   * sqrt(r)));    % milder scaling
        nv = {'Linelength', ls, 'Fontsize', fs};
        % Optionally scale absolute offsets too
        if reg(k).scaleAbs && isfield(hL,'state') && isfield(hL.state,'nPixelOffset') && hL.state.nPixelOffset == 1
            newAbs = round(reg(k).baseAbsOffset .* [r, sqrt(r)]);
            nv = [nv, {'Absoffset', newAbs}];
        end
        try
            hL = funcUpdateLegend(hL, nv{:}); % reflow with new metrics
            % Persist the latest struct for any future updates
            if isgraphics(hL.text)
                setappdata(hL.text, 'CreateLegend_Handle', hL);
            end
        catch
            % Ignore transient errors during interactive resizes
        end
    end
end

function nPos = funcDeterminePos(nPosPlot, nLength, nHigh, nLineLength, nLineThickness, nPixelShift, szLocation, nAxisChoice)
    % Ret1: the position of the text-annotation (everything is orientatet on this point)
    %
    % Arg1: 4-Element-Vector -position of the plot where the legend will be added
    % Arg2: Length of the text annoation
    % Arg3: High of the text annotation
    % Arg4: Length of the lines which are indicating the style of the lines
    % Arg5: Thickness of the legend frame
    % Arg6: Pixelshift between legend and plot-frame
    % Arg7: Location where the legende shall be placed
    % Arg8: Choice which axis are in action (only left, only right, both)
    %
    % Function determines the location where the legend has to be placed.
    % This position is in respect to the down left vertex of the
    % text-annotation.

    % Calculation of the position of the plot where the legend has to be connected with
    nOrientationPos = zeros(1, 2);  % Position where the legend has to be connected with
    nXHalf = nPosPlot(1)+0.5*nPosPlot(3);
    nYHalf = nPosPlot(2)+0.5*nPosPlot(4);
    
        
    if(strcmp(szLocation, "east") || strcmp(szLocation, "eastoutside"))
        nOrientationPos = [nPosPlot(1)+nPosPlot(3), nYHalf];
        
    elseif(strcmp(szLocation, "south") ||strcmp(szLocation, "southoutside"))
        nOrientationPos = [nXHalf, nPosPlot(2)];
        
    elseif(strcmp(szLocation, "west") ||strcmp(szLocation, "westoutside"))
        nOrientationPos = [nPosPlot(1), nYHalf];
        
    elseif(strcmp(szLocation, "north") ||strcmp(szLocation, "northoutside"))
        nOrientationPos = [nXHalf, nPosPlot(2)+nPosPlot(4)];
        
        
    elseif(strcmp(szLocation, "northeast") || strcmp(szLocation, "northeastoutside"))
        nOrientationPos = [nPosPlot(1)+nPosPlot(3), nPosPlot(2)+nPosPlot(4)];
        
    elseif(strcmp(szLocation, "northwest") || strcmp(szLocation, "northwestoutside"))
        nOrientationPos = [nPosPlot(1), nPosPlot(2)+nPosPlot(4)];
        
    elseif(strcmp(szLocation, "southeast") || strcmp(szLocation, "southeastoutside"))
        nOrientationPos = [nPosPlot(1)+nPosPlot(3), nPosPlot(2)];
        
    elseif(strcmp(szLocation, "southwest") || strcmp(szLocation, "southwestoutside"))
        nOrientationPos = [nPosPlot(1), nPosPlot(2)];  
    else
        error("Wrong location!");
    end
   
    % Calculation of the helpvariables. This variables are containing the
    % absolute x- and y- distance in pixel between the corner/edge of the
    % connection-point and the down left corner of the text annotation
    if(nAxisChoice == 1.0)  % Left only
        nPosDown = [nLength*0.5-0.5*nLineLength-nLineThickness, -nLineThickness];
        nPosUp = [nLength*0.5-0.5*nLineLength-nLineThickness, nHigh+nLineThickness];
        nPosLeft = [-nLineLength-nLineThickness, nHigh*0.5];
        nPosRight = [nLength+nLineThickness, nHigh*0.5];

        nPosDownLeft = [-nLineLength-nLineThickness, -nLineThickness];
        nPosDownRight = [nLength+nLineThickness, -nLineThickness];
        nPosUpLeft = [-nLineLength-nLineThickness, nHigh+nLineThickness];
        nPosUpRight = [nLength+nLineThickness, nHigh+nLineThickness];
    elseif(nAxisChoice == 0.1)  % Right only
        nPosDown = [nLength*0.5+0.5*nLineLength+nLineThickness, -nLineThickness];
        nPosUp = [nLength*0.5+0.5*nLineLength+nLineThickness, nHigh+nLineThickness];
        nPosLeft = [-nLineThickness, nHigh*0.5];
        nPosRight = [nLength+nLineLength+nLineThickness, nHigh*0.5];

        nPosDownLeft = [-nLineThickness, -nLineThickness];
        nPosDownRight = [nLength+nLineLength+nLineThickness, -nLineThickness];
        nPosUpLeft = [-nLineThickness, nHigh+nLineThickness];
        nPosUpRight = [nLength+nLineLength+nLineThickness, nHigh+nLineThickness];

    elseif(nAxisChoice == 1.1)  % Both sides
        nPosDown = [nLength*0.5, -nLineThickness];
        nPosUp = [nLength*0.5, nHigh+nLineThickness];
        nPosLeft = [-nLineLength-nLineThickness, nHigh*0.5];
        nPosRight = [nLength+nLineLength+nLineThickness, nHigh*0.5];
    
        nPosDownLeft = [-nLineLength-nLineThickness, -nLineThickness];
        nPosDownRight = [nLength+nLineLength+nLineThickness, -nLineThickness];
        nPosUpLeft = [-nLineLength-nLineThickness, nHigh+nLineThickness];
        nPosUpRight = [nLength+nLineLength+nLineThickness, nHigh+nLineThickness];

    else
        error("Error of the side-choice!");
    end

    % Actual calculation of the position
    if(strcmp(szLocation, "east"))
        nPos = nOrientationPos-nPosRight+[-nPixelShift(1), 0];
    elseif(strcmp(szLocation, "south"))
        nPos = nOrientationPos-nPosDown+[0, nPixelShift(2)];
    elseif(strcmp(szLocation, "west"))
        nPos = nOrientationPos-nPosLeft+[nPixelShift(1), 0];
    elseif(strcmp(szLocation, "north"))
        nPos = nOrientationPos-nPosUp+[0, -nPixelShift(2)];
        
        
    elseif(strcmp(szLocation, "northeast"))
        nPos = nOrientationPos-nPosUpRight+[-nPixelShift(1), -nPixelShift(2)];
    elseif(strcmp(szLocation, "northwest"))
        nPos = nOrientationPos-nPosUpLeft+[nPixelShift(1), -nPixelShift(2)];
    elseif(strcmp(szLocation, "southeast"))
        nPos = nOrientationPos-nPosDownRight+[-nPixelShift(1), nPixelShift(2)];    
    elseif(strcmp(szLocation, "southwest"))
        nPos = nOrientationPos-nPosDownLeft+[nPixelShift(1), nPixelShift(2)];
    
    elseif(strcmp(szLocation, "eastoutside"))
        nPos = nOrientationPos-nPosLeft+[nPixelShift(1), 0];
    elseif(strcmp(szLocation, "southoutside"))
        nPos = nOrientationPos-nPosUp+[0, -nPixelShift(2)];
    elseif(strcmp(szLocation, "westoutside"))
        nPos = nOrientationPos-nPosRight+[-nPixelShift(1), 0];
    elseif(strcmp(szLocation, "northoutside"))
        nPos = nOrientationPos-nPosDown+[0, nPixelShift(2)];

    elseif(strcmp(szLocation, "northeastoutside"))
        nPos = nOrientationPos-nPosDownLeft+[nPixelShift(1), nPixelShift(2)];
    elseif(strcmp(szLocation, "northwestoutside"))
        nPos = nOrientationPos-nPosDownRight+[-nPixelShift(1), nPixelShift(2)];
    elseif(strcmp(szLocation, "southeastoutside"))
        nPos = nOrientationPos-nPosUpLeft+[nPixelShift(1), -nPixelShift(2)];
    elseif(strcmp(szLocation, "southwestoutside"))
        nPos = nOrientationPos-nPosUpRight+[-nPixelShift(1), -nPixelShift(2)];

    else
        error("Error which can't be! :)");
    end
end

function x = funcManageInput(vardata)
    % Ret1: Structure which includes all parameters of the legend
    %
    % Arg1: All inputs
    %
    % Function creates a structure, similar to the inputParser scheme which
    % includes all the necessary data for the legend.


    %% Input and default values
    szDefaultText = ["data1", "data2", "data3", "data4", "data5", "data6", "data7"];
    szDefaultLocation = 'northeast';
    szDefaultSides = 'l';
    nDefaultFontSize = 20;
    szDefaultFontName = 'Arial';
    szDefaultArrows = 'off';
    nDefaultLineLength = 26;  % Length of the lines which shows the linestyle 26 is a good length for the legend without arrows and 30 with arrows
    nDefaultLineWidth = 1;
    nDefaultAbsOffset = [15,15];
    nDefaultPercOffset = [2,2];
    szDefaultLineStyle = ["-", "--"];
    szDefaultAutoUpdate = 'off';
    szDefaultScaleAbsOffset = 'off';
    nDefaultColorCode = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250]...
        [0.4940, 0.1840, 0.5560], [0.4660, 0.6740, 0.1880], [0.3010, 0.7450, 0.9330], [0.6350, 0.0780, 0.1840]};
    nDefaultDataNumber = length(findall(gca,'type','line'));  % Number of the datasets

    p = inputParser;
    addOptional(p, 'text', szDefaultText);
    addOptional(p, 'location', szDefaultLocation);
    addOptional(p, 'sides', szDefaultSides);
    addOptional(p, 'fontsize', nDefaultFontSize);
    addOptional(p, 'fontname', szDefaultFontName);
    addOptional(p, 'arrows', szDefaultArrows);
    addOptional(p, 'linelength', nDefaultLineLength);
    addOptional(p, 'linewidth', nDefaultLineWidth);
    addOptional(p, 'absoffset', nDefaultAbsOffset);
    addOptional(p, 'percoffset', nDefaultPercOffset);
    addOptional(p, 'linestyle', szDefaultLineStyle);
    addOptional(p, 'colors', nDefaultColorCode);
    addOptional(p, 'autoupdate', szDefaultAutoUpdate);
    addOptional(p, 'scaleabsoffset', szDefaultScaleAbsOffset);
    addOptional(p, 'datanumber', nDefaultDataNumber);
    parse(p, vardata{:});


    %% Editing of the parameters
    x.szText = p.Results.text;
    x.szLocation = p.Results.location;
    x.szSides = p.Results.sides;
    x.szFontname = p.Results.fontname;
    x.nFontsize = p.Results.fontsize;
    x.szArrows = p.Results.arrows;
    x.nLinelength = p.Results.linelength;
    x.nLinewidth = p.Results.linewidth;
    x.nAbsoffset = p.Results.absoffset;
    x.nPercoffset = p.Results.percoffset;
    x.szLinestyle = p.Results.linestyle;
    x.nColors = p.Results.colors;
    x.szAutoupdate = p.Results.autoupdate;
    x.szScaleabsoffset = p.Results.scaleabsoffset;
    x.nDataNumber = p.Results.datanumber;

    % Conversion of the entire string/char-input into (lowercase-) strings
    x.szText = convertCharsToStrings(x.szText);

    x.szLocation = lower(convertCharsToStrings(x.szLocation));
    x.szSides = lower(convertCharsToStrings(x.szSides));
    x.szFontname = lower(convertCharsToStrings(x.szFontname));
    x.szArrows = lower(convertCharsToStrings(x.szArrows));
    x.szLinestyle = lower(convertCharsToStrings(x.szLinestyle));
    x.szAutoupdate = lower(string(x.szAutoupdate));
    x.szScaleabsoffset = lower(string(x.szScaleabsoffset));

    % Validation of the input settings
    nFieldLength = length(fieldnames(x));
    szFieldNames = fieldnames(x);

    % Determination, in which state (default/not default) each parameter is
    szDefaultParam = strings(length(p.UsingDefaults),1);
    for i=1:length(p.UsingDefaults)
        szDefaultParam(i) = p.UsingDefaults{1, i};
    end

    nNumberData = x.nDataNumber;

    for i=1:nFieldLength
        aTemp = getfield(x, szFieldNames{i,1});
        if(~funcValidation(aTemp, szFieldNames{i,1}, nNumberData))
            szTemp = szFieldNames{i,1};
            szTemp = convertStringsToChars(szTemp);
            if(strcmp(szTemp(1,1), 's'))
                szTemp = szTemp(3:length(szTemp));
            elseif(strcmp(szTemp(1,1), 'n'))
                szTemp = szTemp(2:length(szTemp));
            end
            error("Wrong Parameter for '%s'", szTemp);
        end
    end


    szText = strings(1, nNumberData);
    for i=1:nNumberData
        szText(1, i) = x.szText(1,i);
    end
    szText = strrep(szText, ' ', '_');  % Replace the whitespaces which would cause new lines
    x.szText = szText;
    
    if(sum(ismember(szDefaultParam, "absoffset")) == 1 && sum(ismember(szDefaultParam, "percoffset")) == 1)  % Both elements are not forwarded: Default setting (absolute offset)
        x.nPixelOffset = 1;

    elseif(sum(ismember(szDefaultParam, "absoffset")) == 0 && sum(ismember(szDefaultParam, "percoffset")) == 1)  % Absolute-element forwarded: Absolute offset 
        x.nPixelOffset = 1;

    elseif(sum(ismember(szDefaultParam, "absoffset")) == 1 && sum(ismember(szDefaultParam, "percoffset")) == 0)  % Percent-element forwarded: Percentage offset 
        x.nPixelOffset = 0;

    elseif(sum(ismember(szDefaultParam, "absoffset")) == 0 && sum(ismember(szDefaultParam, "percoffset")) == 0)   % Both forwarded: Error!
        error("It's not possible to input both offsets--> Vagueness");

    else
        error("Error which can't occure! :)");
    end

    % Choice of the sides
    if(strcmp(x.szSides, "l"))
        x.nAxisChoice = 1.0;
    elseif(strcmp(x.szSides, "r"))
        x.nAxisChoice = 0.1;
    elseif(strcmp(x.szSides, "l+r") || strcmp(x.szSides, "r+l"))
        x.nAxisChoice = 1.1;
    end

    % Arrow choice
    if(strcmp(x.szArrows, "on"))
        x.bArrowsOn = true;
    elseif(strcmp(x.szArrows, "off"))
        x.bArrowsOn = false;
    else
        error("Wrong arrow choice!");
    end

    if(sum(ismember(szDefaultParam, "arrows")) == 1)  % If parameter 'arrows' is not forwarded
        if(x.nAxisChoice == 1.1)  % If both sides are on
            x.bArrowsOn = 1;
        end
    end

    % AutoUpdate / ScaleAbsOffset flags
    if strcmp(x.szAutoupdate,"on")
        x.bAutoUpdate = true;
    elseif strcmp(x.szAutoupdate,"off")
        x.bAutoUpdate = false;
    else
        error("Wrong AutoUpdate choice! Use 'on' or 'off'.");
    end
    if strcmp(x.szScaleabsoffset,"on")
        x.bScaleAbsOffset = true;
    elseif strcmp(x.szScaleabsoffset,"off")
        x.bScaleAbsOffset = false;
    else
        error("Wrong ScaleAbsOffset choice! Use 'on' or 'off'.");
    end
end

function bOut = funcValidation(x, szFunction, nNumberData)
    % Ret1: The boolean check-result
    %
    % Arg1: Value to be checked
    % Arg2: Name of the Value
    % Arg3: Number of datasets
    %
    % Function checks the forwarded value on the respective criteria and
    % gives the boolean value back.

    
    %% Function
    if(strcmp(szFunction, "szText"))
        bOut = isstring(x) && length(x)>=nNumberData;

    elseif(strcmp(szFunction, "szLocation"))
        bOut = isstring(x) && sum(ismember(x, ["north", "south", "west", "east", "northeast", "northwest", "southeast", "southwest", "eastoutside", "westoutside", "northoutside", "southoutside", "northeastoutside", "northwestoutside", "southeastoutside", "southwestoutside"])>0); %string und element loc
    
    elseif(strcmp(szFunction, "szSides"))
        bOut = isstring(x) && sum(ismember(x, ["l", "l+r", "r+l", "r"])>0);

    elseif(strcmp(szFunction, "szFontname"))
        szFontnames = listfonts;
        szTemp = strings(length(szFontnames), 1);
        for i=1:length(szFontnames)
            szTemp(i, 1) = lower(szFontnames{i, 1});
        end
        bOut = isstring(x) && ismember(x, szTemp);

    elseif(strcmp(szFunction, "nFontsize"))
        bOut = isnumeric(x) && x>0;

    elseif(strcmp(szFunction, "szArrows"))
        bOut = isstring(x) && sum(ismember(x, ["on", "off"])>0);

    elseif(strcmp(szFunction, "nLinelength"))
        bOut = isnumeric(x) && x>0;

    elseif(strcmp(szFunction, "nLinewidth"))
        bOut = isnumeric(x) && x>0;

    elseif(strcmp(szFunction, "nAbsoffset"))
        bOut = max(size(x))==2 && x(1)>=0 && x(2)>=0;

    elseif(strcmp(szFunction, "nPercoffset"))
        bOut = max(size(x))==2 && x(1)>=0 && x(1)<=100 && x(2)>=0 && x(2)<=100;

    elseif(strcmp(szFunction, "szLinestyle"))
        szLinestyle = strings(60, 1);
        nCount = 1;
        szLines = ["", "-", "--", ":", "-."];
        szMarker = ["", "o", "+", "*", ".", "x", "_", "|", "s", "d", "^", "v", ">", "<", "p", "h"];
        for i=1:length(szLines)
            for j=1:length(szMarker)
                szLinestyle(nCount, 1) = [convertStringsToChars(szMarker(j)), convertStringsToChars(szLines(i))];
                nCount = nCount+1;
            end
        end
        bOut = isstring(x) && max(size(x))==2 && ismember(x(1), szLinestyle) && ismember(x(2), szLinestyle);

    elseif(strcmp(szFunction, "nColors"))
        bOut = length(x)>=nNumberData;
        for i=1:max(size(x))
            if(max(x{1,i})>1 || min(x{1, i})<0 || isnumeric(x{1, 1})==0)
                bOut = false;
            end
        end  

    elseif(strcmp(szFunction, "nDataNumber"))
        bOut = isnumeric(x) && x>0;

     elseif(strcmp(szFunction, "szAutoupdate"))
         bOut = isstring(x) && sum(ismember(x, ["on","off"])>0);
 
     elseif(strcmp(szFunction, "szScaleabsoffset"))
         bOut = isstring(x) && sum(ismember(x, ["on","off"])>0);

    else
        error("Wrong attribute!");
        
    end
end
