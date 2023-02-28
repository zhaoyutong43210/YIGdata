function motor = createMotor
% Motor connection and setup
serialInfo = instrhwinfo('serial') ; % Find the aviliable serial ports
port = serialInfo.AvailableSerialPorts{1};
% Check this if you have more than one Serial Ports!!!
motor = serial(port);
motor.Timeout = 0.2;
% Sampling Rates ~= 20Hz (from real measurements)
fopen(motor);

