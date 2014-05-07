function makenoisepattern(spritenum, psize, sf, pixperdeg)

    maxlum = gammacon(0.5,'rgb2lum');%was 0.7 untill 20130725
    minlum = gammacon(0,'rgb2lum');
    greylum = (maxlum+minlum)./2;
    psize = psize * pixperdeg;
    
    period = round(pixperdeg/sf/10);
    
    bighalfsize = round((psize/2/ period) * period);
    [MA, MB] = meshgrid(-bighalfsize:bighalfsize);
    
    halfsize = round((psize/2/ period) * period) / 10;
    gradient = -halfsize:halfsize;
    
    offset = rand(1)*2*pi;
    
    pattern = [];
    for i = 1:length(gradient)
        pattern(i, :, 1) = sin(2*pi*(1/period)*gradient+ offset);
    end
    
    for i = 1:length(gradient)
        pattern(:, i, 2) = sin(2*pi*(1/period)*gradient+ offset);
    end
    
    pattern = mean(pattern, 3);


    
    [X, Y] = meshgrid(gradient);
    [Xq, Yq] = meshgrid(-halfsize:0.1:halfsize);
    pattern = (interp2(X,Y, (pattern + rand(size(pattern))), Xq, Yq) + 1)/4;
    
    %pattern = pattern - min(min(pattern));
    %pattern = pattern * (0.5 / max(max(pattern)));
    
    
    sigma_x = (psize/4);
	sigma_y = (psize/4);
    
    gab = (1/(2*pi*sigma_x*sigma_y)).*exp(-(1/2)*(((MA/sigma_x).^2)+((MB/sigma_y).^2)));
    gab = gab/max(max(gab));
    pmean = nanmean(nanmean(pattern));
    pattern = pattern - pmean;
    pattern = pattern .* gab + pmean;
    pattern = pattern *maxlum;
    pmean = nanmean(nanmean(pattern));
    pattern = pattern - (pmean - greylum);
    
    pattern = gammacon(pattern,'lum2rgb');
    psize = length(pattern);
    redfact = 1;
    x = (1:psize)-((psize+1)/2);
    x = repmat(x,psize,1);
    y = x';
    f = find((x.^2+y.^2) > (((psize.*redfact)+1)/2).^2);
    pattern(f) = 0;
    
    gb = reshape(pattern',psize*psize,1);
    gb = [gb,gb,gb];
    cgloadarray(spritenum,psize,psize,gb,psize,psize)
    cgtrncol(spritenum,'n') 