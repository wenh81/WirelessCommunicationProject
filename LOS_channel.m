clear all, clc, close all


Pars.fc = 1e9;
Pars.c = physconst('LightSpeed');
Pars.lambda = Pars.c/Pars.fc;

Geometry.BSPos = [0,0,25]; % macrocell with high 25m
Geometry.V1PosStart = [70,-100,1.5]; % start Veichile 1
Geometry.V1PosEnd = [70,100,1.5]; % end Veichile 1
Geometry.V2PosStart = [200,-50,1.5]; % start Veichile 2
Geometry.V2PosEnd = [10,-50,1.5]; % end Veichile 2

Geometry.I1Pos = [10,-210,1.5]; 
Geometry.I2Pos = [-150,100,1.5];

% CreateScenarioAndVisualize(Geometry, Pars);
Geometry.T1 = dist3D(Geometry.V1PosStart, Geometry.V1PosEnd);  % distance covered by V1
Geometry.T2 = dist3D(Geometry.V2PosStart, Geometry.V2PosEnd);  % distance covered by V2

Geometry.DistV1Start = dist3D(Geometry.V1PosStart, Geometry.BSPos); % initial distance between BS and V1
Geometry.DistV2Start = dist3D(Geometry.V2PosStart, Geometry.BSPos); % initial distance between BS and V2


% DoA = [AoA ZoA] at beginning 
% (Direction of Arrival) = (Angle of Arriv. Zenith of Arriv.)
% Zenith = 90 - Elevation Angle
Geometry.AOAV1Start = AoA(Geometry.BSPos, Geometry.V1PosStart);
Geometry.ZOAV1Start = ZoA(Geometry.BSPos, Geometry.V1PosStart);
Geometry.DOAV1Start = [Geometry.AOAV1Start Geometry.ZOAV1Start]; % DOA of V1

Geometry.AOAV2Start = AoA(Geometry.BSPos, Geometry.V2PosStart);
Geometry.ZOAV2Start = ZoA(Geometry.BSPos, Geometry.V2PosStart);
Geometry.DOAV2Start = [Geometry.AOAV2Start Geometry.ZOAV2Start]; % DOA of V2


% Defining 4x4 antenna array BS, separated by lambda/2
Geometry.BSarray = phased.URA('Size',[4 4],...
    'ElementSpacing', [Pars.lambda/2 Pars.lambda/2], 'ArrayNormal', 'x');

% Position of elements of antenna array
Geometry.BSAntennaPos = getElementPosition(Geometry.BSarray);

Geometry.confarray = phased.ConformalArray('ElementPosition',Geometry.BSAntennaPos);
viewArray(Geometry.confarray);





% Define waveform1
Fsin1 = 600;
Ts = 1e-5;
Fsample = 1/Ts; % 10 khz
TsVect = 0:Ts:5/Fsin1; % up to 5 periods
waveform1 = sin(2*pi*Fsin1*TsVect);

% Define waveform2
Fsin2 = 1200;
waveform2 = sin(2*pi*Fsin2*TsVect);



% Calculation on waveform
receivedW = collectPlaneWave(Geometry.BSarray, [waveform1' waveform2'],...
        [Geometry.DOAV1Start', Geometry.DOAV2Start'], Pars.fc);
    

% Add AWGN
Pars.SNR = 20; % dB
chOut = awgn(receivedW, Pars.SNR, 'measured');



