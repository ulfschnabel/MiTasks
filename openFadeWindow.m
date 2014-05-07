%% Basics

bgcon = input('Enter starting contrast \n');

f = figure('name', nts, 'position', [0 0 330 230]);
uicontrol('Style', 'text', 'Position', [10 10 60 20], 'String', 'RDur Norm');

rdurleft = uicontrol('Style', 'edit' , 'Position', [75 10 30 20], 'String', '93');%93
rdurright = uicontrol('Style', 'edit' , 'Position', [110 10 30 20], 'String', '100');%100 %19112013: gives 0.6ml per 100 hits

uicontrol('Style', 'text', 'Position', [10 120 30 20], 'String', 'Hit');
uicontrol('Style', 'text', 'Position', [10 80 30 20], 'String', 'Err');
uicontrol('Style', 'text', 'Position', [60 150 30 20], 'String', 'Total');
uicontrol('Style', 'text', 'Position', [100 150 70 20], 'String', 'ThisContrast');

HitText(1) = uicontrol('Style', 'text', 'Position', [75 120 20 20], 'String', '0');
HitText(2) = uicontrol('Style', 'text', 'Position', [55 120 20 20], 'String', '0');

SpecHitText(1) = uicontrol('Style', 'text', 'Position', [135 120 20 20], 'String', '0');
SpecHitText(2) = uicontrol('Style', 'text', 'Position', [115 120 20 20], 'String', '0');

ErrText(1) = uicontrol('Style', 'text', 'Position', [75 80 20 20], 'String', '0');
ErrText(2) = uicontrol('Style', 'text', 'Position', [55 80 20 20], 'String', '0');

SpecErrText(1) = uicontrol('Style', 'text', 'Position', [135 80 20 20], 'String', '0');
SpecErrText(2) = uicontrol('Style', 'text', 'Position', [115 80 20 20], 'String', '0');

uicontrol('Style', 'text', 'Position', [230 40 60 20], 'String', 'Ezmode');
ezbox = uicontrol('Style', 'checkbox' , 'Position', [300 40 20 20], 'value', 1);

uicontrol('Style', 'text', 'Position', [230 10 60 20], 'String', 'Drumm');
drummbox = uicontrol('Style', 'checkbox' , 'Position', [300 10 20 20], 'value', 1);

%% Special

prewtext = uicontrol('Style', 'text', 'Position', [230 130 80 20], 'String', 'PassRew');
rewbox = uicontrol('Style', 'edit' , 'Position', [300 130 20 20], 'String', '0');

uicontrol('Style', 'text', 'Position', [230 70 50 20], 'String', 'BgContr');
contbox = uicontrol('Style', 'edit' , 'Position', [300 70 20 20], 'String', bgcon);

uicontrol('Style', 'text', 'Position', [230 100 50 20], 'String', 'BgGrating');
bgbox = uicontrol('Style', 'checkbox' , 'Position', [300 100 20 20], 'value', 1);

uicontrol('Style', 'text', 'Position', [20 200 40 20], 'String', 'MotFig');
fmbox = uicontrol('Style', 'checkbox' , 'Position', [70 200 20 20], 'value', 1);
uicontrol('Style', 'text', 'Position', [100 200 40 20], 'String', 'MotBG');
bmbox = uicontrol('Style', 'checkbox', 'Position', [150 200 20 20], 'value', 0);
uicontrol('Style', 'text', 'Position', [210 200 50 20], 'String', 'MotDelay');
mdbox = uicontrol('Style', 'edit' , 'Position', [270 200 20 20], 'String', '0');

uicontrol('Style', 'text', 'Position', [210 170 50 20], 'String', 'PassDelay');
pdbox = uicontrol('Style', 'edit' , 'Position', [270 170 20 20], 'String', '2000');
drawnow