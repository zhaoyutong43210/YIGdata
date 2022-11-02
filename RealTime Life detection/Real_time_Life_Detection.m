function varargout = Real_time_Life_Detection(varargin)
% =========================================================================
% Interface of Real time Life Detection System 
% 2017 Sept 16th  Yutong Zhao
% University of Manitoba
% =========================================================================
% REAL_TIME_LIFE_DETECTION MATLAB code for Real_time_Life_Detection.fig
%      REAL_TIME_LIFE_DETECTION, by itself, creates a new REAL_TIME_LIFE_DETECTION or raises the existing
%      singleton*.
%
%      H = REAL_TIME_LIFE_DETECTION returns the handle to a new REAL_TIME_LIFE_DETECTION or the handle to
%      the existing singleton*.
%
%      REAL_TIME_LIFE_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REAL_TIME_LIFE_DETECTION.M with the given input arguments.
%
%      REAL_TIME_LIFE_DETECTION('Property','Value',...) creates a new REAL_TIME_LIFE_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Real_time_Life_Detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Real_time_Life_Detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Real_time_Life_Detection

% Last Modified by GUIDE v2.5 11-Sep-2017 21:16:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Real_time_Life_Detection_OpeningFcn, ...
                   'gui_OutputFcn',  @Real_time_Life_Detection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Real_time_Life_Detection is made visible.
function Real_time_Life_Detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Real_time_Life_Detection (see VARARGIN)

% Choose default command line output for Real_time_Life_Detection
handles.output = hObject;
% =========================================================================
cam=webcam('USB2.0 Camera');
img1 = snapshot(cam);
image(handles.axes1,img1);
set(handles.axes1,'visible','off');
imagesc(handles.axes2,zeros(100));
imagesc(handles.axes3,zeros(100));
set(handles.axes2,'visible','off');
set(handles.axes3,'visible','off');
% =========================================================================
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Real_time_Life_Detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Real_time_Life_Detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% Read settings from interface
Start_freq = str2double(get(handles.edit1,'String'));
End_freq = str2double(get(handles.edit2,'String'));
Sweep_points = str2double(get(handles.edit3,'String'));
global Video_Frames
Video_Frames = str2double(get(handles.edit4,'String'));
Distance = str2double(get(handles.edit5,'String'));
FFTfreq = str2double(get(handles.edit6,'String'));
% some pre-calculation

global Band_witdth
Band_witdth =(End_freq-Start_freq)*1e9; % bandwidth (make sure this matches the VNA settings)

raw_data=zeros(Sweep_points,Video_Frames);   % build a matrix "test" to store all measurement data
new_data=raw_data;                        % build a matrix "XX" to store all measurement data

cam=webcam('USB2.0 Camera');

%% Connect and initialize VNA 

VNA=gpib('ni',0,13);  %  create gpib port with address 13
VNA.ByteOrder='bigEndian';    %  define data order
%VNA.EOIMode	= 'off';
%Freq_number=256;    %  set the number of microwave frequencies (points) (256 works)

VNA.InputBufferSize = Sweep_points*20*5;  % define buffersize
fopen(VNA);            %  open the connection

fprintf(VNA,'*IDN?');  % write command to request ID 
idn=fscanf(VNA);       % read data sent by VNA 

%fprintf(VNA,'SYST:FPR');  % deletes the default trace, measurement, and window. The PNA screen becomes blank.
fprintf(VNA,'CALC:PAR:DEL:ALL');    % delete all the traces
fprintf(VNA,['CALC:PAR:DEF:EXT ' '''Meas2''' ', ' 'S21']);% define trace S21
%fprintf(VNA,'DISPlay:WINDow1:STATE ON'); % turn on windows

fprintf(VNA,'FORM REAL,32'); % define data format

fprintf(VNA,'SENS:FREQ:STAR 4000000000'); % define the start frequency
fprintf(VNA,'SENS:FREQ:STOP 6000000000'); % define the stop frequency
fprintf(VNA,['SENS:SWE:POIN ', num2str(Sweep_points)]); % define number of points to 256
fprintf(VNA,'SOUR:POW 10'); % define the power level to 10dbm
%")
disp('Initialization successfully');

pause(10);     %      pause for 2 senconds
%% Real time life detection begins
current_time = clock;

global name
name = num2str(current_time(1:5),'%02u%02u%02u%02u%02u');

