function hLeg = funcUpdateLegend(hLeg, varargin)
    %FUNCUPDATELEGEND Update an existing funcCreateLegend layout in-place.
    %   hLeg = funcUpdateLegend(hLeg, "location", "northwest", "Absoffset", [dx dy], ...)
    %
    % Supported name-value overrides (all optional). Most of funcCreateLegend's
    % adjustable parameters are supported here, except creating new structural
    % elements (no new axes or arrows are created):
    %   "location"   : string, e.g., "north", "southwest", "eastoutside", etc.
    %   "Absoffset"  : [x y] pixels (mutually exclusive with Percoffset)
    %   "Percoffset" : [x% y%] (0..100), mutually exclusive with Absoffset
    %   "sides"      : "l", "r", "l+r" or "r+l" (layout recalculated)
    %   "Arrows"     : "on"/"off" (toggles visibility of existing arrows only)
    %   "Text"       : string array, labels; whitespaces replaced with underscores
    %   "Fontname"   : string, font name
    %   "Fontsize"   : positive numeric, font size
    %   "Linelength" : positive numeric, indicator line length (px)
    %   "Linewidth"  : positive numeric, line/arrow width
    %   "Linestyle"  : string[2], styles for left/right indicators (e.g., ["-","--"])
    %   "Colors"     : cell array of [r g b], one per dataset (values in 0..1)
    %
    % Notes:
    % - This function reuses the geometry of funcCreateLegend. It moves text,
    %   stub axes, arrows, and frame. It does not create or delete objects.
    % - If you switch "sides", the function will position any existing parts
    %   that are present in hLeg; missing parts are ignored.

    % Start from stored state
    x = hLeg.state;

    % Parse name-value overrides (minimal, no try/catch)
    pendingTextUpdate = false;
    pendingFontUpdate = false;
    for k = 1:2:numel(varargin)
        name = lower(string(varargin{k}));
        val  = varargin{k+1};
        if name == "location"
            x.szLocation = lower(string(val));
        elseif name == "absoffset"
            x.nAbsoffset = val; x.nPixelOffset = 1;
        elseif name == "percoffset"
            x.nPercoffset = val; x.nPixelOffset = 0;
        elseif name == "sides"
            s = lower(string(val));
            if s == "l"
                x.nAxisChoice = 1.0;
            elseif s == "r"
                x.nAxisChoice = 0.1;
            else
                x.nAxisChoice = 1.1;
            end
        elseif name == "arrows"
            x.bArrowsOn = strcmpi(val, "on");
        elseif name == "text"
            % Expect string array; normalize and store
            x.szText = convertCharsToStrings(val);
            x.szText = strrep(x.szText, ' ', '_');
            pendingTextUpdate = true;
        elseif name == "fontname"
            x.szFontname = lower(string(val));
            pendingFontUpdate = true;
        elseif name == "fontsize"
            x.nFontsize = double(val);
            pendingFontUpdate = true;
        elseif name == "linelength"
            x.nLinelength = double(val);
        elseif name == "linewidth"
            x.nLinewidth = double(val);
        elseif name == "linestyle"
            % Expect string[2]
            x.szLinestyle = lower(convertCharsToStrings(val));
        elseif name == "colors"
            x.nColors = val;
        end
    end

    % Axes position in pixels
    oldUnits = get(hLeg.axes_handle, "Units");
    set(hLeg.axes_handle, "Units", "pixels");
    nPosPlot = get(hLeg.axes_handle, "Position");
    set(hLeg.axes_handle, "Units", oldUnits);

    % Apply text/font changes first so size reflects new content
    if pendingTextUpdate
        set(hLeg.text, "String", x.szText);
    end
    if pendingFontUpdate
        set(hLeg.text, "FontName", x.szFontname, "FontSize", x.nFontsize);
    end

    % Ensure text box is fit to content and get its new size
    set(hLeg.text, "FitBoxToText", "on");
    pause(0.01); % allow graphics to update
    textPos = get(hLeg.text, "Position");
    % Trim tiny voids as in creation (width minus fontsize, height minus 4)
    textW = max(1, textPos(3) - x.nFontsize);
    textH = max(1, textPos(4) - 4);

    % Offset
    if x.nPixelOffset == 1
        nPixelShift = x.nAbsoffset;
    else
        nPixelShift = [nPosPlot(3)*x.nPercoffset(1)/100, nPosPlot(4)*x.nPercoffset(2)/100];
    end

    % Compute new origin of text box
    pText = local_determine_pos(nPosPlot, textW, textH, x.nLinelength, hLeg.line_thickness, nPixelShift, x.szLocation, x.nAxisChoice);
    set(hLeg.text, "Position", [pText(1), pText(2), textW, textH], "BackgroundColor", "white", "HorizontalAlignment", "left", "LineStyle", "none");

    % Move stub axes
    if ~isempty(hLeg.left_axes) && isgraphics(hLeg.left_axes)
        set(hLeg.left_axes, "Position", [pText(1)-x.nLinelength, pText(2), x.nLinelength, textH], ...
            "Units", "pixels", "XColor", "white", "YColor", "white", "TickDir", "out");
    end
    if ~isempty(hLeg.right_axes) && isgraphics(hLeg.right_axes)
        set(hLeg.right_axes, "Position", [pText(1)+textW, pText(2), x.nLinelength, textH], ...
            "Units", "pixels", "XColor", "white", "YColor", "white", "TickDir", "out");
    end

    % Update styles on stub lines (colors, linewidth, linestyle)
    if ~isempty(hLeg.left_lines)
        for i = 1:numel(hLeg.left_lines)
            if isgraphics(hLeg.left_lines(i))
                set(hLeg.left_lines(i), "LineWidth", x.nLinewidth);
                if numel(x.szLinestyle) >= 1
                    [ls1, mk1] = local_parse_style_token(x.szLinestyle(1));
                    set(hLeg.left_lines(i), "LineStyle", ls1, "Marker", mk1);
                end
                if numel(x.nColors) >= i && isnumeric(x.nColors{i})
                    set(hLeg.left_lines(i), "Color", x.nColors{i});
                end
            end
        end
    end
    if ~isempty(hLeg.right_lines)
        for i = 1:numel(hLeg.right_lines)
            if isgraphics(hLeg.right_lines(i))
                set(hLeg.right_lines(i), "LineWidth", x.nLinewidth);
                if numel(x.szLinestyle) >= 2
                    [ls2, mk2] = local_parse_style_token(x.szLinestyle(2));
                    set(hLeg.right_lines(i), "LineStyle", ls2, "Marker", mk2);
                end
                if numel(x.nColors) >= i && isnumeric(x.nColors{i})
                    set(hLeg.right_lines(i), "Color", x.nColors{i});
                end
            end
        end
    end

    % Move arrows (if they exist); we do not create or delete here
    nNumTests = x.nDataNumber;
    nCorrFactor = 0.65;
    nYLimitRange = nNumTests - 1 + 2*nCorrFactor;
    for i = 1:numel(hLeg.arrows_left)
        if isgraphics(hLeg.arrows_left(i))
            if x.bArrowsOn
                set(hLeg.arrows_left(i), "Visible", "on");
            else
                set(hLeg.arrows_left(i), "Visible", "off");
            end
            nHighFactor = (0.65 + (i-1)) / nYLimitRange;
            pos = [pText(1) - x.nLinelength + 5*x.nLinewidth, ...
                   pText(2) + textH - nHighFactor*textH + hLeg.line_thickness, ...
                  -5*x.nLinewidth, 0];
            set(hLeg.arrows_left(i), "Position", pos);
            % Color follows dataset color if provided
            if numel(x.nColors) >= i && isnumeric(x.nColors{i})
                set(hLeg.arrows_left(i), "Color", x.nColors{i});
            end
        end
    end
    for i = 1:numel(hLeg.arrows_right)
        if isgraphics(hLeg.arrows_right(i))
            if x.bArrowsOn
                set(hLeg.arrows_right(i), "Visible", "on");
            else
                set(hLeg.arrows_right(i), "Visible", "off");
            end
            nHighFactor = (0.65 + (i-1)) / nYLimitRange;
            pos = [pText(1) + textW + x.nLinelength - 5*x.nLinewidth, ...
                   pText(2) + textH - nHighFactor*textH + hLeg.line_thickness, ...
                    5*x.nLinewidth, 0];
            set(hLeg.arrows_right(i), "Position", pos);
            if numel(x.nColors) >= i && isnumeric(x.nColors{i})
                set(hLeg.arrows_right(i), "Color", x.nColors{i});
            end
        end
    end

    % Move frame
    if isgraphics(hLeg.frame)
        if x.nAxisChoice == 1.0          % left only
            set(hLeg.frame, "Position", [pText(1)-x.nLinelength-hLeg.line_thickness, pText(2)-hLeg.line_thickness, textW + 1*x.nLinelength + 2*hLeg.line_thickness, textH + 2*hLeg.line_thickness]);
        elseif x.nAxisChoice == 0.1      % right only
            set(hLeg.frame, "Position", [pText(1)-hLeg.line_thickness, pText(2)-hLeg.line_thickness, textW + 1*x.nLinelength + 2*hLeg.line_thickness, textH + 2*hLeg.line_thickness]);
        else                             % both
            set(hLeg.frame, "Position", [pText(1)-x.nLinelength-hLeg.line_thickness, pText(2)-hLeg.line_thickness, textW + 2*x.nLinelength + 2*hLeg.line_thickness, textH + 2*hLeg.line_thickness]);
        end
    end

    % Toggle visibility of left/right stubs if "sides" was changed and handles exist
    if isfield(hLeg, "left_axes") && isgraphics(hLeg.left_axes)
        if x.nAxisChoice == 0.1
            set(hLeg.left_axes, "Visible", "off");
            if ~isempty(hLeg.left_lines), set(hLeg.left_lines, "Visible", "off"); end
            if ~isempty(hLeg.arrows_left), set(hLeg.arrows_left, "Visible", "off"); end
        else
            set(hLeg.left_axes, "Visible", "on");
            if ~isempty(hLeg.left_lines), set(hLeg.left_lines, "Visible", "on"); end
            if x.bArrowsOn && ~isempty(hLeg.arrows_left), set(hLeg.arrows_left, "Visible", "on"); end
        end
    end
    if isfield(hLeg, "right_axes") && isgraphics(hLeg.right_axes)
        if x.nAxisChoice == 1.0
            set(hLeg.right_axes, "Visible", "off");
            if ~isempty(hLeg.right_lines), set(hLeg.right_lines, "Visible", "off"); end
            if ~isempty(hLeg.arrows_right), set(hLeg.arrows_right, "Visible", "off"); end
        else
            set(hLeg.right_axes, "Visible", "on");
            if ~isempty(hLeg.right_lines), set(hLeg.right_lines, "Visible", "on"); end
            if x.bArrowsOn && ~isempty(hLeg.arrows_right), set(hLeg.arrows_right, "Visible", "on"); end
        end
    end

    % Persist updated state and return
    hLeg.state = x;
