sport = serial('com3');
if strcmp(get(sport, 'status'), 'closed'); fopen(sport); end;
set(sport, 'baudrate', 115200);

one = [];
two = [];

figure
plot(rand(1, 10))
h = get(gca, 'Children'); 
drawnow
ylim([-1000 10000])
xlim([0 5000])
lastreward = tic;
start = tic;
while 1
    thist = tic;
   while sport.BytesAvailable && toc(thist) < 0.1
      one = [one str2num(fscanf(sport, '%s'))];
   end
   if size(one) <= 5000
     set(h, 'YData', one)
   else
      one = [];
   end
   drawnow
   
   if toc(lastreward) > 15
       fprintf(sport, 'IP');
       lastreward = tic;
   end
end


if strcmp(get(sport, 'status'), 'open'); fclose(sport); end;