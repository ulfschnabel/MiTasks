sport = serial('com3');
if strcmp(get(sport, 'status'), 'closed'); fopen(sport); end;
set(sport, 'baudrate', 115200);



lastreward = tic;
sendard(sport, ['IF ' '8000'])
sendard(sport, ['IL ' '250'])
sendard(sport, ['IR ' '250'])
sendard(sport, ['IM ' '1'])


while 1
    if toc(lastreward) > 5
        a = randsample([0, 1], 1);
        if a
            sendard(sport, 'IE 1')
        else
            sendard(sport, 'IE 2')
        end
        fprintf(sport, 'IS');
    end
    if toc(lastreward) > 30
            lastreward = tic;
            sendard(sport, 'IP')
    end
    if sport.BytesAvailable
        while ~strcmp(I, 'O') && sport.BytesAvailable
            I = fscanf(sport, '%s');
            break
        end
        if strcmp(I, 'O')
            pause(0.01)
            if sport.BytesAvailable
                Reaction = fscanf(sport, '%s');
            end
            if sport.BytesAvailable
                RT = fscanf(sport, '%s');
            end
            if sport.BytesAvailable
                passfirst = str2num(fscanf(sport, '%s'));
            end
            %buf = fread(sport, 240, 'uchar');
            disp(Reaction)
            lastreward = tic;
        end
        
    end
end

%%

calllib(Par.Dll,'Das_Clear');
unloadlibrary(Par.Dll)

if strcmp(get(sport, 'status'), 'open'); fclose(sport); end;

clear all
