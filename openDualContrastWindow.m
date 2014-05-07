%% Basics
bgfactor = input('Enter starting contrast multiplier \n');
f = figure('name', nts, 'position', [0 0 330 230]);
uicontrol('Style', 'text', 'Position', [10 10 60 20], 'String', 'RDur Norm');
uicontrol('Style', 'text', 'Position', [10 40 60 20], 'String', 'RDur Spec');
rdurleft = uicontrol('Style', 'edit' , 'Position', [75 10 30 20], 'String', '93');
rdurright = uicontrol('Style', 'edit' , 'Position', [110 10 30 20], 'String', '100');

uicontrol('Style', 'text', 'Position', [10 120 30 20], 'String', 'Hit');
uicontrol('Style', 'text', 'Position', [10 80 30 20], 'String', 'Err');
uicontrol('Style', 'text', 'Position', [60 150 30 20], 'String', '40/20');
uicontrol('Style', 'text', 'Position', [120 150 30 20], 'String', '80/40');

HitText(1) = uicontrol('Style', 'text', 'Position', [75 120 20 20], 'String', '0');
HitText(2) = uicontrol('Style', 'text', 'Position', [55 120 20 20], 'String', '0');

SpecHitText(1) = uicontrol('Style', 'text', 'Position', [135 120 20 20], 'String', '0');
SpecHitText(2) = uicontrol('Style', 'text', 'Position', [115 120 20 20], 'String', '0');

ErrText(1) = uicontrol('Style', 'text', 'Position', [75 80 20 20], 'String', '0');
ErrText(2) = uicontrol('Style', 'text', 'Position', [55 80 20 20], 'String', '0');

SpecErrText(1) = uicontrol('Style', 'text', 'Position', [135 80 20 20], 'String', '0');
SpecErrText(2) = uicontrol('Style', 'text', 'Position', [115 80 20 20], 'String', '0');

uicontrol('Style', 'text', 'Position', [230 40 60 20], 'String', 'Ezmode');
ezbox = uicontrol('Style', 'checkbox' , 'Position', [300 40 20 20], 'value', 0);

uicontrol('Style', 'text', 'Position', [230 10 60 20], 'String', 'Drumm');
drummbox = uicontrol('Style', 'checkbox' , 'Position', [300 10 20 20], 'value', 0);

%% Special

%uicontrol('Style', 'text', 'Position', [230 70 60 20], 'String', 'SpecOnly');
%speconlybox = uicontrol('Style', 'checkbox' , 'Position', [300 70 20 20], 'value', 0);

prewtext = uicontrol('Style', 'text', 'Position', [180 70 80 20], 'String', 'PassiveRew');
rewbox = uicontrol('Style', 'edit' , 'Position', [270 70 20 20], 'String', '0');

prewtext = uicontrol('Style', 'text', 'Position', [180 100 80 20], 'String', 'ContrastFactor');
bgfacbox = uicontrol('Style', 'edit' , 'Position', [270 100 20 20], 'String', num2str(bgfactor));

uicontrol('Style', 'text', 'Position', [210 200 50 20], 'String', 'PassDel');
pdbox = uicontrol('Style', 'edit' , 'Position', [270 200 30 20], 'String', '500');
drawnow