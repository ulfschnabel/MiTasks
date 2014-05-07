function sendard(com, message)

    rep = 'n';
    fprintf(com, message) %Enable 1st reward valve
    n = 1;
    while ~strcmp(rep, 'D')
        if com.BytesAvailable
            rep = fscanf(com, '%s');
        end;
        n = n+1;
        pause(0.001)
        if n > 30
            fprintf(com, message) %Enable 1st reward valve
            n = 1;
            disp(['Trouble sending ', message ' , trying again']);
        end
    end
    while com.BytesAvailable
        disp(['Found strange things while sending ', message])
        disp(fgets(com))
    end

end