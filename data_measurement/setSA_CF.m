function [CF,MID] = setSA_CF(SA,f)
set(SA.Configure, 'CenterFreq', f.*1e9);
CF = get(SA.Configure, 'CenterFreq');

settings = invoke(SA.Spectrum, 'GetSettings');
MID.maxTracePoints = settings.traceLength;
MID.freqStepSize = settings.actualFreqStepSize;
MID.startFreq = settings.actualStartFreq;
MID.endFreq = MID.startFreq + (MID.maxTracePoints-1) * MID.freqStepSize;
MID.freqs = MID.startFreq:MID.freqStepSize:MID.endFreq;
end
