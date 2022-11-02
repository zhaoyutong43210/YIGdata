function move_motor2(motor,position)
fprintf(motor,['C,E,I1AM',num2str(position(1)),',I2AM',num2str(position(2)),',R']);
while 1
    flushinput(motor)
    flushoutput(motor)
    
    fprintf(motor,'X,');
%     % byA = motor.BytesAvailable;
       x = fscanf(motor,'%s',9);
%        if isnan(x(1))
%        x = x(2:end);
%        end
       Coor(1)=str2double(x);
       fprintf(motor,'Y,');
       y = fscanf(motor,'%s',9);
%         if isnan(y(1))
%            y = y(2:end);
%        end
     Coor(2)=str2double(y);
    if Coor == position
    break
    end
end
%pause(0.5)
end
