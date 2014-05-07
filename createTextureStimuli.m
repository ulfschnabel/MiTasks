maxlum = gammacon(0.5,'rgb2lum');%was 0.7 untill 20130725
minlum = gammacon(0,'rgb2lum');
greylum = (maxlum+minlum)./2;

Par.BackGrey = gammacon(greylum/2, 'lum2rgb') ;
grey = Par.BackGrey;
Par.BarGrey = gammacon(2*greylum, 'lum2rgb') ;

Par.BarOrient = [45 135];%[135 315];
Par.Speed = 20;
Par.FigSize = 50.*Ang2Pix;


Par.Versions = 4;

spritex = 1280;
spritey = 720;
barlength = round(25.*Ang2Pix);
barthick = round(3.*Ang2Pix);
nbars = 125;
z = 0;


for v = 1:Par.Versions
	for o = 1:length(Par.BarOrient)
		z = z+1;
		cgmakesprite(z,Par.Screenx,Par.Screeny, [Par.BackGrey, Par.BackGrey, Par.BackGrey])
		cgsetsprite(z)
		%Pick random x and y positions
		X = ceil(rand(nbars,1).*spritex)-(spritex/2);
		Y = ceil(rand(nbars,1).*spritey)-(spritey/2);

		%Calculate end points
		X2 = round(X+(cosd(Par.BarOrient(o)).*barlength));
		Y2 = round(Y+(sind(Par.BarOrient(o)).*barlength));

		cgpenwid(barthick)
		cgdraw(X,Y,X2,Y2,repmat(Par.BarGrey,nbars,3))

        
		%sprdet(z,:) = [z,v,o];

		%TXT(z).X = X;
		%TXT(z).Y = Y;
	end
end
cgsetsprite(0)