end

% =================== local helper (geometry) ==============================
function nPos = local_determine_pos(nPosPlot, nLength, nHigh, nLineLength, nLineThickness, nPixelShift, szLocation, nAxisChoice)
    % Geometry copied from funcDeterminePos to avoid duplication across files.

    % Anchor candidates on plot
    nXHalf = nPosPlot(1)+0.5*nPosPlot(3);
    nYHalf = nPosPlot(2)+0.5*nPosPlot(4);
    switch char(szLocation)
        case {"east","eastoutside"}
            nOrientationPos = [nPosPlot(1)+nPosPlot(3), nYHalf];
        case {"south","southoutside"}
            nOrientationPos = [nXHalf, nPosPlot(2)];
        case {"west","westoutside"}
            nOrientationPos = [nPosPlot(1), nYHalf];
        case {"north","northoutside"}
            nOrientationPos = [nXHalf, nPosPlot(2)+nPosPlot(4)];
        case {"northeast","northeastoutside"}
            nOrientationPos = [nPosPlot(1)+nPosPlot(3), nPosPlot(2)+nPosPlot(4)];
        case {"northwest","northwestoutside"}
            nOrientationPos = [nPosPlot(1), nPosPlot(2)+nPosPlot(4)];
        case {"southeast","southeastoutside"}
            nOrientationPos = [nPosPlot(1)+nPosPlot(3), nPosPlot(2)];
        case {"southwest","southwestoutside"}
            nOrientationPos = [nPosPlot(1), nPosPlot(2)];
        otherwise
            error("Wrong location.");
    end

    % Offsets from anchor to text origin
    if nAxisChoice == 1.0        % left only
        nPosDown      = [nLength*0.5-0.5*nLineLength-nLineThickness, -nLineThickness];
        nPosUp        = [nLength*0.5-0.5*nLineLength-nLineThickness, nHigh+nLineThickness];
        nPosLeft      = [-nLineLength-nLineThickness, nHigh*0.5];
        nPosRight     = [nLength+nLineThickness,     nHigh*0.5];
        nPosDownLeft  = [-nLineLength-nLineThickness, -nLineThickness];
        nPosDownRight = [nLength+nLineThickness,      -nLineThickness];
        nPosUpLeft    = [-nLineLength-nLineThickness,  nHigh+nLineThickness];
        nPosUpRight   = [nLength+nLineLength+nLineThickness, nHigh+nLineThickness]; % not used
    elseif nAxisChoice == 0.1    % right only
        nPosDown      = [nLength*0.5+0.5*nLineLength+nLineThickness, -nLineThickness];
        nPosUp        = [nLength*0.5+0.5*nLineLength+nLineThickness, nHigh+nLineThickness];
        nPosLeft      = [-nLineThickness,              nHigh*0.5];
        nPosRight     = [nLength+nLineLength+nLineThickness, nHigh*0.5];
        nPosDownLeft  = [-nLineThickness,              -nLineThickness];
        nPosDownRight = [nLength+nLineLength+nLineThickness, -nLineThickness];
        nPosUpLeft    = [-nLineThickness,               nHigh+nLineThickness];
        nPosUpRight   = [nLength+nLineLength+nLineThickness, nHigh+nLineThickness];
    else                        % both
        nPosDown      = [nLength*0.5, -nLineThickness];
        nPosUp        = [nLength*0.5,  nHigh+nLineThickness];
        nPosLeft      = [-nLineLength-nLineThickness, nHigh*0.5];
        nPosRight     = [nLength+nLineLength+nLineThickness, nHigh*0.5];
        nPosDownLeft  = [-nLineLength-nLineThickness, -nLineThickness];
        nPosDownRight = [nLength+nLineLength+nLineThickness, -nLineThickness];
        nPosUpLeft    = [-nLineLength-nLineThickness,  nHigh+nLineThickness];
        nPosUpRight   = [nLength+nLineLength+nLineThickness, nHigh+nLineThickness];
    end

    switch char(szLocation)
        case "east",           nPos = nOrientationPos - nPosRight + [-nPixelShift(1), 0];
        case "south",          nPos = nOrientationPos - nPosDown  + [0,  nPixelShift(2)];
        case "west",           nPos = nOrientationPos - nPosLeft  + [ nPixelShift(1), 0];
        case "north",          nPos = nOrientationPos - nPosUp    + [0, -nPixelShift(2)];
        case "northeast",      nPos = nOrientationPos - nPosUpRight   + [-nPixelShift(1), -nPixelShift(2)];
        case "northwest",      nPos = nOrientationPos - nPosUpLeft    + [ nPixelShift(1), -nPixelShift(2)];
        case "southeast",      nPos = nOrientationPos - nPosDownRight + [-nPixelShift(1),  nPixelShift(2)];
        case "southwest",      nPos = nOrientationPos - nPosDownLeft  + [ nPixelShift(1),  nPixelShift(2)];
        case "eastoutside",    nPos = nOrientationPos - nPosLeft      + [ nPixelShift(1),  0];
        case "southoutside",   nPos = nOrientationPos - nPosUp        + [ 0,              -nPixelShift(2)];
        case "westoutside",    nPos = nOrientationPos - nPosRight     + [-nPixelShift(1),  0];
        case "northoutside",   nPos = nOrientationPos - nPosDown      + [ 0,               nPixelShift(2)];
        case "northeastoutside", nPos = nOrientationPos - nPosDownLeft  + [ nPixelShift(1),  nPixelShift(2)];
        case "northwestoutside", nPos = nOrientationPos - nPosDownRight + [-nPixelShift(1),  nPixelShift(2)];
        case "southeastoutside", nPos = nOrientationPos - nPosUpLeft    + [ nPixelShift(1), -nPixelShift(2)];
        case "southwestoutside", nPos = nOrientationPos - nPosUpRight   + [-nPixelShift(1), -nPixelShift(2)];
        otherwise, error("Error which cannot occur.");
    end
