function res = gabor_filter_fade(GAB)
% Creates a Gabor filter for orientation and spatial frequency
% selectivity of orientation OR (in radians) and spatial frequency SF.

%PHSr=GAB.Phase/180*pi;

% create filter
[x,y]=meshgrid(-GAB.hsiz:GAB.hsiz);
X=x*cosd(GAB.Orient)+y*sind(GAB.Orient); %rotate axes

%snw=sin(2*pi*(1/GAB.Period)*X+PHSr);
res=sin(2*pi*(1/GAB.Period)*X+GAB.Phase);

% res = snw - min(snw(:));
% res = (res/range(res(:)))*(GAB.Pedestal +(GAB.Pedestal * GAB.Contrast)) - (GAB.Pedestal - (GAB.Pedestal * GAB.Contrast));
% res = res + GAB.Minlum;

% f=f-min(min(f));
% f=f./max(max(f));
% f = f.*2-1;