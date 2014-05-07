
logon = 0;
nts = input('Enter log name\n' ,'s');

modes = {'BlackWhite', 'OriDisc'};
mode = menu('Choose the mode',modes);

if ~isempty(nts)
    if exist(['log/' modes{mode} '/' nts '.mat'], 'file')
        error('Log-file already used, please pick a different name.');
    end
    logon = 1;
    nameend = strfind(nts, '_');
    name = nts;
    mouse = name(1:nameend(1)-1);
else
    mouse = 'Unknown';
end

%% Start Serial connection

sport = serial('com3');
if strcmp(get(sport, 'status'), 'closed'); fopen(sport); end;
set(sport, 'baudrate', 115200);


%% General Settings

Par.ITI = 5;
Par.ItiRandMin = 0;
Par.ItiRandMax = 2;
Par.StimDur = 1.5;
Par.Screenx = 1280;
Par.Screeny = 720;
Par.Refresh = 60;
Par.DistanceToScreen = 11;
Par.Centerx = Par.Screenx/4;
Par.Orientations = [0 90];
Par.ScreenWidthD2 = 51./2;
if mode == 9 %bigger stimuli for Orientation Discrimination
    Par.FigSize = 80;
else
    Par.FigSize = 50;
end
Par.SpatFreq = 0.08;%0.05;

%% Initialize variables for later use
if mode == 1
    LOG = {'Mouse', 'Mode', 'Date', 'RT', 'response', 'side', 'color', 'bgfactor', 'itiduration', 'gavepassive', 'ezmode', 'drumm', 'rewdurleft', 'rewdurright'};
end
passfirst = 0;
MissCount = 0;
ESC = 0;
Err = [0, 0];
SpecErr = [0, 0];
Hit = [0, 0];
SpecHit = [0, 0];
Miss = 0;
trialcount = 0;
gavepassive = 0;
wentthrough = 0;

%% initialize  Cogent
warning('off','MATLAB:dispatcher:InexactMatch')
cgloadlib

cgopen(Par.Screenx, Par.Screeny, 32,Par.Refresh ,1)

cgpenwid(1)
cgpencol(0,0,0)
cgfont('Arial',100)

cogstd('sPriority','high')

%% get screen details
gsd = cggetdata('gsd');
Par.HW = gsd.ScreenWidth./2; %get half width of the screen
Par.HH = gsd.ScreenHeight./2;
Par.PixPerDeg = Par.HW/atand(Par.ScreenWidthD2/Par.DistanceToScreen);
Ang2Pix = Par.PixPerDeg;
display(['Pixel per Degree: ' num2str(Ang2Pix)]);

%% Create stimuli and trial matrix depending on mode

switch mode
    case 1
        maxlum = gammacon(0.4,'rgb2lum');%was 0.7 untill 20130725
        minlum = gammacon(0,'rgb2lum');
        greylum = (maxlum+minlum)./25;
        maxlum = gammacon(0.8,'rgb2lum');
        PAR.greylum = greylum;
        grey = gammacon(greylum,'lum2rgb');
        PAR.grey = grey;
        openBlackWhiteWindow
        %color and side
        details = zeros(4, 2);
        details(1, :) = [0, 0];
        details(2, :) = [1, 0];
        details(3, :) = [0, 1];
        details(4, :) = [1, 1];
        details = [details; details; details];
        [ntrials, nvars] = size(details);
        order = randperm(ntrials);
        trials = details(order,:);
    case 2
        openOriDiscWindow
        createOriDiscStimuli
        z = 0;
        for o = Par.Orientations
            for s = 0:1
                z = z+1;
                details(z,:) = [o, s];
            end
        end
        details = [details; details];
        [ntrials, nvars] = size(details);
        order = randperm(ntrials);
        trials = details(order,:);
end

%% Actual script

cgflip(grey,grey,grey)

ititime = tic;

