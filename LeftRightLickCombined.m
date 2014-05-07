
logon = 0;
nts = input('Enter log name\n' ,'s');

modes = {'Standard', 'Hole', 'Motion', 'Texture', 'Mask', 'Fade', 'DualContrast', 'BlackWhite', 'OriDisc'};
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
if mode < 7
    LOG = {'Mouse', 'Mode', 'Date', 'RT', 'response', 'special', 'side', 'orientation', 'itiduration', 'gavepassive', 'bgcontrast', 'movementdelay', 'direction', 'figmotion', 'bgmotion', 'textureversion', 'ezmode', 'rewdurleftnorm', 'rewdurrightnorm', 'rewdurleftspec', 'rewdurrightspec'};
elseif mode == 7
    LOG = {'Mouse', 'Mode', 'Date', 'RT', 'response', 'side', 'orientation', 'itiduration', 'centcontrast', 'bgcontrast', 'gavepassive', 'ezmode', 'drumm', 'rewdurleftnorm', 'rewdurrightnorm'};
elseif mode == 8
    LOG = {'Mouse', 'Mode', 'Date', 'RT', 'response', 'side', 'color', 'bgfactor', 'itiduration', 'gavepassive', 'ezmode', 'drumm', 'rewdurleft', 'rewdurright'};
