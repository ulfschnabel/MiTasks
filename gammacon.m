function out = gammacon(val,whichway)

%Convert rgb to luminance or vive versa using a gamma function
%values taken on 17/01/2012 in the psych room at contrast 85%, bright 50%
%Trinitron, T5400

%String argument can be either 'rgb2lum' or 'lum2rgb'

a  = 129.2;%77.5;
b = 2.1;%2.54;
if strcmp('rgb2lum',whichway)
    out = 0.01+a.*(val.^b); 
elseif strcmp('lum2rgb',whichway)
%     out = exp((log(val)-log(a))./(b+0.072));
    
    out = exp((log(val-0.106)-log(a))./b);
else
    disp('Invalid string input!')
    out = 0;
    return
end

return 