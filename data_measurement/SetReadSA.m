function Sig = SetReadSA(SA,f,span)
if nargin <=2
   span = 2; 
end
%%F = num2str(round(f*1e5).*1e4)
fprintf(SA,['FREQ:CENT ',num2str(f),' GHz']);
%num2str(f)
fprintf(SA,['FREQ:SPAN ',num2str(span),' MHz']);
%num2str(span)
fprintf(SA,[':CALC:MARK1:X ',num2str(f*1e9)]);
%num2str(f*1e9)
pause(0.4)
fprintf(SA,[':CALC:MARK1:Y?']);
Sig = fscanf(SA);
end