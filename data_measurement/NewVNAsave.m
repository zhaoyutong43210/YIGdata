function NewVNAsave(VNA,filename,timedelay)
fprintf(VNA,'SENS:AVER:CLE');
pause(timedelay);
fprintf(VNA,['CALC1:DATA:SNP:PORT:Save ''1'', ''D:/Raw/',filename,'.s2p''']);
end