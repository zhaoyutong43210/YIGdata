function SG_SA_sweepXY_GPIB(f)
tic
%pause(300)
% *************************************************************************
% This function is for 
% =========================================================================
% For Win 64 system Only(VEX motor requirments)
% =========================================================================
% Yutong Zhao 2017 Sept 7th
% *************************************************************************
%% Settings
%close all force
instrreset;

timedelay = 0.1 ;
Name = 'data_0422_1';
position_shift = [0  0];
%% Connecting

motor = createMotor;
SA = creatSA(18);
SG = create_SG(5);

%% Programming the motor (Prepare)
move_motor2(motor,[0,0])
move_motor32(motor,0)
move_motor2(motor,position_shift)

%% define the discrete scanning
% flushoutput(SA);
% clrdevice(SA);
% position = [-x_range/2,-y_range/2]+position_shift;
% move_motor2(motor,position)

Y_array = round(linspace(-1000,1000,51));
X_array = round(linspace(-1000,1000,51));

Sig_array = zeros(length(X_array),length(Y_array));
% f = waitbar(0,'Please wait...');
if nargin < 1
    f = 2.816;
end
    setSGfreq(SG,f);

for n1 = 1:length(Y_array)
    Y = Y_array(n1);
for n2 = 1:length(X_array)
    X = X_array(n2);
    
    move_motor2(motor,([Y,X]+position_shift));
Sig = str2num(SetReadSA_CHP(SA,f));

while Sig > 0 || Sig < -120
Sig = str2num(SetReadSA_CHP(SA,f));
end

    Sig_array(n2,n1) = Sig;
    
end
end
% move_motor2(motor,[0,0]) 
move_motor2(motor,[0,0])
fprintf(SG,':OUTPut:STATe OFF'); % set the output to off
%close(f);
instrreset;
% imagesc(Y_array,X_array,Sig_array);axis xy
imagesc(Y_array*0.5e-2,X_array*0.5e-2,db2mag(Sig_array));axis xy;colormap jet;daspect([1 1 1])
% 
% d = (Sig_array);
% d = (d(1,1))-d;
% d = d/(max(max(d)));
% imagesc(Y_array*0.5e-2,X_array*0.5e-2,d);axis xy;colormap jet;daspect([1 1 1])

% save(Name,'Mapping','X_array','Y_array','X','Y')
c = colorbar;%('north')
% fig = figure; imagesc(X,Y,Mapping');colormap jet;colorbar;daspect([1 1 1])
xlabel('X (mm)')
ylabel('Y (mm)')
set(gca,'FontSize',16,'FontName','Times New Roman')
% caxis([0 1])

colorTitleHandle = get(c,'Title');
titleString = '|B_y|';
set(colorTitleHandle ,'String',titleString);

% print(fig,['Sweeped_Image.png'],'-dpng','-r600')

%data = reshape(MappingF,numel(MappingF),1);
toc
delete(SA);delete(SG);delete(motor);
save(['data_Xmappping5_',num2str(f),'_GHz.mat'])
end
