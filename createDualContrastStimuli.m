
centercontrast = 40;

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
CENT.pedestal = greylum;
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