v=VideoWriter(['main',name,'.avi']);
v.FrameRate= 10;% default=30
open(v);
vediohandle1=gcf;
handles.fig =vediohandle1;
tic  % start a time counting
for vf=1:Video_Frames
%============== VNA_read ================
fprintf(VNA,'CALC:MATH:MEM');    % store current trace data to VNA memory
fprintf(VNA,'CALC:DATA? SMEM');  % read VNA memory to bufffer (next two lines)
fread(VNA,6);      % read first 6 bits from buffer data (header bits in real 32 format)
%read measurement data from buffer. 2 points for each frequency because
%data is complex
data0=fread(VNA,Sweep_points*2,'float');   %read the measurement data (everything but header)
%fread(g,1);  
data_r=data0(1:2:end)+1i.*data0(2:2:end);      % combine real and imaginary components to form complex values
data_r=data_r.';                    % transpose the complex data
data_d=ifft(data_r);                % perform fourier transform on data (bring to time domain)
%========================================
% substract average
  raw_data(:,vf)=data_d;          % store data_d to iith column of test
  ave=mean(raw_data(:,1:(vf-1)).');  % get the running average from 1st to ii-1th column
  ave=ave.';                          %transpose the average
  new_data(:,vf)=raw_data(:,vf)-ave;    % substract the average from the data and store in XX
   
   if vf==1                                   % 1st measurement special case
   new_data(:,1)=0;
   elseif vf==2
   new_data(:,2)=raw_data(:,2)-raw_data(:,1); % 2nd measurement special case 
   end
    imagesc(handles.axes2,abs(new_data));        % colour graph object
    axis(handles.axes2,'xy')
    tvf=toc;                 % measurement time (x-axis)
    %axis(handles.axes2,[0.5,Video_Frames,0.5,256])
    
   
%xlabel('Time (s)','FontSize', 16)   % label x-acis
%ylabel('Distance (m)','FontSize', 16)
set(handles.axes2, 'YTick', [0 20 40 60 80 100 120 140 160 200 240 280 320 360].*Band_witdth./3e9)
set(handles.axes2,'YTickLabel',{'0', '1', '2','3','4','5','6','7','8','10','12','14','16','18'})
ylim([0.5 Distance])
set(handles.axes2, 'XTick', [0 vf])
set(handles.axes2,'XTickLabel',{'0',tvf,})
%set(gca,'FontName','Times New Roman','FontSize',16)
    
img1 = snapshot(cam);
image(handles.axes1,img1);
set(handles.axes1,'visible','off');

writeVideo(v,getframe(vediohandle1)); 
    
end

global tv
tv=toc; 

fclose(VNA);
delete(VNA);

global fft_data
fft_data=fft(new_data.').';
save(['data_',name,'.mat'],'new_data','fft_data','tv')
surface_map(fft_data,Band_witdth,name,tv,Distance,FFTfreq,handles)

for n = 1:50
writeVideo(v,getframe(vediohandle1)); 
end
print(vediohandle1,['FFT_analysis_',name,'.png'],'-r600')
close(v);
%% 

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global name
global fft_data
global tv
global Band_witdth
Distance = str2double(get(handles.edit5,'String'));
FFTfreq = str2double(get(handles.edit6,'String'));
surface_map(fft_data,Band_witdth,name,tv,Distance,FFTfreq)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
winopen(cd)


function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function surface_map(fft_data,BD,name,ti,d,fftfreq,handles)
my_size=size(fft_data);
dL=3e8/BD/2;  % resolution in distance
L=linspace(dL,dL*my_size(1),my_size(1)); % create distance array
L=L';       % transverse
LL=repmat(L,1,my_size(2)); % create distance array into matrix
Igor_L=reshape(LL,my_size(1)*my_size(2),1); % reshape distance matrix into a long array, ready for Igor

%t=linspace(dt,dt*my_size(2),my_size(2)); % time array

global Video_Frames
f=linspace(0,1/ti*Video_Frames,my_size(2)); % freq array

ff=repmat(f,my_size(1),1); % time matrix
Igor_f=reshape(ff,my_size(1)*my_size(2),1); % reshape time matrix into a long array, ready for Igor
Igor_s=reshape(fft_data,my_size(1)*my_size(2),1); % reshape data matrix into a long array, ready for Igor
Igor_SS=[Igor_L,Igor_f,Igor_s]; % combine all three arrays together.
%ltemp=linspace(min(Igor_L),max(Igor_L),my_size(1));
ltemp=linspace(0,8,my_size(1));
%ttemp=linspace(min(Igor_t),max(Igor_t),my_size(1));
ftemp=linspace(0.15,4,my_size(1));
[FF,LL]=meshgrid(ftemp,ltemp);
Z=griddata(Igor_f,Igor_L,Igor_s,FF,LL,'cubic');

%surf(handles.axes3,LL,TT,abs(Z))
surf(handles.axes3,LL,FF,abs(Z),'LineStyle','none')
%axis([0,10,0,1])
Data_file_name = (['Igorplot_',name,'data.txt']);
fp = fopen(Data_file_name,'w');
     fprintf(fp,'Distance(m)\t Frequency(Hz)\t Signal\t \r\n'); 
     fprintf(fp,' %e %e %e  \r\n',Igor_SS');
     fclose(fp);
save(['MATLAB',name,'data.mat'],'LL','FF','Z')
xlim(handles.axes3,[0 d])
ylim(handles.axes3,[0.15 fftfreq])

ylabel(handles.axes3,'Freq (Hz)')
xlabel(handles.axes3,'d (m)')

set(get(handles.axes3, 'xlabel'), 'Rotation', 16);	
set(get(handles.axes3, 'ylabel'), 'Rotation', -26);