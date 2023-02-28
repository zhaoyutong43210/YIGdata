function VNA = createVNA(address)
VNA=gpib('ni',0,address);  %  create gpib port with address 13
VNA.ByteOrder='bigEndian';    %  define data order
%VNA.EOIMode	= 'off';
Sweep_points = 401;
%Freq_number=256;    %  set the number of microwave frequencies (points) (256 works)

VNA.InputBufferSize = Sweep_points*20*5;  % define buffersize
fopen(VNA);            %  open the connection

fprintf(VNA,'*IDN?');  % write command to request ID 
idn=fscanf(VNA);       % read data sent by VNA 
disp(idn)

%fprintf(VNA,'CALC:PAR:DEL:ALL'); 
%fprintf(VNA,'CALC1:PAR:EXT ''T1'', ''S21'''); 
end
