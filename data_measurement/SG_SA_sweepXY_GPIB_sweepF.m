function SG_SA_sweepXY_GPIB_sweepF

f_array = [2.4  2.6  2.686 2.69 2.695 2.7 2.705 2.71 2.715 2.72 2.725  2.815  2.925 2.938  3.0  3.2];
for n = 1:length(f_array)
    f = f_array(n);
    figure;
SG_SA_sweepXY_GPIB(f);
end

end