function SA = creatSA(Address)
SA = gpib('ni',0,Address);
% SG.ByteOrder='bigEndian';
% SG.EOSMode = 'none';
SA.EOScharCode = 'CR';
SA.Timeout = 2;
fopen(SA);
info = query(SA,'*IDN?');
% query(SA,':FREQ:MODE?')
%fprintf(SA,':OUTPut:STATe ON');
disp(info);

end