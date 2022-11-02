function SG = create_SG(Address)
SG = gpib('ni',0,Address);
% SG.ByteOrder='bigEndian';
% SG.EOSMode = 'none';
SG.EOScharCode = 'CR';
SG.Timeout = 2;
fopen(SG);
info = query(SG,'*IDN?');
% query(SG,':FREQ:MODE?')
fprintf(SG,':OUTPut:STATe ON');
disp(info);
end