
centercontrast = 80;

CENT.Size = str2num(get(fsizebox, 'string'));

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

z = 0;
for J=1:length(Par.Orientations)
    CENT.Orient = Par.Orientations(J);
    %display(['Orientation: ' num2str(CENT.Orient)]);
    z = z+1;
    CENT.Phase=0;   %now no movement
    [acref,CENT] = makegaborpat(z,CENT);
    if  ~exist('sprite1end', 'var')
        sprite1end=z;
        %display(['sprite1end: ' num2str(sprite1end)]);
    end
end

    
    