while ~ESC
    
    
    %% Set Arduino and trial details depending on mode
    trialcount = trialcount + 1;
    sendard(sport, ['IF ' '4000'])
    switch mode
        case 1
            sendard(sport, ['IF ' get(thbox, 'string')])
            color = trials(1,1);
            switch color
                case 0
                    special = 0;
                    colorstring = 'black';
                    figcol = 0;
                    bgcol = gammacon(maxlum - (maxlum - greylum) * (1- str2num(get(bgfacbox, 'string'))), 'lum2rgb');
                case 1
                    special = 1;
                    colorstring = 'white';
                    figcol = gammacon(maxlum, 'lum2rgb');
                    bgcol = gammacon(minlum + (greylum - minlum) * (1- str2num(get( bgfacbox, 'string'))), 'lum2rgb');
                    if~isreal(bgcol); bgcol = 0; end;
            end
            side = trials(1,2);
            sendard(sport, ['IL ' get(rdurright, 'String')])
            sendard(sport, ['IR ' get(rdurleft, 'String')])
            sendard(sport, ['IM ' num2str(get(ezbox, 'Value'))])
        case 2
            orientation = trials(1,1);
            side = trials(1, 2);
            special = 0;
            sendard(sport, ['IL ' get(rdurright, 'String')])
            sendard(sport, ['IR ' get(rdurleft, 'String')])
            sendard(sport, ['IM ' num2str(get(ezbox, 'Value'))])
            createOriDiscStimuli
            if orientation == Par.Orientations(1)
                Fsprite=1;
                %special = 0;
            else
                Fsprite = 2;
                % special = 1;
            end
    end
    gavepassive = 0;
    passivereward = 0;
    
    
    
    %Finish ITI
    pause(Par.ITI + random('uniform', Par.ItiRandMin, Par.ItiRandMax) - toc(ititime))
    itiduration = toc(ititime);
    
    if side == 0
        sidestring = 'right';
        x = Par.Centerx;
        y = 0;
        if ~get(prbox, 'Value')
            passivereward = 0;
        elseif str2num(get(rewbox, 'string'))
            set(rewbox, 'string', num2str(str2num(get(rewbox, 'string')) - 1));
            passivereward = 1;
        end
    else
        sidestring = 'left';
        x = Par.Centerx - Par.Screenx/2;
        y = 0;
        if ~get(plbox, 'Value')
            passivereward = 0;
        elseif str2num(get(rewbox, 'string'))
            set(rewbox, 'string', num2str(str2num(get(rewbox, 'string')) - 1));
            passivereward = 1;
        end
    end
    
    
    
    %% Present stimuli
    didflip = 0;
    Reaction = [];
    switch mode
        case 1
            I = '';
            if side == 0
                sendard(sport, 'IE 1')
            else
                sendard(sport, 'IE 2')
            end
            cgrect(0, 0, 1290, 720, [bgcol bgcol bgcol])
            cgellipse(x, y, Par.FigSize * Ang2Pix, Par.FigSize * Ang2Pix, [figcol figcol figcol],'f')
            cgflip(grey, grey, grey)
            fprintf(sport, 'IS');
            onset = tic;
            while toc(onset) < 1.5
                if passivereward && ~gavepassive && toc(onset) > str2num(get(pdbox, 'string'))/1000
                    fprintf(sport, 'IP');
                    gavepassive = 1;
                end
                if sport.BytesAvailable
                    while ~strcmp(I, 'O') && sport.BytesAvailable
                        I = fscanf(sport, '%s');
                        break
                    end
                    if strcmp(I, 'O')
                        if sport.BytesAvailable
                            Reaction = fscanf(sport, '%s');
                        end
                        if sport.BytesAvailable
                            RT = fscanf(sport, '%s');
                        end
                        if sport.BytesAvailable
                            passfirst = str2num(fscanf(sport, '%s'));
                        end
                        if sport.BytesAvailable
                            wentthrough = str2num(fscanf(sport, '%s'));
                            set(wt, 'string', num2str(wentthrough));
                        end
                        if strcmp(Reaction, '0')
                            cgflip(grey,grey,grey)
                            didflip = 1;
                        end
                        pause(0.01)
                    end
                end
            end
            if(~didflip)
                cgflip(grey, grey, grey)
            end
        case 2
            if orientation == Par.Orientations(1)
                sendard(sport, 'IE 1')
            else
                sendard(sport, 'IE 2')
            end
            
            cgdrawsprite(Fsprite, x * str2num(get(posfacbox, 'string')), 0)
            cgflip(grey,grey,grey)
            fprintf(sport, 'IS');
            onset = tic;
            
            I = '';
            if passivereward
                pause(str2num(get(pdbox, 'string'))/1000)
                fprintf(sport, 'IP');
                gavepassive = 1;
            end
            
            didflip = 0;
            while toc(onset) < 1.5
                if sport.BytesAvailable
                    while ~strcmp(I, 'O') && sport.BytesAvailable
                        I = fscanf(sport, '%s');
                        break
                    end
                    if strcmp(I, 'O')
                        if sport.BytesAvailable
                            Reaction = fscanf(sport, '%s');
                        end
                        if sport.BytesAvailable
                            RT = fscanf(sport, '%s');
                        end
                        if sport.BytesAvailable
                            passfirst = str2num(fscanf(sport, '%s'));
                        end
                        if sport.BytesAvailable
                            wentthrough = str2num(fscanf(sport, '%s'));
                            set(wt, 'string', num2str(wentthrough));
                        end
                        if strcmp(Reaction, '0')
                            cgflip(grey,grey,grey)
                            didflip = 1;
                        end
                        pause(0.01)
                    end
                end
            end
    end
    cgflip(grey, grey, grey)
    fprintf(sport, 'ID');
    pause(0.2)
    if sport.BytesAvailable
        while ~strcmp(I, 'O') && sport.BytesAvailable
            I = fscanf(sport, '%s');
            break
        end
        if strcmp(I, 'O')
            pause(0.01)
            if sport.BytesAvailable
                Reaction = fscanf(sport, '%s');
            end
            if sport.BytesAvailable
                RT = fscanf(sport, '%s');
            end
            if sport.BytesAvailable
                passfirst = str2num(fscanf(sport, '%s'));
            end
            if sport.BytesAvailable
                wentthrough = str2num(fscanf(sport, '%s'));
                set(wt, 'string', num2str(wentthrough));
            end
        end
    end
    if ~didflip
        if mode == 5 && get(bgbox, 'value')
            cgdrawsprite(surspr,0,0)
        end
        cgflip(grey,grey,grey)
    end
    
    %% Process response
    if mode == 1
        if strcmp(Reaction, '1')
            Reaction = 'Hit';
            if ~special
                Hit(side + 1) = Hit(side + 1) + 1;
                set(HitText(side + 1), 'string', Hit(side + 1));
            end
            if special
                SpecHit(side + 1) = SpecHit(side + 1) + 1;
                set(SpecHitText(side + 1), 'string', SpecHit(side + 1));
            end
        elseif strcmp(Reaction, '2')
            Reaction = 'Hit';
            if ~special
                Hit(side + 1) = Hit(side + 1) + 1;
                set(HitText(side + 1), 'string', Hit(side + 1));
            end
            if special
                SpecHit(side + 1) = SpecHit(side + 1) + 1;
                set(SpecHitText(side + 1), 'string', SpecHit(side + 1));
            end
        elseif strcmp(Reaction, '0')
            Reaction = 'Error';
            if ~special
                Err(side + 1) = Err(side + 1) + 1;
                set(ErrText(side + 1), 'string', Err(side + 1));
            end
            if special
                SpecErr(side + 1) = SpecErr(side + 1) + 1;
                set(SpecErrText(side + 1), 'string', SpecErr(side + 1));
            end
            pause(5)
        elseif strcmp(Reaction, '4')
            Reaction = 'TooFast';
        else
            Reaction = 'Miss';
            Miss = Miss+ 1;
            RT = NaN;
            %set(MissText, 'string', Miss);
        end
    else
         ori = str2num(Reaction);
         if strcmp(Reaction, '1') && ~side
             Reaction = 'Hit';
             Hit(ori) = Hit(ori) + 1;
             set(HitText(ori), 'string', Hit(ori));
         elseif strcmp(Reaction, '1') && side
             Reaction = 'Hit';
             SpecHit(ori) = SpecHit(ori) + 1;
             set(SpecHitText(ori), 'string', SpecHit(ori));
         elseif strcmp(Reaction, '2') && ~side
            Reaction = 'Hit';
            Hit(ori) = Hit(ori) + 1;
            set(HitText(ori), 'string', Hit(ori));
         elseif strcmp(Reaction, '1') && side
             Reaction = 'Hit';
             SpecHit(ori) = SpecHit(ori) + 1;
             set(SpecHitText(ori), 'string', SpecHit(ori));
        elseif strcmp(Reaction, '0') && ~side
            Reaction = 'Error';
            Err(ori) = Err(ori) + 1;
            set(ErrText(ori), 'string', Err(ori));
            pause(5)
        elseif strcmp(Reaction, '1') && side
            Reaction = 'Error';
            SpecErr(ori) = SpecErr(ori) + 1;
            set(SpecErrText(ori), 'string', SpecErr(ori));
            pause(5)
        elseif strcmp(Reaction, '4')
            Reaction = 'TooFast';
        else
            Reaction = 'Miss';
            Miss = Miss+ 1;
            RT = NaN;
            %set(MissText, 'string', Miss);
        end
    end
    
    ititime = tic;
    
    
    %% Finish Trial
    
    [kd,kp] = cgkeymap;
    if length(find(kp)) == 1
        if find(kp) == 1;
            ESC = 1;
        end
    end
    if get(drummbox, 'value')
        if strcmp(Reaction, 'Hit')
            trials(1,:) = [];
            if isempty(trials)
                order = randperm(ntrials);
                trials = details(order,:);
            end
        end
    else
        trials(1,:) = [];
        if isempty(trials)
            order = randperm(ntrials);
            trials = details(order,:);
        end
    end
    
    
    %Display trial info and save log
    %LOG = {'Mouse', 'Mode', 'Date', 'RT', 'response', 'special', 'side', 'orientation', 'itiduration', 'gavepassive', 'bgcontrast', 'movementdelay', 'direction', 'figmotion', 'bgmotion', 'textureversion', 'ezmode', 'rewdurleftnorm', 'rewdurrightnorm', 'rewdurleftspec', 'rewdurrightspec'};
    switch mode
        case 1
            LOG =  [LOG; {mouse, 'BlackWhite', date, RT, Reaction, sidestring, color, str2num(get(bgfacbox, 'string')), itiduration, gavepassive, get(ezbox, 'Value'), get(drummbox, 'Value'), str2num(get(rdurleft, 'String')), str2num(get(rdurright, 'String'))}];
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' RT: ' num2str(RT) ', Reaction: ' Reaction , ' ,Color: ', colorstring, ' ,Background: ', get(bgfacbox, 'string'), ' ,Passive: ', num2str(gavepassive), ' ,Passfirst: ', num2str(passfirst), 'pdelay: ', get(pdbox, 'string')]);
            %LOG = {'Mouse', 'Mode', 'Date', 'RT', 'response', 'side', 'color', 'bgfactor', 'itiduration', 'gavepassive', 'ezmode', 'drumm', 'rewdurleft', 'rewdurright'};
        case 2
            LOG.Mouse = mouse;
            LOG.Date = date;
            LOG.Trial(trialcount) = trialcount;
            LOG.Orientation(trialcount) = orientation;
            LOG.Side(trialcount) = {sidestring};
            if ischar(RT)
                LOG.RT(trialcount) = str2num(RT);
            else
                LOG.RT(trialcount) = RT;
            end
            LOG.Reaction(trialcount) = {Reaction};
            LOG.Gavepassive(trialcount) = gavepassive;
            LOG.Passivefirst(trialcount) = passfirst;
            LOG.Ezbox(trialcount) = get(ezbox, 'Value');
            LOG.Passivedelay(trialcount) = str2num(get(pdbox, 'string'));
            LOG.Figuresize = str2num(get(fsizebox, 'string'));
            
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' Orientation: ' , num2str(orientation), ' RT: ' num2str(RT) ', Reaction: ' Reaction , ' ,Passive: ', num2str(gavepassive), ' ,Passfirst: ', num2str(passfirst), 'pdelay: ', get(pdbox, 'string')]);
    end
    if logon
        save(['log/' modes{mode} '/' nts],'LOG');
    end
end

if strcmp(get(sport, 'status'), 'open'); fclose(sport); end;
clear all
cogstd('sPriority','normal')
cgshut

