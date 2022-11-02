function GPIB_Lockin_communicate_demo
% *************************************************************************
% This Function is write for Dynamic Spintronics Group.
% This Code gives a sample that read data from Lock-in amplifier through
% different methods. (FAST mode, Query mode and buffer mode)
% =========================================================================
% For FAST mode:
% The binary data of X & Y is sending from GPIB when EACH data measured and 
% stored during measurement.
% =========================================================================
% Query mode: 
% Use the query command to read the most resent stored in buffer. This
% command can request in ASCII floating point. Some data points may missing
% and the sampling rate may not be constant.
% =========================================================================
% buffer mode: 
% Read the data from buffer, Command can be input during measurement. But
% the data read need to PAUSE the data scan.
% =========================================================================
% For more information about Model SR380 DSP Lock-in Amplifier: 
% http://www.thinksrs.com/downloads/PDFs/Manuals/SR830m.pdf
% =========================================================================
% Yutong Zhao 2017.May.12 University of Manitoba (version 1.0)
% *************************************************************************
%% Create connection with Lock-in Amplifier
g=gpib('ni',0,18);    % Check the address of lock-in
g.ByteOrder='bigEndian'; % The code Enaian
% Just use default setting
g.EOSMode = 'read';
%g.EOIMode = 'off';
g.Timeout = 60;       % The measure time may longger than 10s
g.Outputbuffer = 3000;% The buffer store command waiting to write in Lock-in
g.Inputbuffer = 16383*14+1; % The buffer store data points from Lock-in
fopen(g);             % Create connection with Lock-in
fprintf(g,'OUTX1');   % Set the output interface to GPIB
sample_points=100;    % Number of points that will be read out from lock-in
%clrdevice(g);        % Clear buffer if necessary
%% Lock-in Setup
fprintf(g,'*RST');        % Initialize the lock-in(to default settings)
fprintf(g,'SRAT13;SEND0');% DataSample Rate = 64Hz & Data Scan Mode= shot;
                          % Other options: For SRAT
                          % 4=1Hz;5=2Hz;6=4Hz;7=8Hz;8=16Hz;9=32Hz;10=64Hz;
                          % 11=128Hz;12=256Hz;13=512Hz;
                          % The maximum DataSample Rate is 512Hz
                          % For SEND, 0=short; 1=loop

%fprintf(g,'SLVL 0.02');   % set the sine output amplitude to 0.02V
fprintf(g,'DDEF1,1,0;DDEF2,1,0');
% Set CH1=R, CH2=theta; Buffers store CH1 and CH2;
fprintf(g,'SENS 22');     % set the sensitivity as 50mV/nA
                          % (I guess it's the range of measurements)
%disp('Scan is iniyialized, Press any key to continue......')
%disp('Lock-in Communicating initalization successfully')

tc=6;
fprintf(g,['OFLT',num2str(tc)]); % set the time constant to 100ms
                     % Other optional values:
                     % 6=10ms,7=30ms,8=100ms,9=300ms,10=1000ms
%% Data acqusiation 
fprintf(g,'PAUS');
fprintf(g,'REST'); % clear buffer 
fprintf(g,'FAST1;STRD');

% ==================== FAST Mode read ========================
tic
% read the real-time binary data send by GPIB; Check the Timeout Value!
data_bi=fread(g,[sample_points,2],'int16');  % Short or int16
toc
% ==================== FAST Mode read  end ====================
% =================== Query mode read ==============================
data_query=zeros(4,sample_points);
t0=clock;
tic
for n=1:sample_points
    fprintf(g,'SNAP? 1,2,3,4');
    data_query(:,n)=fscanf(g,'%f,%f,%f,%f');
    % lock-in command can goes here
end
ti=etime(clock,t0);
toc
% =================== Query mode  read end ==========================
fprintf(g,'PAUS');
fprintf(g,'SPTS?'); % Query data points stored in buffer
pause(0.01)
data_number=fscanf(g);
tic
% =================== Buffer mode read ==============================
fprintf(g,['TRCA?1,0,',num2str(sample_points)]); % Channel 1 buffer(R)
data_buffer=fscanf(g,'%e,',sample_points);
% =================== Buffer mode read end===========================
toc

%% Plotting
t=1:1:sample_points;
t=t/512;
figure(1);
R=sqrt(data_bi(1,:).^2+data_bi(2,:).^2)/30000*0.05;

subplot(3,1,2)
plot(t,R,'x-')
xlabel('time(s)')
ylabel('Amplitudes (V)')
axis([0 0.25 0 0.05])
legend('Time Constant = 1ms')
title('FAST mode read')

subplot(3,1,1)
t1=linspace(0,ti,sample_points);
plot(t1,data_query(3,:),'x-')
xlabel('time(s)')
ylabel('Amplitudes (V)')
axis([0 0.25 0 0.05])
title('Query mode read')

subplot(3,1,3)
plot(t,data_buffer,'x-')
xlabel('time(s)')
ylabel('Amplitudes (V)')
axis([0 0.25 0 0.05])
legend('Time Constant = 1ms')
title('buffer mode read')

%% End of read, Close the connection
fclose(g);
% if this lane is not executed due to an error or exit the debug mode
% midway. The connection with the Lock-in Amplifier still exist, A new
% connection creation would be impossible. The solution is to close the
% MATLAB and open it again. 
%% Write the data from lock-in to a txt file
%fileID = fopen('lockin_data.txt','w');

%fprintf(fileID,'%6s,%12s,%6s,%6s\r\n','x','exp(x)');
%fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\r\n',dataset');
%fclose(fileID);
end