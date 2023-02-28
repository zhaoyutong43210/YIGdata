function move_motor32(motor,zposition)
fprintf(motor,['C,E,I3AM',num2str(zposition),',R']);
while 1
    flushinput(motor)
    flushoutput(motor)
    
    fprintf(motor,'Z,');
    z = fscanf(motor,'%s',9);
%     % byA = motor.BytesAvailable;
%    if isempty(z)
%           z = NaN;
%    elseif isnan(z(1))
%         z = z(2:end);
%     end
     Coor=str2double(z);
    if Coor == zposition
    break
    end
end
end
