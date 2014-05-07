function f = gabor_filter(GAB)
% Creates a Gabor filter for orientation and spatial frequency
% selectivity of orientation OR (in radians) and spatial frequency SF.

%PHSr=GAB.Phase/180*pi;

% create filter
[x,y]=meshgrid(-GAB.hsiz:GAB.hsiz);
X=x*cosd(GAB.Orient)+y*sind(GAB.Orient); %rotate axes
Y=-x*sind(GAB.Orient)+y*cosd(GAB.Orient);
nd = (1/(2*pi*GAB.sigma_x*GAB.sigma_y)).*exp(-(1/2)*(((X/GAB.sigma_x).^2)+((Y/GAB.sigma_y).^2))); % figure;imagesc(nd);colorbar; 

%figure;plot(nd(round(size(nd,1)/2),:))
%nd = nd-min(min(nd));
nd = nd./max(max(nd));
%snw=sin(2*pi*(1/GAB.Period)*X+PHSr);
snw=sin(2*pi*(1/GAB.Period)*X+GAB.Phase);

if GAB.Grat
    f = snw;
else
    f = nd.*snw;
end
% f=f-min(min(f));
% f=f./max(max(f));
% f = f.*2-1;