end
passfirst = 0;
lrewardedtrials = 0;
rrewardedtrials = 0;
forcedside = 0;
MissCount = 0;
lick = 0;
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
        openStandardWindow
        createHoleStimuli
        z = 0;
        for o = Par.Orientations
            for r = [0, 1]
                z = z+1;
                details(z,:) = [o, r];
            end
        end
        details = [details; details];
        [ntrials, nvars] = size(details);
        order = randperm(ntrials);
        trials = details(order,:);
    case 2
        openHoleWindow
        createHoleStimuli
        z = 0;
        for o = Par.Orientations
            for h = [0, 1]
                for r = [0, 1]
                    z = z+1;
                    details(z,:) = [o, r, h];
                end
            end
        end
        details = [details; details];
        [ntrials, nvars] = size(details);
        order = randperm(ntrials);
        trials = details(order,:);
    case 3
        openMotionWindow
        createMotionStimuli
        z = 0;
        for o = Par.Orientations
            for r = [0, 1]
                for d = 1:2
                    z = z+1;
                    details(z,:) = [o, r, d];
                end
            end
        end
        ntrials = z;
        order = randperm(ntrials);
        trials = details(order,:);
        currbgcontrast = str2num(get(contbox, 'string'));
    case 4
        openStandardWindow
        createTextureStimuli
        z = 0;
        for o = Par.Orientations
            for r = [0, 1]
                for v = 1:Par.Versions
                    z = z+1;
                    details(z,:) = [o, r, v];
                end
            end
        end
        details = [details; details];
        [ntrials, nvars] = size(details);
        order = randperm(ntrials);
        trials = details(order,:);
    case 5
        openMaskWindow
        createMaskStimuli
        z = 0;
        for o = Par.Orientations
            for r = [0, 1]
                z = z+1;
                details(z,:) = [o, r];
            end
        end
        details = [details; details];
        [ntrials, nvars] = size(details);
        order = randperm(ntrials);
        trials = details(order,:);
        currbgcontrast = get(bgslider, 'value');
    case 6
        openFadeWindow
        createFadeStimuli
        z = 0;
        for o = Par.Orientations
            for r = [0, 1]
                for d = 1:2
                    z = z+1;
                    details(z,:) = [o, r, d];
                end
            end
        end
        ntrials = z;
        order = randperm(ntrials);
        trials = details(order,:);
        currbgcontrast = str2num(get(contbox, 'string'));
    case 7
        openDualContrastWindow
        createDualContrastStimuli
        z = 0;
        for o = Par.Orientations
            for r = [0, 1]
                z = z+1;
                detailsone(z,:) = [o, 1, r];
            end
        end
        z = 0;
        for o = Par.Orientations
            for r = [0, 1]
                z = z+1;
                detailszero(z,:) = [o, 0, r];
            end
        end
        [ntrials, nvars] = size(detailsone);
        order = randperm(ntrials);
        detailsone = detailsone(order,:);
        detailszero = detailszero(order,:);
        
        trials = [];
        while ~isempty(detailsone) || ~isempty(detailszero)
            rep = randsample([1 2 3], 2);
            [a b] = size(detailsone);
            if rep(1) > a; rep(1) = a; end
            trials = [trials; detailsone(1:rep(1), :)];
            detailsone(1:rep(1), :) = [];
            [a b] = size(detailszero);
            if rep(2) > a; rep(2) = a; end
            trials = [trials; detailszero(1:rep(2), :)];
            detailszero(1:rep(2), :) = [];
        end
    case 8
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
    case 9
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
            orientation = trials(1,1);
            side = trials(1,2);
            special = 0;
            sendard(sport, ['IL ' get(rdurright, 'String')])
            sendard(sport, ['IR ' get(rdurleft, 'String')])
            sendard(sport, ['IM ' num2str(get(ezbox, 'Value'))])
            if orientation == 45
                Fsprite=1;
                surspr = 4;
            else
                Fsprite = 2;
                surspr = 3;
            end
        case 2
            orientation = trials(1,1);
            side = trials(1,2);
            special = trials(1,3);
            if get(speconlybox, 'value')
                special = 1;
            end
            if special
                sendard(sport, ['IL ' get(specialrdurright, 'String')])
                sendard(sport, ['IR ' get(specialrdurleft, 'String')])
            else
                sendard(sport, ['IL ' get(rdurright, 'String')])
                sendard(sport, ['IR ' get(rdurleft, 'String')])
            end
            sendard(sport, ['IM ' num2str(get(ezbox, 'Value'))])
            if orientation == 45
                Fsprite=1;
                surspr = 4;
            else
                Fsprite = 2;
                surspr = 3;
            end
        case 3
            if get(bgbox, 'value') && currbgcontrast ~= str2num(get(contbox, 'string'))
                createMotionStimuli
                currbgcontrast = str2num(get(contbox, 'string'));
                SpecHit = [0, 0];
                SpecErr = [0, 0];
                set(SpecErrText(1), 'string', SpecErr(1));
                set(SpecErrText(2), 'string', SpecErr(2));
                set(SpecHitText(1), 'string', SpecHit(1));
                set(SpecHitText(2), 'string', SpecHit(2));
            elseif ~get(bgbox, 'value')
                currbgcontrast = 0;
            end
            orientation = trials(1,1); %Orient
            side = trials(1,2); %in RF?
            direction = trials(1,3);
            special = 0;
            sendard(sport, ['IL ' get(rdurright, 'String')])
            sendard(sport, ['IR ' get(rdurleft, 'String')])
            sendard(sport, ['IM ' num2str(get(ezbox, 'Value'))])
            if orientation == 45
                Fsprites = 1:max(length(phasesteps));
                Bgsprites = sprite2end+1:sprite2end+max(length(phasesteps));
            else
                Fsprites = sprite1end+1:sprite1end+max(length(phasesteps));
                Bgsprites = bg1end+1:bg1end+max(length(phasesteps));
            end
        case 4
            orientation = trials(1,1);
            side = trials(1,2);
            special = 0;
            version = trials(1,3);
            sendard(sport, ['IL ' get(rdurright, 'String')])
            sendard(sport, ['IR ' get(rdurleft, 'String')])
            sendard(sport, ['IM ' num2str(get(ezbox, 'Value'))])
            if orientation == 45
                forespr = 1 + (version-1) * 2;
                backspr = 2 + (version-1) * 2;
            else
                forespr = 1 + (version-1) * 2;
                backspr = 2 + (version-1) * 2;
            end
        case 5
            if get(bgbox, 'value') && currbgcontrast ~= get(bgslider, 'value')
                createMaskStimuli
                currbgcontrast = get(bgslider, 'value');
            elseif ~get(bgbox, 'value')
                currbgcontrast = 0;
            end
            
            for i = 10:11
                makenoisepattern(i, Par.FigSize+10, Par.SpatFreq, Par.PixPerDeg)
            end
            orientation = trials(1,1);
            side = trials(1,2);
            special = 0;
            sendard(sport, ['IL ' get(rdurright, 'String')])
            sendard(sport, ['IR ' get(rdurleft, 'String')])
            sendard(sport, ['IM ' num2str(get(ezbox, 'Value'))])
            if orientation == 45
                Fsprite=1;
                surspr = 4;
            else
                Fsprite = 2;
                surspr = 3;
            end
            if get(bgbox, 'value')
                cgdrawsprite(surspr,0,0)
            end
            cgflip(grey, grey, grey)
            
        case 6
            if get(bgbox, 'value') && currbgcontrast ~= str2num(get(contbox, 'string'))
                createFadeStimuli
                currbgcontrast = str2num(get(contbox, 'string'));
                SpecHit = [0, 0];
                SpecErr = [0, 0];
                set(SpecErrText(1), 'string', SpecErr(1));
                set(SpecErrText(2), 'string', SpecErr(2));
                set(SpecHitText(1), 'string', SpecHit(1));
                set(SpecHitText(2), 'string', SpecHit(2));
            elseif ~get(bgbox, 'value')
                currbgcontrast = 0;
            end
            orientation = trials(1,1); %Orient
            side = trials(1,2); %in RF?
            special = 0;
            sendard(sport, ['IL ' get(rdurright, 'String')])
            sendard(sport, ['IR ' get(rdurleft, 'String')])
            sendard(sport, ['IM ' num2str(get(ezbox, 'Value'))])
        case 7
            orientation = trials(1,1);
            side = trials(1,2);
            special = trials(1,3);
            sendard(sport, ['IL ' get(rdurright, 'String')])
            sendard(sport, ['IR ' get(rdurleft, 'String')])
            sendard(sport, ['IM ' num2str(get(ezbox, 'Value'))])
            
            if special
                CENT.Contrast = 80;
                SURR.Contrast = 40 * str2num(get(bgfacbox, 'string'));
            else
                CENT.Contrast = 40;
                SURR.Contrast = 20 * str2num(get(bgfacbox, 'string'));
            end
            
            CENT.Phase = rand(1)*(2*pi);
            SURR.Phase = CENT.Phase;
            
            CENT.Orient = orientation;
            SURR.Orient = orientation + 90;
            
            [acref,CENT] = makegaborpat(1,CENT);
            [acref,SURR] = makegaborpat(2,SURR);
        case 8
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
        case 9
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
            if side == 0
                sendard(sport, 'IE 1')
            else
                sendard(sport, 'IE 2')
            end
            
            cgdrawsprite(Fsprite, x, y)
            cgflip(grey,grey,grey)
            fprintf(sport, 'IS');
            onset = tic;
            
            I = '';
            if passivereward
                pause(str2num(get(pdbox, 'string'))/1000)
                fprintf(sport, 'IP');
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
        case 2
            if side == 0
                sendard(sport, 'IE 1')
            else
                sendard(sport, 'IE 2')
            end
            if special
                cgdrawsprite(surspr,0,0)
                cgellipse(x, y, Par.FigSize * Ang2Pix, Par.FigSize * Ang2Pix, [grey grey grey],'f')
            else
                cgdrawsprite(Fsprite,x,y)
            end
            cgflip(grey, grey, grey)
            fprintf(sport, 'IS');
            onset = tic;
            
            I = '';
            if passivereward
                pause(str2num(get(pdbox, 'string'))/1000)
                fprintf(sport, 'IP');
            end
            
            didflip = 0;
            while toc(onset) < Par.StimDur
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
        case 3 %changed to 1s figure presentation before trial starts on 2-12-13
            if get(bgbox, 'value')
                cgdrawsprite(Bgsprites(1),0,0)
            end
            cgdrawsprite(Fsprites(1),x,y)
            cgflip(grey,grey,grey)
            fprintf(sport, 'IS');
            onset = tic;
            I = '';
            %             while toc(onset) < str2num(get(mdbox, 'string'))/1000
            %                 if passivereward && ~gavepassive && toc(onset) > str2num(get(pdbox, 'string'))/1000
            %                     fprintf(sport, 'IP');
            %                     gavepassive = 1;
            %                 end
            %                 if sport.BytesAvailable
            %                     while ~strcmp(I, 'O') && sport.BytesAvailable
            %                         I = fscanf(sport, '%s');
            %                         break
            %                     end
            %                     if strcmp(I, 'O')
            %                         cgflip(grey,grey,grey)
            %                         didflip = 1;
            %                         pause(0.01)
            %                         if sport.BytesAvailable
            %                             Reaction = fscanf(sport, '%s');
            %                         end
            %                         if sport.BytesAvailable
            %                             RT = fscanf(sport, '%s');
            %                         end
            %                         if sport.BytesAvailable
            %                             passfirst = str2num(fscanf(sport, '%s'));
            %                         end
            %                     end
            %                 end
            %             end
            
            count = 1;
            motionstart = tic;
            frames = 0:(1/60):1.5;
            
            while toc(onset) < 0.5
                if toc(motionstart) > frames(count + 1)
                    if get(bmbox, 'value') && get(bgbox, 'value')
                        cgdrawsprite(Bgsprites(count),0,0)
                    elseif get(bgbox, 'value')
                        cgdrawsprite(Bgsprites(1),0,0)
                    end
                    if get(fmbox, 'value')
                        cgdrawsprite(Fsprites(count),x,y)
                    else
                        cgdrawsprite(Fsprites(1),x,y)
                    end
                    
                    count = count + 1;
                    if count > max(length(phasesteps))
                        count = 1;
                    end
                    cgflip(grey, grey, grey)
                end
            end
            
            if side == 0
                sendard(sport, 'IE 1')
            else
                sendard(sport, 'IE 2')
            end
            
            
            while toc(onset) < 0.5+Par.StimDur
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
                        %buf = fread(sport, 240, 'uchar');
                    end
                else
                    if toc(motionstart) > frames(count + 1)
                        if get(bmbox, 'value') && get(bgbox, 'value')
                            cgdrawsprite(Bgsprites(count),0,0)
                        elseif get(bgbox, 'value')
                            cgdrawsprite(Bgsprites(1),0,0)
                        end
                        if get(fmbox, 'value')
                            cgdrawsprite(Fsprites(count),x,y)
                        else
                            cgdrawsprite(Fsprites(1),x,y)
                        end
                        
                        count = count + 1;
                        if count > max(length(phasesteps))
                            count = 1;
                        end
                        cgflip(grey, grey, grey)
                    end
                end
            end
        case 4
            if side == 0
                sendard(sport, 'IE 1')
            else
                sendard(sport, 'IE 2')
            end
            if get(bgbox, 'value')
                cgdrawsprite(backspr, 0, 0)
            end
            cgblitsprite(forespr, x, y, Par.FigSize, Par.FigSize, x, y)
            cgflip(grey, grey, grey)
            fprintf(sport, 'IS');
            onset = tic;
            I = '';
            if passivereward
                pause(str2num(get(pdbox, 'string'))/1000)
                fprintf(sport, 'IP');
            end
            while toc(onset) < Par.StimDur
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
        case 5
            if get(maskbox, 'value')
                if get(bgbox, 'value')
                    cgdrawsprite(surspr,0,0)
                end
                cgdrawsprite(10, Par.Centerx, 0)
                cgdrawsprite(11, Par.Centerx - Par.Screenx/2, 0)
                cgflip(grey,grey,grey)
                pause(100/1000)
            end
            if get(bgbox, 'value')
                cgdrawsprite(surspr, 0, 0)
            end
            cgdrawsprite(Fsprite, x, y)
            cgflip(grey,grey,grey)
            fprintf(sport, 'IS');
            onset = tic;
            
            I = '';
            if passivereward
                pause(str2num(get(pdbox, 'string'))/1000)
                fprintf(sport, 'IP');
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
                            if get(bgbox, 'value')
                                cgdrawsprite(surspr,0,0)
                            end
                            cgflip(grey,grey,grey)
                        end
                        didflip = 1;
                        pause(0.01)
                    end
                end
            end
        case 6
            onset = tic;
            I = '';
            sindex = min(find(lookup(:, 7) == orientation));
            index = sindex + 1;
            fprintf(sport, 'IS');
            if side == 0
                sendard(sport, 'IE 1')
            else
                sendard(sport, 'IE 2')
            end
            
            start = tic;
            while toc(onset) < 3.5
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
                        %buf = fread(sport, 240, 'uchar');
                    end
                else
                    index = sindex +  max(find(toc(start) > frames));
                    cgdrawsprite(lookup(index, 6),0,0)
                    cgdrawsprite(lookup(index, 5),x,y)
                    cgflip(grey, grey, grey)
                    index = index + 1;
                end
            end
        case 7
            if orientation == Par.Orientations(1)
                sendard(sport, 'IE 1')
            else
                sendard(sport, 'IE 2')
            end
            
            cgdrawsprite(2,0,0)
            
            cgdrawsprite(1, x, y)
            cgflip(grey,grey,grey)
            fprintf(sport, 'IS');
            onset = tic;
            
            I = '';
            if passivereward
                pause(str2num(get(pdbox, 'string'))/1000)
                fprintf(sport, 'IP');
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
        case 8
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
        case 9
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
    ititime = tic;
    
    
    %% Process response
    if strcmp(Reaction, '1')
        Reaction = 'Hit';
        if ~special
            Hit(1) = Hit(1) + 1;
            set(HitText(1), 'string', Hit(1));
        end
        if special || mode == 3 || mode == 6
            SpecHit(1) = SpecHit(1) + 1;
            set(SpecHitText(1), 'string', SpecHit(1));
        end
    elseif strcmp(Reaction, '2')
        Reaction = 'Hit';
        if ~special
            Hit(2) = Hit(2) + 1;
            set(HitText(2), 'string', Hit(2));
        end
        if special || mode == 3 || mode == 6
            SpecHit(2) = SpecHit(2) + 1;
            set(SpecHitText(2), 'string', SpecHit(2));
        end
    elseif strcmp(Reaction, '0') && mode ~= 9
        Reaction = 'Error';
        if ~special
            Err(side + 1) = Err(side + 1) + 1;
            set(ErrText(side + 1), 'string', Err(side + 1));
        end
        if special || mode == 3 || mode == 6
            SpecErr(side + 1) = SpecErr(side + 1) + 1;
            set(SpecErrText(side + 1), 'string', SpecErr(side + 1));
        end
        pause(5)
        ititime = tic;
    elseif strcmp(Reaction, '0') && mode == 9
        Reaction = 'Error';
        if ~special
            if orientation == Par.Orientations(1)
                Err(1) = Err(1) + 1;
                set(ErrText(1), 'string', Err(1));
            else
                Err(2) = Err(2) + 1;
                set(ErrText(2), 'string', Err(2));
            end
        end
        pause(5)
        ititime = tic;
    elseif strcmp(Reaction, '4')
        Reaction = 'TooFast';
    else
        Reaction = 'Miss';
        Miss = Miss+ 1;
        RT = NaN;
        %set(MissText, 'string', Miss);
    end
    
    
    
    
    %% Finish Trial
    
    [kd,kp] = cgkeymap;
    if length(find(kp)) == 1
        if find(kp) == 1;
            ESC = 1;
        end
    end
    if mode == 7
        %Update randomization table
        if get(drummbox, 'value')
            if strcmp(Reaction, 'Hit')
                trials(1,:) = [];
                if isempty(trials)
                    z = 0;
                    for o = Par.Orientations
                        for r = [0, 1]
                            z = z+1;
                            detailsone(z,:) = [o, 1, r];
                        end
                    end
                    z = 0;
                    for o = Par.Orientations
                        for r = [0, 1]
                            z = z+1;
                            detailszero(z,:) = [o, 0, r];
                        end
                    end
                    [ntrials, nvars] = size(detailsone);
                    order = randperm(ntrials);
                    detailsone = detailsone(order,:);
                    detailszero = detailszero(order,:);
                    
                    trials = [];
                    if side == 0
                        while ~isempty(detailsone) || ~isempty(detailszero)
                            rep = randsample([1 2 3], 2);
                            [a b] = size(detailsone);
                            if rep(1) > a; rep(1) = a; end
                            trials = [trials; detailsone(1:rep(1), :)];
                            detailsone(1:rep(1), :) = [];
                            [a b] = size(detailszero);
                            if rep(2) > a; rep(2) = a; end
                            trials = [trials; detailszero(1:rep(2), :)];
                            detailszero(1:rep(2), :) = [];
                        end
                    else
                        while ~isempty(detailsone) || ~isempty(detailszero)
                            rep = randsample([1 2 3], 2);
                            [a b] = size(detailszero);
                            if rep(1) > a; rep(1) = a; end
                            trials = [trials; detailszero(1:rep(1), :)];
                            detailszero(1:rep(1), :) = [];
                            [a b] = size(detailsone);
                            if rep(2) > a; rep(2) = a; end
                            trials = [trials; detailsone(1:rep(2), :)];
                            detailsone(1:rep(2), :) = [];
                        end
                    end
                end
            end
        else
            trials(1,:) = [];
            if isempty(trials)
                z = 0;
                for o = Par.Orientations
                    for r = [0, 1]
                        z = z+1;
                        detailsone(z,:) = [o, 1, r];
                    end
                end
                z = 0;
                for o = Par.Orientations
                    for r = [0, 1]
                        z = z+1;
                        detailszero(z,:) = [o, 0, r];
                    end
                end
                [ntrials, nvars] = size(detailsone);
                order = randperm(ntrials);
                detailsone = detailsone(order,:);
                detailszero = detailszero(order,:);
                
                trials = [];
                if side == 0
                    while ~isempty(detailsone) || ~isempty(detailszero)
                        rep = randsample([1 2 3], 2);
                        [a b] = size(detailsone);
                        if rep(1) > a; rep(1) = a; end
                        trials = [trials; detailsone(1:rep(1), :)];
                        detailsone(1:rep(1), :) = [];
                        [a b] = size(detailszero);
                        if rep(2) > a; rep(2) = a; end
                        trials = [trials; detailszero(1:rep(2), :)];
                        detailszero(1:rep(2), :) = [];
                    end
                else
                    while ~isempty(detailsone) || ~isempty(detailszero)
                        rep = randsample([1 2 3], 2);
                        [a b] = size(detailszero);
                        if rep(1) > a; rep(1) = a; end
                        trials = [trials; detailszero(1:rep(1), :)];
                        detailszero(1:rep(1), :) = [];
                        [a b] = size(detailsone);
                        if rep(2) > a; rep(2) = a; end
                        trials = [trials; detailsone(1:rep(2), :)];
                        detailsone(1:rep(2), :) = [];
                    end
                end
            end
        end
    else
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
    end
    
    %Display trial info and save log
    %LOG = {'Mouse', 'Mode', 'Date', 'RT', 'response', 'special', 'side', 'orientation', 'itiduration', 'gavepassive', 'bgcontrast', 'movementdelay', 'direction', 'figmotion', 'bgmotion', 'textureversion', 'ezmode', 'rewdurleftnorm', 'rewdurrightnorm', 'rewdurleftspec', 'rewdurrightspec'};
    switch mode
        case 1
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' RT: ' num2str(RT) ', Reaction: ' Reaction ,', Gave passive: ', num2str(gavepassive)]);
            LOG =  [LOG; {mouse, 'Standard', date, RT, Reaction, NaN, sidestring, orientation, itiduration, gavepassive, NaN, NaN, NaN, NaN, NaN, NaN, get(ezbox, 'Value'), str2num(get(rdurleft, 'String')), str2num(get(rdurright, 'String')), NaN, NaN}];
        case 2
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' RT: ' num2str(RT) ', Reaction: ' Reaction , ' ,Hole: ', num2str(special) ', Gave passive: ', num2str(gavepassive)]);
            LOG =  [LOG; {mouse, 'Hole', date, RT, Reaction, special, sidestring, orientation, itiduration, gavepassive, NaN, NaN, NaN, NaN, NaN, NaN, get(ezbox, 'Value'), str2num(get(rdurleft, 'String')), str2num(get(rdurright, 'String')), str2num(get(specialrdurleft, 'String')), str2num(get(specialrdurright, 'String'))}];
        case 3
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' RT: ' num2str(RT) ', Reaction: ' Reaction , ' ,BGContrast: ', num2str(currbgcontrast)]);
            LOG =  [LOG; {mouse, 'Motion', date, RT, Reaction, special, sidestring, orientation, itiduration, NaN, currbgcontrast, str2num(get(mdbox, 'string')), direction, get(fmbox, 'value'), get(bmbox, 'value'), NaN, get(ezbox, 'Value'), str2num(get(rdurleft, 'String')), str2num(get(rdurright, 'String')), NaN, NaN}];
        case 4
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' RT: ' num2str(RT) ', Reaction: ' Reaction ,', Gave passive: ', num2str(gavepassive)]);
            LOG =  [LOG; {mouse, 'Texture', date, RT, Reaction, NaN, sidestring, orientation, itiduration, gavepassive, NaN, NaN, NaN, NaN, NaN, version, get(ezbox, 'Value'), str2num(get(rdurleft, 'String')), str2num(get(rdurright, 'String')), NaN, NaN}];
        case 5
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' RT: ' num2str(RT) ', Reaction: ' Reaction ,', Gave passive: ', num2str(gavepassive)]);
            LOG =  [LOG; {mouse, 'Mask', date, RT, Reaction, get(maskbox, 'value'), sidestring, orientation, itiduration, gavepassive, currbgcontrast, NaN, NaN, NaN, NaN, NaN, get(ezbox, 'Value'), str2num(get(rdurleft, 'String')), str2num(get(rdurright, 'String')), NaN, NaN}];
        case 6
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' RT: ' num2str(RT) ', Reaction: ' Reaction , ' ,BGContrast: ', num2str(currbgcontrast)]);
            LOG =  [LOG; {mouse, 'Fade', date, RT, Reaction, special, sidestring, orientation, itiduration, NaN, currbgcontrast, str2num(get(mdbox, 'string')), NaN, get(fmbox, 'value'), get(bmbox, 'value'), NaN, get(ezbox, 'Value'), str2num(get(rdurleft, 'String')), str2num(get(rdurright, 'String')), NaN, NaN}];
        case 7
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' RT: ' num2str(RT) ', Reaction: ' Reaction , ' ,FigContrast: ', num2str(CENT.Contrast)]);
            LOG =  [LOG; {mouse, 'DualContrast', date, RT, Reaction, sidestring, orientation, itiduration,gavepassive, CENT.Contrast, SURR.Contrast, get(ezbox, 'Value'), get(drummbox, 'Value'), str2num(get(rdurleft, 'String')), str2num(get(rdurright, 'String'))}];
        case 8
            LOG =  [LOG; {mouse, 'BlackWhite', date, RT, Reaction, sidestring, color, str2num(get(bgfacbox, 'string')), itiduration, gavepassive, get(ezbox, 'Value'), get(drummbox, 'Value'), str2num(get(rdurleft, 'String')), str2num(get(rdurright, 'String'))}];
            display([ 'Trial: ' num2str(trialcount) ,' Side: ', sidestring ,' RT: ' num2str(RT) ', Reaction: ' Reaction , ' ,Color: ', colorstring, ' ,Background: ', get(bgfacbox, 'string'), ' ,Passive: ', num2str(gavepassive), ' ,Passfirst: ', num2str(passfirst), 'pdelay: ', get(pdbox, 'string')]); 
            %LOG = {'Mouse', 'Mode', 'Date', 'RT', 'response', 'side', 'color', 'bgfactor', 'itiduration', 'gavepassive', 'ezmode', 'drumm', 'rewdurleft', 'rewdurright'};
        case 9
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

