centercontrast = 80;

CENT.Size = Par.FigSize;

maxlum = gammacon(0.5,'rgb2lum');%was 0.7 untill 20130725
minlum = gammacon(0,'rgb2lum');
greylum = (maxlum+minlum)./2;
PAR.greylum = greylum;
grey = gammacon(greylum,'lum2rgb');
PAR.grey = grey;


gabsize = [80];
%Spat Frequency in cyc/deg
CENT.SF     = Par.SpatFreq;
CENT.Period = round(Ang2Pix./CENT.SF);
%half-size of Gabor in degrees
CENT.hsiz   = round((CENT.Size./2).*Ang2Pix./CENT.Period).*CENT.Period; % half of total size of figure
%standard deviation of Gabor (x and y)
CENT.sigma_x = (CENT.Size./4)*Ang2Pix;
CENT.sigma_y = (CENT.Size./4)*Ang2Pix;
% CENT.Orient = 90;
CENT.Contrast = centercontrast;
%Mask to make circular?
CENT.mask = 1;
%Gabor or grating?
CENT.Grat = 1;
%Place on luminance pedestal? Enter greylum value for no pedestal
CENT.Pedestal = greylum;
CENT.Speed = 24;
Cycpersec = CENT.Speed.*CENT.SF;
Secpercyc = 1 / Cycpersec;
%We know the refresh rate, so we can work out
%how many phase steps we need per refresh
%But for memory reasons we should only make as many stimuli as we need
%for the stimulus duration
Steps = Secpercyc/(1/Par.Refresh);
phasesteps = 0:(2.*pi./Steps):(2*pi - 2.*pi./Steps);
%phasesteps = 2*pi*1:-(2.*pi.*Steps):0;

%% Background Settings
%Gabor strucxture of "surround"
%Size in degrees
%This is the size of the occluder - the Gabor is always full-screen

SURR.Size = (Par.Screenx + 150)./Ang2Pix;
%Spat Frequency in cyc/deg
SURR.SF     = Par.SpatFreq;
SURR.Period = round(Ang2Pix./SURR.SF);
%half-size of Gabor in degrees
SURR.hsiz   = round((SURR.Size./2).*Ang2Pix./SURR.Period).*SURR.Period; % half of total size of figure
%standard deviation of Gabor (x and y)
SURR.sigma_x = (SURR.Size./4)*Ang2Pix;
SURR.sigma_y = (SURR.Size./4)*Ang2Pix;
%Mask to make circular?
SURR.mask = 0;
SURR.Phase = 0;
%Gabor or grating?
SURR.Grat = 1;
%Place on luminance pedestal? Enter greylum value for no pedestal
SURR.pedestal = greylum;
SURR.OccSize = gabsize; %JL removed occluder
SURR.Contrast = str2num(get(contbox, 'string'));


%create the gabors

%colors

CENT.Orient = 45;
SURR.Orient = 135;
CENT.Phase = 0;

Cycpersec = CENT.Speed.*CENT.SF;
Secpercyc = 1 / Cycpersec;
%We know the refresh rate, so we can work out
%how many phase steps we need per refresh
%But for memory reasons we should only make as many stimuli as we need
%for the stimulus duration
Steps = Secpercyc/(1/Par.Refresh);
phasesteps = 0:(2.*pi./Steps):(2*pi - 2.*pi./Steps);





frames = 0:(1/60):5;
lookup = -ones(2*length(frames), 7);
figconttimes = 0:2/centercontrast:2;
bgconttimes = 0:2/SURR.Contrast:2;

figspritecount = 1;
bgspritecount = 501;
a = tic;

pos = 1;
for j = [45, 135]
    CENT.Orient = j;
    SURR.Orient = j + 90;
    for k = 1:length(phasesteps);
        CENT.Phase = phasesteps(k);
        centstim{k} = gabor_filter_fade(CENT);
    end
    
    for k = 1:length(phasesteps);
        SURR.Phase = phasesteps(k);
        surrstim{k} = gabor_filter_fade(SURR);
    end
    
    
    
    figcont = 1;
    bgcont = 1;
    bgmotcount = 1;
    figmotcount = 1;
    for i = 1:length(frames)
        %[figcontrast, bgcontrast, figphasestep, bgphasestep, figsprite, bgsprite, figorientation]
        if frames(i) > figconttimes(figcont) && figcont < CENT.Contrast
            figcont = figcont + 1;
        end
        if frames(i) > bgconttimes(bgcont) && bgcont < SURR.Contrast
            bgcont = bgcont + 1;
        end
        %check if sprites were already made
        if find(ismember([lookup(:, 1), lookup(:, 3), lookup(:, 7)], [figcont, phasesteps(figmotcount), j], 'rows'))
            figsprite = min(lookup(find(ismember([lookup(:, 1), lookup(:, 3), lookup(:, 7)], [figcont, phasesteps(figmotcount), j], 'rows')), 5));
        else
            [figtmp, figsize]= setcontrast(centstim{figmotcount}, greylum, figcont, 1);
            cgloadarray(figspritecount,figsize,figsize,figtmp,figsize,figsize)
            cgtrncol(figspritecount,'n')
            figsprite = figspritecount;
            figspritecount = figspritecount + 1;
        end
        if find(ismember([lookup(:, 2), lookup(:, 4), lookup(:, 7)], [bgcont, phasesteps(bgmotcount), j], 'rows'))
            bgsprite = min(lookup(find(ismember([lookup(:, 2), lookup(:, 4), lookup(:, 7)], [bgcont, phasesteps(bgmotcount), j], 'rows')), 6));
        else
            [bgtmp, bgsize] = setcontrast(surrstim{bgmotcount}, greylum, bgcont, 0);
            cgloadarray(bgspritecount,bgsize,bgsize,bgtmp,bgsize,bgsize)
            cgtrncol(bgspritecount,'n')
            bgsprite = bgspritecount;
            bgspritecount = bgspritecount + 1;
            
        end
        lookup(pos, :) = [figcont, bgcont, phasesteps(figmotcount), phasesteps(bgmotcount), figsprite, bgsprite, j];
        pos = pos + 1;
        if get(fmbox, 'value')
            figmotcount = figmotcount + 1;
        end
        if figmotcount > max(length(phasesteps))
            figmotcount = 1;
        end
        if get(bmbox, 'value')
            bgmotcount = bgmotcount + 1;
        end
        if bgmotcount > max(length(phasesteps))
            bgmotcount = 1;
        end
    end
end
toc(a)