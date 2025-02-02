%% Preparing

clear all;
close all;
clc;


figure();

for k=0:3
    
    %% Defining geometry and pars
    
    % Number of interferents:
    N_interf = k;
    
    % CArrier frequency and wavelength
    Pars.fc = 2.6e9;
    Pars.c = physconst('LightSpeed');
    Pars.lambda = Pars.c / Pars.fc;
    
    % BS position (macrocell with high 25m):
    Geometry.BSPos = [0, 0, 0];
    
    
    % First veichle (V1):
    Geometry.V1PosStart = [25*cos((0)*pi/180), 25*sin((0)*pi/180), 0]; % start
    Geometry.V1PosEnd = [70, 100, 1.5];    % end
    
    % Second veichle (V2):
    Geometry.V2PosStart = [25*cos((20)*pi/180), 25*sin((20)*pi/180), 0]; % start
    Geometry.V2PosEnd = [10, -50, 1.5];    % end
    
    % Second veichle (V3):
    Geometry.V3PosStart = [25*cos((40)*pi/180), 25*sin((40)*pi/180), 0]; % start
    Geometry.V3PosEnd = [10, -50, 1.5];    % end
    
    % Second veichle (V4):
    Geometry.V4PosStart = [25*cos((60)*pi/180), 25*sin((60)*pi/180), 0]; % start
    Geometry.V4PosEnd = [10, -50, 1.5];    % end
    
    
    
    % Distance covered by veichle 1:
    Geometry.T1 = dist3D(Geometry.V1PosStart, Geometry.V1PosEnd);  % V1
    
    % Initial DoA = [AoA ZoA] (ZoA = 90 - elevation angle):
    Geometry.AOAV1Start = AoA(Geometry.V1PosStart, Geometry.BSPos);
    Geometry.ZOAV1Start = ZoA(Geometry.BSPos, Geometry.V1PosStart);
    Geometry.DOAV1Start = [Geometry.AOAV1Start Geometry.ZOAV1Start-90]; % DoA of V1
    
    % Distance covered by veichle 2:
    Geometry.T2 = dist3D(Geometry.V2PosStart, Geometry.V2PosEnd);  % V2
    
    % Initial DoA = [AoA ZoA] (ZoA = 90 - elevation angle):
    Geometry.AOAV2Start = AoA(Geometry.V2PosStart, Geometry.BSPos);
    Geometry.ZOAV2Start = ZoA(Geometry.BSPos, Geometry.V2PosStart);
    Geometry.DOAV2Start = [Geometry.AOAV2Start Geometry.ZOAV2Start-90]; % DoA of V2
    
    % Distance covered by veichle 3:
    Geometry.T3 = dist3D(Geometry.V3PosStart, Geometry.V3PosEnd);  % V3
    
    % Initial DoA = [AoA ZoA] (ZoA = 90 - elevation angle):
    Geometry.AOAV3Start = AoA(Geometry.V3PosStart, Geometry.BSPos);
    Geometry.ZOAV3Start = ZoA(Geometry.BSPos, Geometry.V3PosStart);
    Geometry.DOAV3Start = [Geometry.AOAV3Start Geometry.ZOAV3Start-90]; % DoA of V3
    
    % Distance covered by veichle 4:
    Geometry.T4 = dist3D(Geometry.V4PosStart, Geometry.V4PosEnd);  % V4
    
    % Initial DoA = [AoA ZoA] (ZoA = 90 - elevation angle):
    Geometry.AOAV4Start = AoA(Geometry.V4PosStart, Geometry.BSPos);
    Geometry.ZOAV4Start = ZoA(Geometry.BSPos, Geometry.V4PosStart);
    Geometry.DOAV4Start = [Geometry.AOAV4Start Geometry.ZOAV4Start-90]; % DoA of V4
    
    
    
    
    % Defining a rectangular Nant x Nant antenna array with antenna spacing = lambda/2:
    Geometry.Nant = 4;
    Geometry.BSarray = phased.URA('Size', [Geometry.Nant Geometry.Nant], ...
        'ElementSpacing', [Pars.lambda/2 Pars.lambda/2], 'ArrayNormal', 'x');
    
    % Getting position antenna array:
    Geometry.BSAntennaPos = getElementPosition(Geometry. BSarray);
    
    % Creating conformal antenna array:
    Geometry.confarray = phased.ConformalArray('ElementPosition', Geometry.BSAntennaPos);
    
    
    %% Generation of ODFM modulators and demodulators, M-QAM modulators and waveforms
    
    % VEHICLE 1
    % Number of ODFM symbols:
    nSymbols1 = 100;
    
    % Pilots symbols positioning at first antenna
    pilot_indices1 = [11]';
    
    % Band Carriers
    NumGuardBandCarriers = [1;1];
    
    % Nfft for OFDM modulation
    nfft  = 64;
    
    % Cyclic prefix length:
    CyclicPrefixLength  = [4];
    
    % First OFDM modulator:
    ofdmMod1 = comm.OFDMModulator('FFTLength', nfft, ...
        'NumGuardBandCarriers', NumGuardBandCarriers, ... % Default values
        'InsertDCNull', false, ...
        'CyclicPrefixLength', CyclicPrefixLength, ...
        'Windowing', false, ...
        'NumSymbols', nSymbols1, ...
        'NumTransmitAntennas', 1, ...
        'PilotInputPort', true, ...
        'PilotCarrierIndices', pilot_indices1);
    
    % QAM modulation order:
    M1 = 4;
    
    % Generation of random bits:
    bitInput1 = randi([0 1], (nfft - (length(pilot_indices1) + sum(NumGuardBandCarriers))) * nSymbols1 * log2(M1), 1);
    
    % Mudulation of bit_in_1 with QAM modulator:
    dataInput1 = qammod(bitInput1, M1, 'gray', 'InputType', 'bit', 'UnitAveragePower', true);
    
    % Preparing dataInput1 for OFDM modulation:
    ofdmInfo1 = info(ofdmMod1);
    ofdmSize1 = ofdmInfo1.DataInputSize;
    dataInput1 = reshape(dataInput1, ofdmSize1);
    
    % OFDM modulation:
    pilotInput1 = ones(1, nSymbols1, 1);
    waveform1 = ofdmMod1(dataInput1, pilotInput1);
    
    
    
    % VEHICLE 2
    % Pilot indices for second modulator:
    pilot_indices2 = pilot_indices1 + 5;
    
    % Definition of a second OFDM modulator (different pilot carrier indices and different number of symbols):
    nSymbols2 = nSymbols1;
    ofdmMod2 = comm.OFDMModulator('FFTLength', nfft, ...
        'NumGuardBandCarriers', NumGuardBandCarriers, ...
        'InsertDCNull', false, ...
        'CyclicPrefixLength', CyclicPrefixLength, ...
        'Windowing', false, ...
        'NumSymbols', nSymbols2, ...
        'NumTransmitAntennas', 1, ...
        'PilotInputPort', true, ...
        'PilotCarrierIndices', pilot_indices2);
    
    % Definition of a second M-QAM modulator:
    M2 = M1;
    
    % Generation of a second random string of bits:
    bitInput2 = randi([0 1], (nfft - (length(pilot_indices1) + sum(NumGuardBandCarriers))) * nSymbols2 * log2(M2), 1);
    
    % QAM modulation of bitInput2:
    dataInput2 = qammod(bitInput2, M2, 'gray', 'InputType', 'bit', 'UnitAveragePower', true);
    
    % Preparing QAM modulated singal for OFDM modulation:
    ofdmInfo2 = info(ofdmMod2);
    ofdmSize2 = ofdmInfo2.DataInputSize;
    dataInput2 = reshape(dataInput2, ofdmSize2);
    
    % OFDM modulation:
    pilotInput2 = ones(1, nSymbols2, 1);
    waveform2 = ofdmMod2(dataInput2, pilotInput2);
    
    
    
    % VEHICLE 3
    % Pilot indices for second modulator:
    pilot_indices3 = pilot_indices1 + 6;
    
    % Definition of a second OFDM modulator (different pilot carrier indices and different number of symbols):
    nSymbols3 = nSymbols1;
    ofdmMod3 = comm.OFDMModulator('FFTLength', nfft, ...
        'NumGuardBandCarriers', NumGuardBandCarriers, ...
        'InsertDCNull', false, ...
        'CyclicPrefixLength', CyclicPrefixLength, ...
        'Windowing', false, ...
        'NumSymbols', nSymbols3, ...
        'NumTransmitAntennas', 1, ...
        'PilotInputPort', true, ...
        'PilotCarrierIndices', pilot_indices3);
    
    % Definition of a second M-QAM modulator:
    M3 = M1;
    
    % Generation of a second random string of bits:
    bitInput3 = randi([0 1], (nfft - (length(pilot_indices1) + sum(NumGuardBandCarriers))) * nSymbols3 * log2(M3), 1);
    
    % QAM modulation of bitInput3:
    dataInput3 = qammod(bitInput3, M3, 'gray', 'InputType', 'bit', 'UnitAveragePower', true);
    
    % Preparing QAM modulated singal for OFDM modulation:
    ofdmInfo3 = info(ofdmMod3);
    ofdmSize3 = ofdmInfo3.DataInputSize;
    dataInput3 = reshape(dataInput3, ofdmSize3);
    
    % OFDM modulation:
    pilotInput3 = ones(1, nSymbols3, 1);
    waveform3 = ofdmMod3(dataInput3, pilotInput3);
    
    
    
    % VEHICLE 4
    % Pilot indices for second modulator:
    pilot_indices4 = pilot_indices1 + 7;
    
    % Definition of a second OFDM modulator (different pilot carrier indices and different number of symbols):
    nSymbols4 = nSymbols1;
    ofdmMod4 = comm.OFDMModulator('FFTLength', nfft, ...
        'NumGuardBandCarriers', NumGuardBandCarriers, ...
        'InsertDCNull', false, ...
        'CyclicPrefixLength', CyclicPrefixLength, ...
        'Windowing', false, ...
        'NumSymbols', nSymbols4, ...
        'NumTransmitAntennas', 1, ...
        'PilotInputPort', true, ...
        'PilotCarrierIndices', pilot_indices3);
    
    % Definition of a second M-QAM modulator:
    M4 = M1;
    
    % Generation of a second random string of bits:
    bitInput4 = randi([0 1], (nfft - (length(pilot_indices1) + sum(NumGuardBandCarriers))) * nSymbols4 * log2(M4), 1);
    
    % QAM modulation of bitInput4:
    dataInput4 = qammod(bitInput4, M4, 'gray', 'InputType', 'bit', 'UnitAveragePower', true);
    
    % Preparing QAM modulated singal for OFDM modulation:
    ofdmInfo4 = info(ofdmMod4);
    ofdmSize4 = ofdmInfo4.DataInputSize;
    dataInput4 = reshape(dataInput4, ofdmSize4);
    
    % OFDM modulation:
    pilotInput4 = ones(1, nSymbols4, 1);
    waveform4 = ofdmMod4(dataInput4, pilotInput4);
    
    
    
    
    
    % OFDM demodulators definition:
    ofdmDemod1 = comm.OFDMDemodulator(ofdmMod1);
    ofdmDemod2 = comm.OFDMDemodulator(ofdmMod2);
    ofdmDemod3 = comm.OFDMDemodulator(ofdmMod3);
    ofdmDemod4 = comm.OFDMDemodulator(ofdmMod4);
    
    
    
    
    % Visualizing OFDM mapping:
    % showResourceMapping(ofdmMod1);
    % title('OFDM modulators (1 = 2)');
    
    
    
    
    %% Definition of working parameters and outputs
    
    % SNR vector:
    Pars.SNR = 0:9;
    
    % Definition of output of the channel with noise:
    chOut_noise = zeros(size(waveform1, 1), Geometry.Nant^2, length(Pars.SNR));
    chOut1_noise = zeros(size(waveform1, 1), Geometry.Nant^2, length(Pars.SNR));
    chOut2_noise = zeros(size(waveform1, 1), Geometry.Nant^2, length(Pars.SNR));
    noise = zeros(size(waveform1, 1), Geometry.Nant^2, length(Pars.SNR));
    
    % Definition of output SNR vectors:
    SNR_out_simple_BF = zeros(1, length(Pars.SNR));
    SNR_out_nulling_BF = zeros(1, length(Pars.SNR));
    SNR_out_mvdr_BF = zeros(1, length(Pars.SNR));
    SNR_out_lms_BF = zeros(1, length(Pars.SNR));
    SNR_out_mmse_BF = zeros(1, length(Pars.SNR));
    
    % Set of outputs of the differen beamformers (overall signal):
    chOut_simple_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut_nulling_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut_mvdr_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut_lms_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut_mmse_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    
    % Set of outputs of the differen beamformers (signal from V1):
    chOut1_simple_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut1_nulling_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut1_mvdr_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut1_lms_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut1_mmse_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    
    % Set of outputs of the differen beamformers (signal from V2):
    chOut2_simple_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut2_nulling_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut2_mvdr_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut2_lms_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut2_mmse_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    
    % Set of outputs of the differen beamformers (signal from V3):
    chOut3_simple_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut3_nulling_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut3_mvdr_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut3_lms_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut3_mmse_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    
    % Set of outputs of the differen beamformers (signal from V4):
    chOut4_simple_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut4_nulling_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut4_mvdr_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut4_lms_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    chOut4_mmse_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    
    % Set of weigths of the differen beamformers:
    w_simple_BF = zeros((Geometry.Nant)^2, length(Pars.SNR));
    w_nulling_BF = zeros((Geometry.Nant)^2, length(Pars.SNR));
    w_mvdr_BF = zeros((Geometry.Nant)^2, length(Pars.SNR));
    w_lms_BF = zeros((Geometry.Nant)^2, length(Pars.SNR));
    w_mmse_BF = zeros((Geometry.Nant)^2, length(Pars.SNR));
    
    % Noise after BF:
    noise_simple_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    noise_nulling_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    noise_mvdr_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    noise_lms_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    noise_mmse_BF = zeros(size(waveform1, 1), length(Pars.SNR));
    
    %% Looping for finding weigths for different levels of SNR:
    
    for i = 1 : length(Pars.SNR)
        
        
        %% LOS channel
        
        
        % Generation of LoS channel for good signal:
        chOut1 = LOS(waveform1, Geometry.V1PosStart, Geometry.BSPos, Pars);
        
        % Generation of LoS channel for interfering signal (if present):
        switch N_interf
            case 0
                chOut2 = 0 * LOS(waveform2, Geometry.V2PosStart, Geometry.BSPos, Pars);
                chOut3 = 0 * LOS(waveform3, Geometry.V3PosStart, Geometry.BSPos, Pars);
                chOut4 = 0 * LOS(waveform4, Geometry.V4PosStart, Geometry.BSPos, Pars);
            case 1
                chOut2 = 1 * LOS(waveform2, Geometry.V2PosStart, Geometry.BSPos, Pars);
                chOut3 = 0 * LOS(waveform3, Geometry.V3PosStart, Geometry.BSPos, Pars);
                chOut4 = 0 * LOS(waveform4, Geometry.V4PosStart, Geometry.BSPos, Pars);
            case 2
                chOut2 = 1 * LOS(waveform2, Geometry.V2PosStart, Geometry.BSPos, Pars);
                chOut3 = 1 * LOS(waveform3, Geometry.V3PosStart, Geometry.BSPos, Pars);
                chOut4 = 0 * LOS(waveform4, Geometry.V4PosStart, Geometry.BSPos, Pars);
            case 3
                chOut2 = 1 * LOS(waveform2, Geometry.V2PosStart, Geometry.BSPos, Pars);
                chOut3 = 1 * LOS(waveform3, Geometry.V3PosStart, Geometry.BSPos, Pars);
                chOut4 = 1 * LOS(waveform4, Geometry.V4PosStart, Geometry.BSPos, Pars);
        end
        
        steervec = phased.SteeringVector('SensorArray',Geometry.BSarray);
        s1 = steervec(Pars.fc, Geometry.DOAV1Start');
        s2 = steervec(Pars.fc, Geometry.DOAV2Start');
        s3 = steervec(Pars.fc, Geometry.DOAV3Start');
        s4 = steervec(Pars.fc, Geometry.DOAV4Start');
        
        
        
        
        %% Adding noise wrt the current SNR
        
        noise = zeros(size(chOut1,1), Geometry.Nant^2);
        for j=1:Geometry.Nant^2
            chOut1_noise = awgn(chOut1, Pars.SNR(i), 'measured');
            noise(:,j) = chOut1_noise - chOut1(:, :);
        end
        
        
        % Calculation of received wavefroms:
        chOut1 = collectPlaneWave(Geometry.BSarray, [chOut1], ...
            [Geometry.DOAV1Start'], Pars.fc);
        chOut2 = collectPlaneWave(Geometry.BSarray, [chOut2], ...
            [Geometry.DOAV2Start'], Pars.fc);
        chOut3 = collectPlaneWave(Geometry.BSarray, [chOut3], ...
            [Geometry.DOAV3Start'], Pars.fc);
        chOut4 = collectPlaneWave(Geometry.BSarray, [chOut4], ...
            [Geometry.DOAV4Start'], Pars.fc);
        
        
        chOut_noise(:, :, i) = chOut1 + chOut2 + chOut3 + chOut4 + noise;
        
        
        
        % SNR_in = 10 * log10(sum(abs(fft(chOut1)).^2) / sum(abs(fft(noise(:, :, i))).^2))
        P_V1_in = mean(sum(abs(fft(chOut1)).^2));
        P_V2_in = mean(sum(abs(fft(chOut2)).^2));
        P_V3_in = mean(sum(abs(fft(chOut3)).^2));
        P_V4_in = mean(sum(abs(fft(chOut4)).^2));
        P_noise_in = mean(sum(abs(fft(noise)).^2));
        
        Rv1_in = chOut1'*chOut1;
        Rv2_in = chOut2'*chOut2;
        Rv3_in = chOut3'*chOut3;
        Rv4_in = chOut4'*chOut4;
        Rn = squeeze(noise)'* squeeze(noise);
        
        %Rv1_in = ones(Geometry.Nant^2, Geometry.Nant^2)*Rv1_in(1);
        %sigma2n = Rv1_in(1) / (10^(Pars.SNR(i)/10));
        %Rn = sigma2n * eye(Geometry.Nant^2);
        
        Ru = Rv1_in + Rv2_in + Rv3_in + Rv4_in + Rn;
        
        
        %% Assignment of DoA:
        
        switch N_interf
            case 0
                DoA = [Geometry.DOAV1Start'];
            case 1
                DoA = [Geometry.DOAV1Start' Geometry.DOAV2Start'];
            case 2
                DoA = [Geometry.DOAV1Start' Geometry.DOAV2Start' Geometry.DOAV3Start'];
            case 3
                DoA = [Geometry.DOAV1Start' Geometry.DOAV2Start' Geometry.DOAV3Start' Geometry.DOAV4Start'];
        end
        
        
        %% Applying BF techniques
        
        % Simple BF:
        [chOut_simple_BF(:, i), w_simple_BF(:, i)] = ...
            Conventional_BF(Geometry, Pars, DoA(:, 1), squeeze(chOut1));
        %     figure;
        %     pattern(Geometry.BSarray,Pars.fc,[-180:180],DoA(2),...
        %         'PropagationSpeed',Pars.c,...
        %         'Type','powerdb',...
        %         'CoordinateSystem','rectangular','Weights',w_simple_BF(:, i))
        
        % Nullsteering BF:
        [chOut_nulling_BF(:, i), w_nulling_BF(:, i)] = ...
            Nullsteering_BF(Geometry, Pars, DoA, squeeze(chOut1));
        %     figure;
        %     pattern(Geometry.BSarray,Pars.fc,[-180:180],DoA(2),...
        %         'PropagationSpeed',Pars.c,...
        %         'Type','powerdb',...
        %         'CoordinateSystem','rectangular','Weights',w_nulling_BF(:, i))
        %     g1 = [1,zeros(1,N_interf)]';
        %     w_nulling_BF(:, i) = g1'*[s1 s2]'*inv([s1 s2]*[s1 s2]'+0.01*eye(Geometry.Nant^2));
        
        
        % MVDR BF:
        [chOut_mvdr_BF(:, i), w_mvdr_BF(:, i)] = ...
            MVDR_BF(Geometry, Pars, DoA(:, 1), squeeze(chOut_noise(:, :, i)));
        %     figure;
        %     pattern(Geometry.BSarray,Pars.fc,[-180:180],DoA(2),...
        %         'PropagationSpeed',Pars.c,...
        %         'Type','powerdb',...
        %         'CoordinateSystem','rectangular','Weights',w_mvdr_BF(:, i))
        %     w_mvdr_BF(:, i) = inv(Ru)*s1/(s1'*inv(Ru)*s1);
        
        
        % LMS BF:
        nTrain = round(length(chOut1(:,1)) / 2);
        [chOut_lms_BF(:, i), w_lms_BF(:, i)] = ...
            LMS_BF(Geometry, Pars, DoA(:, 1), squeeze(chOut1), waveform1(1:nTrain, :));
        %     figure;
        %     pattern(Geometry.BSarray,Pars.fc,[-180:180],DoA(2),...
        %         'PropagationSpeed',Pars.c,...
        %         'Type','powerdb',...
        %         'CoordinateSystem','rectangular','Weights',w_lms_BF(:, i))
        
        % MMSE BF:
        nTrain = round(length(chOut1(:,1)));
        [chOut_mmse_BF(:, i), w_mmse_BF(:, i)] = ...
            MMSE_BF(Geometry, Pars, squeeze(chOut_noise(:, :, i)), waveform1(1:nTrain, :));
        %     figure;
        %     pattern(Geometry.BSarray,Pars.fc,[-180:180],DoA(2),...
        %         'PropagationSpeed',Pars.c,...
        %         'Type','powerdb',...
        %         'CoordinateSystem','rectangular','Weights',w_mmse_BF(:, i))
        %     w_mmse_BF(:, i) = inv(Ru)*s1;
        
        
        %% Passing the signals through the different BFs
        
        % Simple BF:
        % chOut1_simple_BF(:, i) = (chOut1_noise(:, :, i)' * (w_simple_BF(:, i)))';
        % chOut2_simple_BF(:, i) = (chOut2_noise(:, :, i)' * (w_simple_BF(:, i)))';
        chOut1_simple_BF(:, i) = ((w_simple_BF(:, i))') * chOut1.';
        chOut2_simple_BF(:, i) = ((w_simple_BF(:, i))') * chOut2.';
        chOut3_simple_BF(:, i) = ((w_simple_BF(:, i))') * chOut3.';
        chOut4_simple_BF(:, i) = ((w_simple_BF(:, i))') * chOut4.';
        chOut_simple_BF(:, i) = ((w_simple_BF(:, i))') * squeeze(chOut_noise(:, :, i)).';
        noise_simple_BF(:, i) = ((w_simple_BF(:, i))') *  noise.';
        
        % Nullsteering BF:
        % chOut1_nulling_BF(:, i) = transpose(chOut1_noise(:, :, i)' * (w_nulling_BF(:, i)));
        % chOut2_nulling_BF(:, i) = transpose(chOut2_noise(:, :, i)' * (w_nulling_BF(:, i)));
        chOut1_nulling_BF(:, i) = ((w_nulling_BF(:, i))') * chOut1.';
        chOut2_nulling_BF(:, i) = ((w_nulling_BF(:, i))') * chOut2.';
        chOut3_nulling_BF(:, i) = ((w_nulling_BF(:, i))') * chOut3.';
        chOut4_nulling_BF(:, i) = ((w_nulling_BF(:, i))') * chOut4.';
        chOut_nulling_BF(:, i) = ((w_nulling_BF(:, i))') * squeeze(chOut_noise(:, :, i)).';
        noise_nulling_BF(:, i) = ((w_nulling_BF(:, i))') * noise.';
        
        % MVDR BF:
        % chOut1_mvdr_BF(:, i) = transpose(chOut1_noise(:, :, i)' * (w_mvdr_BF(:, i)));
        % chOut2_mvdr_BF(:, i) = transpose(chOut2_noise(:, :, i)' * (w_mvdr_BF(:, i)));
        chOut1_mvdr_BF(:, i) = ((w_mvdr_BF(:, i))') * chOut1.';
        chOut2_mvdr_BF(:, i) = ((w_mvdr_BF(:, i))') * chOut2.';
        chOut3_mvdr_BF(:, i) = ((w_mvdr_BF(:, i))') * chOut3.';
        chOut4_mvdr_BF(:, i) = ((w_mvdr_BF(:, i))') * chOut4.';
        chOut_mvdr_BF(:, i) = ((w_mvdr_BF(:, i))') * squeeze(chOut_noise(:, :, i)).';
        noise_mvdr_BF(:, i) = ((w_mvdr_BF(:, i))') * noise.';
        
        % LMS BF:
        % chOut1_lms_BF(:, i) = transpose(chOut1_noise(:, :, i)' * (w_lms_BF(:, i)));
        % chOut2_lms_BF(:, i) = transpose(chOut2_noise(:, :, i)' * (w_lms_BF(:, i)));
        chOut1_lms_BF(:, i) = ((w_lms_BF(:, i))') * chOut1.';
        chOut2_lms_BF(:, i) = ((w_lms_BF(:, i))') * chOut2.';
        chOut3_lms_BF(:, i) = ((w_lms_BF(:, i))') * chOut3.';
        chOut4_lms_BF(:, i) = ((w_lms_BF(:, i))') * chOut4.';
        chOut_lms_BF(:, i) = ((w_lms_BF(:, i))') * squeeze(chOut_noise(:, :, i)).';
        noise_lms_BF(:, i) = ((w_lms_BF(:, i))') * noise.';
        
        % MMSE BF:
        % chOut1_mmse_BF(:, i) = transpose(chOut1_noise(:, :, i)' * (w_mmse_BF(:, i)));
        % chOut2_mmse_BF(:, i) = transpose(chOut2_noise(:, :, i)' * (w_mmse_BF(:, i)));
        chOut1_mmse_BF(:, i) = ((w_mmse_BF(:, i))') * chOut1.';
        chOut2_mmse_BF(:, i) = ((w_mmse_BF(:, i))') * chOut2.';
        chOut3_mmse_BF(:, i) = ((w_mmse_BF(:, i))') * chOut3.';
        chOut4_mmse_BF(:, i) = ((w_mmse_BF(:, i))') * chOut4.';
        chOut_mmse_BF(:, i) = ((w_mmse_BF(:, i))') * squeeze(chOut_noise(:, :, i)).';
        noise_mmse_BF(:, i) = ((w_mmse_BF(:, i))') * noise.';
        
        %% Computation of the power of good (V1) and interfering (V2) singals after the BF and of SNR:
        
        % Simple BF:
        P1_simple_BF = sum(abs(fft(chOut1_simple_BF(:, i))).^2);
        P2_simple_BF = sum(abs(fft(chOut2_simple_BF(:, i))).^2);
        P3_simple_BF = sum(abs(fft(chOut3_simple_BF(:, i))).^2);
        P4_simple_BF = sum(abs(fft(chOut4_simple_BF(:, i))).^2);
        Ptot_simple_BF = sum(abs(fft(chOut_simple_BF(:, i))).^2);
        P_noise_simple_BF = sum(abs(fft(noise_simple_BF(:, i))).^2);
        SNR_out_simple_BF(i) = P1_simple_BF / (P2_simple_BF + P3_simple_BF + P4_simple_BF + P_noise_simple_BF);
        SNR_out_simple_BF(i) = 10 * log10(SNR_out_simple_BF(i));
        
        %     Pn = (w_simple_BF(:, i))'*Rn*(w_simple_BF(:, i)); %Noise power
        %     Psout = (w_simple_BF(:, i))'*Rv1_in*(w_simple_BF(:, i)); %Output signal power
        %     Piout = (w_simple_BF(:, i))'*Rv2_in*(w_simple_BF(:, i)); %Interference power
        %     SNR_out_simple_BF(i) = Psout/(Pn+Piout);
        %     SNR_out_simple_BF(i) = 10 * log10(real(SNR_out_simple_BF(i)));
        
        
        % Null-steering BF:
        P1_nulling_BF = sum(abs(fft(chOut1_nulling_BF(:, i))).^2);
        P2_nulling_BF = sum(abs(fft(chOut2_nulling_BF(:, i))).^2);
        P3_nulling_BF = sum(abs(fft(chOut3_nulling_BF(:, i))).^2);
        P4_nulling_BF = sum(abs(fft(chOut4_nulling_BF(:, i))).^2);
        Ptot_nulling_BF = sum(abs(fft(chOut_nulling_BF(:, i))).^2);
        P_noise_nulling_BF = sum(abs(fft(noise_nulling_BF(:, i))).^2);
        SNR_out_nulling_BF(i) = P1_nulling_BF / (P2_nulling_BF + P3_nulling_BF + P4_nulling_BF + P_noise_nulling_BF);
        SNR_out_nulling_BF(i) = 10 * log10(SNR_out_nulling_BF(i));
        
        %     Pn = (w_nulling_BF(:, i))'*Rn*(w_nulling_BF(:, i)); %Noise power
        %     Psout = (w_nulling_BF(:, i))'*Rv1_in*(w_nulling_BF(:, i)); %Output signal power
        %     Piout = (w_nulling_BF(:, i))'*Rv2_in*(w_nulling_BF(:, i)); %Interference power
        %     SNR_out_nulling_BF(i) = Psout/(Pn+Piout);
        %     SNR_out_nulling_BF(i) = 10 * log10(real(SNR_out_nulling_BF(i)));
        
        
        % MVDR BF:
        P1_mvdr_BF = sum(abs(fft(chOut1_mvdr_BF(:, i))).^2);
        P2_mvdr_BF = sum(abs(fft(chOut2_mvdr_BF(:, i))).^2);
        P3_mvdr_BF = sum(abs(fft(chOut3_mvdr_BF(:, i))).^2);
        P4_mvdr_BF = sum(abs(fft(chOut4_mvdr_BF(:, i))).^2);
        Ptot_mvdr_BF = sum(abs(fft(chOut_mvdr_BF(:, i))).^2);
        P_noise_mvdr_BF = sum(abs(fft(noise_mvdr_BF(:, i))).^2);
        SNR_out_mvdr_BF(i) = P1_mvdr_BF / (P2_mvdr_BF + P3_mvdr_BF + P4_mvdr_BF + P_noise_mvdr_BF);
        SNR_out_mvdr_BF(i) = 10 * log10(SNR_out_mvdr_BF(i));
        
        %     Pn = (w_mvdr_BF(:, i))'*Rn*(w_mvdr_BF(:, i)); %Noise power
        %     Psout = (w_mvdr_BF(:, i))'*Rv1_in*(w_mvdr_BF(:, i)); %Output signal power
        %     Piout = (w_mvdr_BF(:, i))'*Rv2_in*(w_mvdr_BF(:, i)); %Interference power
        %     SNR_out_mvdr_BF(i) = Psout/(Pn+Piout);
        %     SNR_out_mvdr_BF(i) = 10 * log10(real(SNR_out_mvdr_BF(i)));
        
        
        % LMS BF:
        P1_lms_BF = sum(abs(fft(chOut1_lms_BF(:, i))).^2);
        P2_lms_BF = sum(abs(fft(chOut2_lms_BF(:, i))).^2);
        P3_lms_BF = sum(abs(fft(chOut3_lms_BF(:, i))).^2);
        P4_lms_BF = sum(abs(fft(chOut4_lms_BF(:, i))).^2);
        Ptot_lms_BF = sum(abs(fft(chOut_lms_BF(:, i))).^2);
        P_noise_lms_BF = sum(abs(fft(noise_lms_BF(:, i))).^2);
        SNR_out_lms_BF(i) = P1_lms_BF / (P2_lms_BF + P3_lms_BF +  P4_lms_BF + P_noise_lms_BF);
        SNR_out_lms_BF(i) = 10 * log10(SNR_out_lms_BF(i));
        
        %     Pn = (w_lms_BF(:, i))'*Rn*(w_lms_BF(:, i)); %Noise power
        %     Psout = (w_lms_BF(:, i))'*Rv1_in*(w_lms_BF(:, i)); %Output signal power
        %     Piout = (w_lms_BF(:, i))'*Rv2_in*(w_lms_BF(:, i)); %Interference power
        %     SNR_out_lms_BF(i) = Psout/(Pn+Piout);
        %     SNR_out_lms_BF(i) = 10 * log10(real(SNR_out_lms_BF(i)));
        
        
        % MMSE BF:
        P1_mmse_BF = sum(abs(fft(chOut1_mmse_BF(:, i))).^2);
        P2_mmse_BF = sum(abs(fft(chOut2_mmse_BF(:, i))).^2);
        P3_mmse_BF = sum(abs(fft(chOut3_mmse_BF(:, i))).^2);
        P4_mmse_BF = sum(abs(fft(chOut4_mmse_BF(:, i))).^2);
        Ptot_mmse_BF = sum(abs(fft(chOut_mmse_BF(:, i))).^2);
        P_noise_mmse_BF = sum(abs(fft(noise_mmse_BF(:, i))).^2);
        SNR_out_mmse_BF(i) = P1_mmse_BF / (P2_mmse_BF + P3_mmse_BF + P4_mmse_BF + P_noise_mmse_BF);
        SNR_out_mmse_BF(i) = 10 * log10(SNR_out_mmse_BF(i));
        
        %     Pn = (w_mmse_BF(:, i))'*Rn*(w_mmse_BF(:, i)); %Noise power
        %     Psout = (w_mmse_BF(:, i))'*Rv1_in*(w_mmse_BF(:, i)); %Output signal power
        %     Piout = (w_mmse_BF(:, i))'*Rv2_in*(w_mmse_BF(:, i)); %Interference power
        %     SNR_out_mmse_BF(i) = Psout/(Pn+Piout);
        %     SNR_out_mmse_BF(i) = 10 * log10(real(SNR_out_mmse_BF(i)));
    end
    
    %% Plotting results
    
    subplot(2,2,k+1)
    
    plot(Pars.SNR, SNR_out_simple_BF, '-*','Color','k','LineWidth', 2,'MarkerSize',10);
    % pause();
    
    hold on;
    plot(Pars.SNR, SNR_out_nulling_BF,'-+','Color','r','LineWidth', 2, 'MarkerSize',5);
    % pause();
    
    hold on;
    plot(Pars.SNR, SNR_out_mvdr_BF, '-x','Color','b','LineWidth', 2, 'MarkerSize',3);
    % pause();
    
    hold on;
    plot(Pars.SNR, SNR_out_lms_BF, '-s','Color','g','LineWidth', 2, 'MarkerSize',2);
    % pause();
    
    hold on;
    plot(Pars.SNR, SNR_out_mmse_BF, '-o','Color','m','LineWidth', 2, 'MarkerSize',1);
    
    xlabel('Input SNR');
    ylabel('Output SNR (after BF)');
    legend('simple BF', 'null-steering BF', 'MVDR BF', 'LMS BF', 'MMSE BF', 'LineWidth', 2);
    title(sprintf('Input - Output SNR comparison, Ninterf = %d',N_interf) , 'LineWidth', 16);
    grid on;
    xlim([0 9])
    ylim([4 22])
     
    
end

set(0,'DefaultTextFontSize',18)
set(0,'DefaultLineLineWidth',2);
%set(0,'DefaultTextInterpreter','latex')
set(0,'DefaultAxesFontSize',16)

channel = PlotScenario_SNR(Geometry);
saveas(channel,'Scenario_cirle.png')





