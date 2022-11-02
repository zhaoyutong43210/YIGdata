function S21_measure_SA_MG
%% ================================================================
% This is inspired by using a 
% 
% Hope this can be useful to other people. :)
% Yutong Zhao 
% Jun 25th 2019
% University of Manitoba
% =========================================================================
%% Settings
instrreset;

freq = linspace(2.6,3,1001);
date = '20190705_S21_5';

SG = create_SG(5);
SA = creatSA(18);

removeBG = 0;
Amp_mapping = zeros(length(freq),1);
tic
for k = 1:length(freq)
    f = round(freq(k).*1e4).*1e-4;
setSGfreq(SG,f)
pause(0.01)
% Data acquisition
Sig = str2num(SetReadSA_CHP(SA,f));

while Sig > 0 || Sig < -120
Sig = str2num(SetReadSA_CHP(SA,f));
end
Amp_mapping(k)= Sig;

end
toc

ind = (Amp_mapping > 1e5 | Amp_mapping < -80);
freq(ind) = [];
Amp_mapping(ind) =[];
%%
if removeBG == 1
BGdata = load('S21_BG.mat');
BGF = BGdata.freq;
BGS = BGdata.Amp_mapping;

BGSS = interp1(BGF,BGS,freq,'pchip');
S21_Signal = Amp_mapping - BGSS;
else 
S21_Signal = Amp_mapping;
end
%%

plot(freq,(S21_Signal),'-o')


fprintf(SG,':OUTPut:STATe OFF'); % set the output to off
%% Disconnect from all devices 

%fclose(fp);
save(['S21_',date])
end