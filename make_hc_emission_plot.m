% 'Test'script/ Development script of the funcCreateLegend function.
% Recreates five figures demonstrating funcCreateLegend(...) usage.
% Figures are 1200x800 px, both y-axes black, and saved as Example1..5.png.
% Tested and developed with MatLab R2022b

close all;
clear;
clc;

% ----- data (same for all figures) -----
n = 300;
x = 1:n;
xlabel_text = "# of occurrence";
y1_label = "HC-Emission";
y2_label = "HC-Emission-Acc.";
target_sum = 18000;

tau = 20.0;
y1_model = ...
    600 * exp(-(x) / tau) + ...
    1400 * exp(-((x - 3.0) .^ 2) / (2 * 1.2 ^ 2)) + ...
    350  * exp(-((x - 8.0) .^ 2) / (2 * 1.8 ^ 2)) + ...
    175  * exp(-((x - 35.0) .^ 2) / (2 * 4.0 ^ 2)) + ...
    250  * exp(-((x - 200.0) .^ 2) / (2 * 5.0 ^ 2));

scale = target_sum / sum(y1_model);
y1 = y1_model * scale;
y2 = cumsum(y1);

blue = [0 0.4470 0.7410];
this_dir = fullfile(fileparts(mfilename("fullpath")), "resources");

%% --- Figure 1: default custom legend call --------------------------------
f = newfig();
ax = axes("Parent", f);
plot(ax, x, y1, "-", "LineWidth", 0.9, "Color", blue);
yyaxis(ax, "right");
plot(ax, x, y2, "--", "LineWidth", 1.1, "Color", blue);
yyaxis(ax, "left");
setup_axes(ax, n, y1_label, y2_label, xlabel_text);

t = "funcCreateLegend()";
title(ax, t, "Interpreter", "none");
funcCreateLegend();

exportgraphics(f, fullfile(this_dir, "Example1.png"));

%% --- Figure 2: DataNumber + sides l+r ------------------------------------
f = newfig(); ax = axes("Parent", f);
plot(ax, x, y1, "-", "LineWidth", 0.9, "Color", blue);
yyaxis(ax, "right");
plot(ax, x, y2, "--", "LineWidth", 1.1, "Color", blue);
yyaxis(ax, "left");
setup_axes(ax, n, y1_label, y2_label, xlabel_text);

t = "funcCreateLegend('DataNumber', 1, 'sides', 'l+r')";
title(ax, t, "Interpreter", "none");
funcCreateLegend("DataNumber", 1, "sides", "l+r");

exportgraphics(f, fullfile(this_dir, "Example2.png"));

%% --- Figure 3: + location north, Linelength 50 ---------------------------
f = newfig(); ax = axes("Parent", f);
plot(ax, x, y1, "-", "LineWidth", 0.9, "Color", blue);
yyaxis(ax, "right");
plot(ax, x, y2, "--", "LineWidth", 1.1, "Color", blue);
yyaxis(ax, "left");
setup_axes(ax, n, y1_label, y2_label, xlabel_text);

t = "funcCreateLegend('DataNumber', 1, 'sides', 'l+r', 'location', 'north', 'Linelength', 50)";
title(ax, t, "Interpreter", "none");
funcCreateLegend("DataNumber", 1, "sides", "l+r", "location", "north", "Linelength", 50);

exportgraphics(f, fullfile(this_dir, "Example3.png"));

%% --- Figure 4: + Text and Absoffset --------------------------------------
f = newfig(); ax = axes("Parent", f);
plot(ax, x, y1, "-", "LineWidth", 0.9, "Color", blue);
yyaxis(ax, "right");
plot(ax, x, y2, "--", "LineWidth", 1.1, "Color", blue);
yyaxis(ax, "left");
setup_axes(ax, n, y1_label, y2_label, xlabel_text);

t = "funcCreateLegend('DataNumber', 1, 'sides', 'l+r', 'location', 'north', 'Linelength', 50, 'Text', 'Test1', 'Absoffset', [0, 70])";
title(ax, t, "Interpreter", "none");
funcCreateLegend("DataNumber", 1, "sides", "l+r", "location", "north", ...
                 "Linelength", 50, "Text", "Test1", "Absoffset", [0, 70]);

exportgraphics(f, fullfile(this_dir, "Example4.png"));

%% --- Figure 5: + Linestyle override for both series ----------------------
f = newfig(); ax = axes("Parent", f);
plot(ax, x, y1, "o-", "LineWidth", 0.9, "MarkerSize", 4, "Color", blue);
yyaxis(ax, "right");
plot(ax, x, y2, "d--", "LineWidth", 1.1, "MarkerSize", 4, "Color", blue);
yyaxis(ax, "left");
setup_axes(ax, n, y1_label, y2_label, xlabel_text);

t = "funcCreateLegend('DataNumber', 1, 'sides', 'l+r', 'location', 'north', 'Linelength', 50, 'Linestyle', ['o-', 'd--'])";
title(ax, t, "Interpreter", "none");
% Use a cell array for the actual argument; title shows the exact string.
funcCreateLegend("DataNumber", 1, "sides", "l+r", "location", "north", "Linelength", 50, "Linestyle", ["o-", "d--"]);

exportgraphics(f, fullfile(this_dir, "Example5.png"));

% ====================== local functions (must be at end) ==================
function f = newfig()
% Create a 1200x800 px figure with no toolbar/menubar.
f = figure("Color", "w", "ToolBar", "none", "MenuBar", "none", ...
           "Units", "pixels", "Position", [100 100 1200 800]);
end

function setup_axes(axh, n, y1_label, y2_label, xlabel_text)
% Format axes: dual y-axes in black, fixed limits, labels.
hold(axh, "on"); grid(axh, "off"); box(axh, "on");

yyaxis(axh, "left");
axh.YColor = [0 0 0];
ylabel(axh, y1_label);
xlim(axh, [0 n]);
ylim(axh, [0 2500]);

yyaxis(axh, "right");
axh.YColor = [0 0 0];
ylabel(axh, y2_label);
ylim(axh, [0 19000]);

xlabel(axh, xlabel_text);
end
