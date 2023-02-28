function Sig = SetReadSA_CHP(SA,f,span)
if nargin <=2
   span = 1; 
end
%%F = num2str(round(f*1e5).*1e4)
fprintf(SA,['FREQ:CENT ',num2str(f),' GHz']);
%num2str(f)
 fprintf(SA,['CHP:BAND:INT ',num2str(span),' MHz']);
% fprintf(SA,['CHP:FREQ:SPAN ',num2str(span),' MHz']);
%num2str(span)
% fprintf(SA,':INIT:PAUS ');
fprintf(SA,['CALC:CHP:MARK1:X ',num2str(f*1e9)]);
%num2str(f*1e9)
pause(0.03)
fprintf(SA,['CALC:CHP:MARK1:Y?']);
Sig = fscanf(SA);
end