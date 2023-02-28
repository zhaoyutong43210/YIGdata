function [SA,UDP,UDS,UDT,MID] = createUSB_SA
SA = icdevice('RSA_API_Driver');
connect(SA); 
%% set SA 
UDP.centerFreq =  1e9;
UDP.timeout = 2;
UDP.refLevel = 0;

UDS.span = 3e4;
UDS.rbw = 1e3;
UDS.enableVBW = false;
UDS.vbw = 10e3;
UDS.traceLength = 1001;
UDS.window = 'SpectrumWindow_Kaiser';
UDS.verticalUnit = 'SpectrumVerticalUnit_dBm';

%Adjustable values for spectrum trace
UDT.trace = 'SpectrumTrace1';
UDT.enable = true;
UDT.detector = 'SpectrumDetector_PosPeak';

%Set user desired parameters for graphing spectrum
set(SA.Configure, 'CenterFreq', UDP.centerFreq);
set(SA.Configure, 'ReferenceLevel', UDP.refLevel);

%Get user desired parameters for graphing spectrum
centerFrequency = get(SA.Configure, 'CenterFreq');
refLvl = get(SA.Configure, 'ReferenceLevel');

%Verify user desired parameters for graphing by printing to screen
% fprintf('Center frequency: %g\n', centerFrequency);
% fprintf('Reference Level: %d\n', refLvl);
% 
% fprintf('\n');

%Obtain limits of spectrum
limits = invoke(SA.Spectrum, 'GetLimits');
% fprintf('Spectrum Limits: \n');
% fprintf('     Minimum Span: %d\n', limits.minSpan);
% fprintf('     Maximum Span: %d\n', limits.maxSpan);
% fprintf('     Minimum RBW: %d\n', limits.minRBW);
% fprintf('     Maximum RBW: %d\n', limits.maxRBW);
% fprintf('     Minimum VBW: %d\n', limits.minVBW);
% fprintf('     Maximum VBW: %d\n', limits.maxVBW);
% fprintf('     Minimum Trace Length: %d\n', limits.minTraceLength);
% fprintf('     Maximum Trace Length: %d\n', limits.maxTraceLength);
% 
% % %Uncomment this section and comment SetSettings to set default
% % %parameters for Spectrum
% % %Set default parameters for Spectrum
% % fprintf('Setting default values for spectrum\n');
% % invoke(dev.Spectrum, 'SetDefault');
% 
% fprintf('\n');


%Set user defined parameters for Spectrum
invoke(SA.Spectrum, 'SetSettings', UDS);

%Obtain settings of spectrum
settings = invoke(SA.Spectrum, 'GetSettings');
% fprintf('Settings for Spectrum:\n');
% fprintf('     Span: %d\n', settings.span);
% fprintf('     RBW: %d\n', settings.rbw);
% fprintf('     VBW Status: %d\n', settings.enableVBW);
% fprintf('     VBW: %d\n', settings.vbw);
% fprintf('     Trace Length: %d\n', settings.traceLength);
% fprintf('     Window: %s\n', settings.window);
% fprintf('     Vertical Unit: %s\n', settings.verticalUnit);
% fprintf('     Actual Start Frequency: %d\n', settings.actualStartFreq);
% fprintf('     Actual Stop Frequency: %d\n', settings.actualStopFreq)
% fprintf('     Actual Frequency Step Size: %d\n', settings.actualFreqStepSize);
% fprintf('     Actual RBW: %g\n', settings.actualRBW);
% fprintf('     Actual Start VBW: %d\n', settings.actualVBW);
% fprintf('     Actual Number of IQ Samples: %d\n', settings.actualNumIQSamples);
% 
% fprintf('\n');
%Enable Spectrum
enabled = true;
set(SA.Spectrum, 'Enable', enabled);
% enable = get(SA.Spectrum, 'Enable');
% fprintf('Spectrum Enable Status: %d\n', enable);
% 
% fprintf('\n');

%Set trace type
invoke(SA.Spectrum, 'SetTraceType', UDT.trace, UDT.enable, UDT.detector);

%Obtain trace properties
[enable, detector] = invoke(SA.Spectrum, 'GetTraceType', UDT.trace);
% fprintf('Spectrum Trace:\n     Detector: %s\n     Type: %s\n     Enable Status: %d\n', UDT.trace, detector, enable);
%     
% fprintf('\n');

%Parameters used for Spectrum plot
MID.maxTracePoints = settings.traceLength;
MID.freqStepSize = settings.actualFreqStepSize;
MID.startFreq = settings.actualStartFreq;
MID.endFreq = MID.startFreq + (MID.maxTracePoints-1) * MID.freqStepSize;
MID.freqs = MID.startFreq:MID.freqStepSize:MID.endFreq;
end
