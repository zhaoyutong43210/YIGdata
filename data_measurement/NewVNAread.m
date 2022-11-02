function data = NewVNAread(VNA,freq_n,timedelay)
pause(timedelay)

fprintf(VNA,'CALC:MATH:MEM');    % store current trace data to VNA memory
fprintf(VNA,'CALC:DATA? SMEM');  % read VNA memory to bufffer (next two lines)
fread(VNA,6);      % read first 6 bits from buffer data (header bits in real 32 format)
%read measurement data from buffer. 2 points for each frequency because
%data is complex
data0=fread(VNA,freq_n*2,'float');   %read the measurement data (everything but header)
fread(VNA,1);  
data_r=data0(1:2:end)+1i.*data0(2:2:end);      % combine real and imaginary components to form complex values
data_r=data_r.';                    % transpose the complex data
data = abs(data_r);
%data_d=ifft(data_r);                % perform fourier transform on data (bring to time domain)
%========================================
end
