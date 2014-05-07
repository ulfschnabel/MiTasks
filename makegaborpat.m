function [ac,GAB] = makegaborpat(sprno,GAB)

%Make Gabor in luminance space
f = gabor_filter(GAB); % edit gabor_filter
% figure;imagesc(f);colorbar;axis square;


%Work out the luminaces required to generate a given contrast given the
%luminace pedestal of the Gabor
black=gammacon(0,'rgb2lum');
GAB.L = (GAB.Contrast./100).*(GAB.pedestal-black);
gb = GAB.pedestal+(GAB.L.*f);

%Actual contrast of Gabor (will always be slightly smaller than asked for)
ac = 100.*((max(max(gb))-min(min(gb)))./(max(max(gb))+min(min(gb)))); % actual contrast

%Convert back to rgb
gb = gammacon(gb,'lum2rgb');

%Extract into RGB vector
sz=size(gb,1); 

%Mask gabor to make it circular
if GAB.mask
    redfact = 1;
    x = (1:sz)-((sz+1)/2);
    x = repmat(x,sz,1);
    y = x';
    f = find((x.^2+y.^2) > (((sz.*redfact)+1)/2).^2);
    gb(f) = 0;
end

gb = reshape(gb',sz*sz,1);

%Treble for color map
gb = [gb,gb,gb];

cgloadarray(sprno,sz,sz,gb,sz,sz)

%if masking, set black to be transparent
if GAB.mask
   cgtrncol(sprno,'n') 
end
