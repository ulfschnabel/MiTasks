%% Basics

f = figure('name', nts, 'position', [0 0 330 230]);
uicontrol('Style', 'text', 'Position', [10 10 60 20], 'String', 'RDur Norm');

rdurleft = uicontrol('Style', 'edit' , 'Position', [75 10 30 20], 'String', '150');
rdurright = uicontrol('Style', 'edit' , 'Position', [110 10 30 20], 'String', '150');


uicontrol('Style', 'text', 'Position', [10 120 30 20], 'String', 'Hit');
uicontrol('Style', 'text', 'Position', [10 80 30 20], 'String', 'Err');
uicontrol('Style', 'text', 'Position', [60 150 30 20], 'String', 'Ori 1');
uicontrol('Style', 'text', 'Position', [100 150 70 20], 'String', 'Ori 2');

HitText(1) = uicontrol('Style', 'text', 'Position', [75 120 20 20], 'String', '0');
HitText(2) = uicontrol('Style', 'text', 'Position', [55 120 20 20], 'String', '0');

SpecHitText(1) = uicontrol('Style', 'text', 'Position', [135 120 20 20], 'String', '0');
SpecHitText(2) = uicontrol('Style', 'text', 'Position', [115 120 20 20], 'String', '0');

ErrText(1) = uicontrol('Style', 'text', 'Position', [75 80 20 20], 'String', '0');
ErrText(2) = uicontrol('Style', 'text', 'Position', [55 80 20 20], 'String', '0');

SpecErrText(1) = uicontrol('Style', 'text', 'Position', [135 80 20 20], 'String', '0');
SpecErrText(2) = uicontrol('Style', 'text', 'Position', [115 80 20 20], 'String', '0');

uicontrol('Style', 'text', 'Position', [150 120 80 20], 'String', 'FigSize');
fsizebox = uicontrol('Style', 'edit' , 'Position', [250 120 40 20], 'String', '80');

uicontrol('Style', 'text', 'Position', [150 95 80 20], 'String', 'Displacement');
posfacbox = uicontrol('Style', 'edit' , 'Position', [250 95 40 20], 'String', '0');

uicontrol('Style', 'text', 'Position', [250 40 40 20], 'String', 'Ezmode');
ezbox = uicontrol('Style', 'checkbox' , 'Position', [300 40 20 20], 'value', 0);

uicontrol('Style', 'text', 'Position', [250 10 40 20], 'String', 'Drumm');
drummbox = uicontrol('Style', 'checkbox' , 'Position', [300 10 20 20], 'value', 0);


%% Special

prewtext = uicontrol('Style', 'text', 'Position', [180 70 80 20], 'String', 'PassiveRew');
rewbox = uicontrol('Style', 'edit' , 'Position', [270 70 20 20], 'String', '0');
uicontrol('Style', 'text', 'Position', [210 200 50 20], 'String', 'PassDel');
pdbox = uicontrol('Style', 'edit' , 'Position', [270 200 30 20], 'String', '500');
plbox = uicontrol('Style', 'checkbox' , 'Position', [260 170 20 20], 'value', 1);
prbox = uicontrol('Style', 'checkbox' , 'Position', [290 170 20 20], 'value', 1);
wt = uicontrol('Style', 'text', 'Position', [10 200 60 20], 'String', num2str(wentthrough));
thbox = uicontrol('Style', 'edit' , 'Position', [70 200 60 20], 'String', '5000');
drawnow