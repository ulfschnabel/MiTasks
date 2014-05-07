function [res, ressize] = setcontrast(snw, background, contrast, mask)

if contrast >= 1
    contrast = contrast/100;
end

res = snw - min(snw(:));
res = (res/range(res(:)))*((background + (background * contrast)) - (background - (background * contrast)));
res = res + (background - (background * contrast));
 
ressize = size(res,1); 

res = gammacon(res, 'lum2rgb');

if mask
    redfact = 1;
    x = (1:ressize)-((ressize+1)/2);
    x = repmat(x,ressize,1);
    y = x';
    f = find((x.^2+y.^2) > (((ressize.*redfact)+1)/2).^2);
    res(f) = 0;
end

res = reshape(res',ressize*ressize,1);

%Treble for color map
res = [res,res,res];