end

% =================== local helper (style parsing) =========================
function [linestyle, marker] = local_parse_style_token(tok)
%LOCAL_PARSE_STYLE_TOKEN Split a Matlab combined style token into LineStyle and Marker.
% Accepts strings like "-", "--", ":", "-.", "none", "o-", "d--", "x:", "p-.", "o".
% Returns:
%   linestyle in {'-','--',':','-.','none'}
%   marker    in {'none','o','+','*','.', 'x','s','d','^','v','>','<','p','h','_','|'}
    tok = char(string(tok)); % normalize
    % Known markers (short forms accepted by Marker property)
    markers = {'o','+','*','.', 'x','s','d','^','v','>','<','p','h','_','|'};
    marker = "none";
    % If token contains any marker char, extract it (assume one marker)
    for m = 1:numel(markers)
        if contains(tok, markers{m})
            marker = string(markers{m});
            tok = erase(tok, markers{m}); % remove marker symbol
            break;
        end
    end
    % Remaining token should be a line style
    switch strtrim(tok)
        case {'-','--',':','-.'}
            linestyle = string(strtrim(tok));
        case {'none',''}
            % If nothing remains, allow "none" (pure marker) or default to solid
            if marker ~= "none"
                linestyle = "none";
            else
                linestyle = "-";
            end
        otherwise
            % Fallback to solid if an unknown fragment slipped through
            linestyle = "-";
    end
end
