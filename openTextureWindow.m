f = figure('name', nts, 'position', [0 0 330 230]);
label = uicontrol('Style', 'text', 'Position', [20 20 60 20], 'String', 'RDur Left');
rdurleft = uicontrol('Style', 'edit' , 'Position', [70 20 40 20], 'String', '150');
label = uicontrol('Style', 'text', 'Position', [120 20 60 20], 'String', 'RDur Right');
rdurright = uicontrol('Style', 'edit' , 'Position', [190 20 40 20], 'String', '155');

label = uicontrol('Style', 'text', 'Position', [250 40 40 20], 'String', 'ezmode');
ezbox = uicontrol('Style', 'checkbox' , 'Position', [300 40 20 20], 'value', 0);

%slider = uicontrol('style', 'slider', 'Max', 800, 'Min', 50, 'Sliderstep', [0.05 0.05], 'Value', 50, 'callback', 'set(text, ''string'',  num2str(get(slider, ''value'')))', 'Position', [110 20 80 20]);
label = uicontrol('Style', 'text', 'Position', [20 60 80 20], 'String', 'Contrast 20-80');
text5 = uicontrol('Style', 'text', 'Position', [200 60 40 20], 'String', '20');
bgslider = uicontrol('style', 'slider', 'Max', 80, 'Min', 20, 'Sliderstep', [0.02 0.02], 'Value', 20, 'callback', 'set(text5, ''string'',  num2str(get(bgslider, ''value'')))', 'Position', [110 60 80 20]);
label = uicontrol('Style', 'text', 'Position', [20 90 40 20], 'String', 'Hit L');
text6 = uicontrol('Style', 'text', 'Position', [65 90 20 20], 'String', '0');
label = uicontrol('Style', 'text', 'Position', [90 90 40 20], 'String', 'Hit R');
text7 = uicontrol('Style', 'text', 'Position', [135 90 20 20], 'String', '0');
text4 = uicontrol('Style', 'text', 'Position', [150 90 80 20], 'String', 'PassiveRew');
rewbox = uicontrol('Style', 'edit' , 'Position', [240 90 20 20], 'String', '0');

lbox = uicontrol('Style', 'checkbox' , 'Position', [270 90 20 20], 'value', 1);
rbox = uicontrol('Style', 'checkbox' , 'Position', [300 90 20 20], 'value', 1);

text9 = uicontrol('Style', 'text', 'Position', [150 120 80 20], 'String', 'BgGrating');
bgbox = uicontrol('Style', 'checkbox' , 'Position', [250 120 20 20]);
label = uicontrol('Style', 'text', 'Position', [20 120 40 20], 'String', 'Miss');
misstext = uicontrol('Style', 'text', 'Position', [55 120 20 20], 'String', '0');
label = uicontrol('Style', 'text', 'Position', [85 120 30 20], 'String', 'Err');
fatext = uicontrol('Style', 'text', 'Position', [120 120 20 20], 'String', '0');
label = uicontrol('Style', 'text', 'Position', [20 150 60 20], 'String', 'Grating');
gratbox = uicontrol('Style', 'checkbox' , 'Position', [90 150 20 20], 'value', 1);
label = uicontrol('Style', 'text', 'Position', [120 150 40 20], 'String', 'Figure');
figbox = uicontrol('Style', 'checkbox' , 'Position', [170 150 20 20], 'value', 1);
label = uicontrol('Style', 'text', 'Position', [195 150 45 20], 'String', 'Adaptive');
adaptiverewbox = uicontrol('Style', 'checkbox' , 'Position', [250 150 20 20], 'value', 0);
label = uicontrol('Style', 'text', 'Position', [20 180 60 20], 'String', 'Mavg');
mbox = uicontrol('Style', 'edit' , 'Position', [90 180 20 20], 'String', '20');
label = uicontrol('Style', 'text', 'Position', [120 180 40 20], 'String', 'thres');
thresbox = uicontrol('Style', 'edit' , 'Position', [170 180 40 20], 'String', '10000');
label = uicontrol('Style', 'text', 'Position', [220 180 40 20], 'String', 'ErrTOut');
tobox = uicontrol('Style', 'edit' , 'Position', [270 180 20 20], 'String', '0');
label = uicontrol('Style', 'text', 'Position', [20 210 40 20], 'String', 'LOnly');
lobox = uicontrol('Style', 'checkbox' , 'Position', [70 210 20 20], 'value', 0);
label = uicontrol('Style', 'text', 'Position', [100 210 40 20], 'String', 'ROnly');
robox = uicontrol('Style', 'checkbox', 'Position', [150 210 20 20], 'value', 0);
label = uicontrol('Style', 'text', 'Position', [220 210 40 20], 'String', 'PassDel');
pdbox = uicontrol('Style', 'edit' , 'Position', [270 210 20 20], 'String', '500');
drawnow