function SA_AVE_save
instrreset;
SA = creatSA(18);

Ave_no = 100;
S_no = 2 ;
fprintf(SA,['CHP:AVER:COUN ',num2str(Ave_no)]);

% fprintf(SA,'INIT:RES');

pause(20)
fprintf(SA,[':MMEM:STORE:RES ''D:\FL\data\CMP8dBm_H',num2str(S_no),'_0_25A.csv''']);

instrreset;

end 