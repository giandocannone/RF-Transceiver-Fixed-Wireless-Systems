%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parametric FWA Transceiver Model
% MATLAB/Simulink Simulation
%
% Copyright (c) 2026 Giandomenico Cannone
% Dual-License: Apache 2.0 (non-commercial) / Commercial License
%
% Fingerprint: UUID: 7f1e3b92-0c4f-4b3a-9b76-f6d2dce5c111
% SHA256 Release Hash: 4d2f3a9b7c1d5e6f8a9b0c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f
%
% Author: Giandomenico Cannone
% Email: giandocannone@gmail.com
% LinkedIn: https://www.linkedin.com/in/giandocannone
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
close all
clc

%% ==========================================================
%%  SYSTEM PARAMETER (DYNAMISCH)
%% ==========================================================

M  = 256;                  % Modulationsordnung
k  = log2(M);              % Bits pro Symbol

BW_channel = 224e6;        % Kanalbandbreite [Hz]
rolloff     = 0.25;        % Rolloff Faktor der RRC Filter
span        = 6;          % Filterspan in Symbolen
%% Symbolrate automatisch aus Bandbreite + Roll-off

schnell_flag = 0;

Rs = BW_channel / (1 + rolloff);  % Symbolrate [Symbole/s]
Rb = k * Rs;                          % Bitrate
sps = 2;                   % Samples per Symbol
if schnell_flag == 1
    Fs  = 1*sps;            % Sample Rate
    Ts  = 1/Fs;                % Sample Time
else        
    Fs  = Rs * sps;            % Sample Rate
    Ts  = 1/Fs;                % Sample Time
end

%% ==========================================================
%%  FILTER / RRC
%% ==========================================================

% Bandbreite für RRC Filter (Hz)
BW_signal = Rs * (1 + rolloff);  % Damit passt die RRC-Bandbreite in Kanalbandbreite

% Beispiel für MATLAB RRC Filter Koeffizienten:
% rrc_tx = rcosdesign(rolloff, span, sps, 'sqrt');
% rrc_rx = rcosdesign(rolloff, span, sps, 'sqrt');

%% ==========================================================
%%  TARGET BER UND SNR BERECHNUNG (praktisch für M-QAM)
%% ==========================================================

target_BER = 1e-4;     % gewünschte BER

% Q-inverse Funktion
Qinv = @(p) sqrt(2)*erfcinv(2*p);

% Faktor für Gray-coded M-QAM
factor = (4/k)*(1 - 1/sqrt(M));
if factor >= 1
    factor = 0.999;  % Numerische Stabilität
end

% Berechnung Eb/N0
EbN0_lin = ((Qinv(target_BER/factor)).^2) * (M-1)/(3*k);
EbN0_dB = 10*log10(EbN0_lin);

% Symbolenergie Es/N0
EsN0_dB = EbN0_dB + 10*log10(k);

% SNR pro Sample (inkl. sps)
SNR_sample_dB = EsN0_dB - 10*log10(sps);

%% Ausgabe
fprintf('Modulation: %g-QAM\n', M);
fprintf('Channel Bandwidth: %.2f MHz\n', BW_channel/1e6);
fprintf('Target BER: %.1e\n', target_BER);
fprintf('Eb/N0 [dB]: %.2f\n', EbN0_dB);
fprintf('Es/N0 [dB]: %.2f\n', EsN0_dB);
fprintf('SNR per Sample [dB]: %.2f\n', SNR_sample_dB);

%% ----------------- Sample per Frame -----------------
% Anzahl Symbole pro Frame (z.B. 16000)
Nsym_frame = 300;  
spf = Nsym_frame * k;  % Bits pro Frame (für Random Integer Block)

%% ----------------- RRC Filter Parameter -----------------
rrc_span   = span;        % in Symbolen
rrc_rolloff= rolloff;     

%% ----------------- Für Simulink-Blöcke -----------------
simulink_params = struct();
simulink_params.M         = M;
simulink_params.k         = k;
simulink_params.Rs        = Rs;
simulink_params.sps       = sps;
simulink_params.spf       = spf;
simulink_params.EbN0_dB   = EbN0_dB;
simulink_params.EsN0_dB   = EsN0_dB;
simulink_params.SNR_sample_dB = SNR_sample_dB;
simulink_params.rrc_span  = rrc_span;
simulink_params.rrc_rolloff = rrc_rolloff;
simulink_params.Nsym_frame = Nsym_frame;
% Hidden fingerprint (nicht für Simulation relevant)
simulink_params.FingerprintID = 'FWA-UUID-7f1e3b92-0c4f-4b3a-9b76-f6d2dce5c111';

% Speichern als .mat für Simulink-Parameter
save('simulink_params.mat','-struct','simulink_params');



%% ==========================================================
%% RELATIVE TX-POWER FÜR EINE MODULATION (M-QAM)
%% ==========================================================


%% -----------------------
%% Zufällige Symbole erzeugen
%% -----------------------
data_test = randi([0 M-1], Nsym_frame, 1);

%% -----------------------
%% M-QAM Modulation (relativ, UnitAveragePower = true)
%% -----------------------
txSymbols = qammod(data_test, M, 'UnitAveragePower', true);

%% -----------------------
%% RRC Transmit Filter anwenden
%% -----------------------
rrc_tx = rcosdesign(rolloff, span, sps, 'sqrt');
% Fingerprint Marker: FWA-RRC-2026-GC-001
txUpsampled = upsample(txSymbols, sps);
txFiltered = conv(txUpsampled, rrc_tx, 'same');

%% -----------------------
%% Relative TX-Leistung berechnen
%% -----------------------
TX_Power = mean(abs(txFiltered).^2);  % Relative Leistung pro Sample

fprintf('M = %d QAM: Relative TX-Power nach RRC Filter = %.4f\n', M, TX_Power);

% %% -----------------------
% %% Für Simulink speichern
% %% -----------------------

simulink_params.TX_Power = TX_Power;

save('simulink_params.mat','-struct','simulink_params');

%% DAC Parameter

DAC_Bits = 12;
DAC_levels = 2^DAC_Bits;

DAC_Vmax = 0.5;
DAC_Vmin = -DAC_Vmax;

DAC_delta = (DAC_Vmax - DAC_Vmin) / DAC_levels;

%% DAC RMS Voltage

V_dac_rms = DAC_Vmax / sqrt(2);

R = 50;

P_out_RMS = V_dac_rms^2 / R;
P_out_dBm = 10*log10(P_out_RMS/1e-3);

fprintf('Expected DAC Power: %.3f mW (%.2f dBm)\n',P_out_RMS*1e3,P_out_dBm);

%% Relative TX Power after RRC

TX_Power = mean(abs(txFiltered).^2);

V_norm_rms = sqrt(TX_Power);

fprintf('Normalized RMS after RRC: %.4f\n',V_norm_rms);

% Required DAC Gain

Gain_DAC = V_dac_rms / sqrt(TX_Power);

fprintf('Gain_DAC for Simulink Gain Block: %.4f\n',Gain_DAC);



%% VGA
K_LG = 0.02;
alpha_LG = 0.001;

%% Power Amplifier Parameter (Datenblatt-basierte Berechnung)
% -------- TX-Leistung (physikalisch vom PA) --------
P_TX_W = 2;                         % <-- hier reale PA-Leistung einsetzen
P_TX_dBm = 10*log10(P_TX_W*1e3);    % Watt → dBm

% Linear Gain
Gain_Tx_dB = 24;

Z0 = 50;  % Ohm

% 1️⃣ Typischer PAPR je Modulation
switch M
    case 16
        PAPR_dB = 6;
    case 64
        PAPR_dB = 7;
    case 256
        PAPR_dB = 8;
    case 1024
        PAPR_dB = 9;
    case 2048
        PAPR_dB = 9.5;
    case 4096
        PAPR_dB = 10;
    otherwise
        PAPR_dB = 6;  % konservativer Default
end

% 2️⃣ PA Parameter aus Datenblatt
P1dB_dBm = 20;      % aus PA-Datenblatt
OIP3_dBm  = P1dB_dBm + 10;     % aus PA-Datenblatt

% 3️⃣ Peakleistung der Modulation berechnen
P_peak_dBm = P_TX_dBm + PAPR_dB;  % Peak des Signals vor PA
P_peak_W = 10^(P_peak_dBm/10)/1000;  % Peak in Watt

% 4️⃣ Backoff berechnen relativ zu P1dB
Backoff_dB = P1dB_dBm - P_peak_dBm;  
% Wenn Backoff <0 → Peak überschreitet P1dB → nichtlinear
% Optional: in Simulation auf Mindestwert setzen
if Backoff_dB < 0
    warning('Peak liegt über P1dB! Nichtlinearität unvermeidbar.');
end

% 5️⃣ OIP3-Margin
OIP3_margin_dB = OIP3_dBm - (P_TX_dBm + 10); % 10 dB als typische QAM-Anforderung

% Cubic-Koeffizienten berechnen
a1 = 10^(Gain_Tx_dB/20);               % Linearer Gain V/V
P1dB_W = 10^(P1dB_dBm/10)/1000;      
A_1dB = sqrt(P1dB_W*Z0);               % Spannung bei P1dB
a3 = a1*(10^(-1/20)-1)/A_1dB^2;        % Cubic-Term für 1dB-Kompression

% % 6️⃣ Rapp-Modell Parameter (AM/AM)

V_sat = sqrt(P_peak_W * Z0);   % Output Saturation Level (V)
p_smooth = 3;                  % Magnitude Smoothness Factor
phase_gain = 0.02;             % minimale Phase-Korrektur
phase_sat = 0.02;              % minimale Phase-Sättigung
phase_smooth = 1.5;            % Phase Smoothness Factor

% 7️⃣ Ausgabe
fprintf('Modulation: %d-QAM\n', M);
fprintf('PAPR: %.1f dB\n', PAPR_dB);
fprintf('PA Peak Power: %.1f dBm\n', P_peak_dBm);
fprintf('PA 1dB Compression: %.1f dBm\n', P1dB_dBm);
fprintf('Backoff: %.1f dB\n', Backoff_dB);
fprintf('OIP3: %.1f dBm\n', OIP3_dBm);
fprintf('OIP3 Margin: %.1f dB\n', OIP3_margin_dB);

fprintf('\nRapp-PA Parameter für Simulink:\n');
fprintf('Linear Gain (dB): %.1f dB\n', Gain_Tx_dB);
fprintf('Output Saturation Level (V): %.2f V\n', V_sat);
fprintf('Magnitude Smoothness Factor: %.1f\n', p_smooth);
fprintf('Phase Gain (rad): %.2f\n', phase_gain);
fprintf('Phase Saturation (rad): %.2f\n', phase_sat);
fprintf('Phase Smoothness Factor: %.1f\n', phase_smooth);

%% DPD
% DPD-Parameter
Memory = 1;          % z.B. 1 Memory-Tap
numOrders = 3;       % Cubic Term
mu_DPD = 1e-5;       % Schrittweite LMS

% -----------------------------
% PA / DPD Fingerprint Marker
% Fingerprint: FWA-PA-DPD-2026-GC-002
% -----------------------------

% Initialisierung der DPD-Koeffizienten (komplex)
a1_init = complex(10^(Gain_Tx_dB/20));               
a3_init = complex(a1_init*(10^(-1/20)-1)/A_1dB^2);
% Initial coefficients
N_coef = numOrders*(Memory+1);


A = linspace(0,1.5,2000);
x = A .* exp(1j*0);

% PA Parameter
a1 = 10^(Gain_Tx_dB/20);

P1dB_W = 10^(P1dB_dBm/10)/1000;
A_1dB = sqrt(P1dB_W*Z0);

a3 = a1*(10^(-1/20)-1)/A_1dB^2;

% Initialisierung c_init [numOrders x (Memory+1)]

c_init = complex(zeros(N_coef,1)); 
% Linear-Term: aktuelles Sample
c_init(1) = complex(1);        % linear für n=0, m=0

% Cubic-Term: aktuelles Sample
c_init(2) = complex(-a3/(a1^3));

% Quintic-Term: optional 0
c_init(3) = complex(0);

% Memory-Term: verzögertes Sample
% m=1
c_init(4) = complex(0);  % linear verzögert
c_init(5) = complex(0);  % cubic verzögert
c_init(6) = complex(0);  % quintic verzögert

%% PA
y_pa = a1*x + a3*abs(x).^2 .* x;

% DPD Koeffizienten
b1 = 1;
b3 = -a3/a1;

% DPD
x_dpd = b1*x + b3*abs(x).^2 .* x;

% PA nach DPD
y_dpd_pa = a1*x_dpd + a3*abs(x_dpd).^2 .* x_dpd;

% Plot
figure
plot(abs(x),abs(y_pa),'LineWidth',2)
hold on
plot(abs(x),abs(y_dpd_pa),'LineWidth',2)
grid on

xlabel('Input Amplitude')
ylabel('Output Amplitude')

legend('PA','DPD + PA')
title('AM-AM Characteristic')
%% Kanalparameter


c = 3e8;                % Lichtgeschwindigkeit
d = 7000;                % Distanz in Meter
fc = 42e9;            % Trägerfrequenz


%% ==========================================================
%% LINK BUDGET + ERFORDERLICHE NF + RECEIVER SENSITIVITY
%% ==========================================================



%% -------- Antennengewinne --------
G_TX_dBi = 35;     % TX Antenne (typisch 30–45 dBi bei 42 GHz)
G_RX_dBi = 35;     % RX Antenne

L_sys_dB = 0;      % optionale Systemverluste (Kabel etc.)

%% -------- Bitrate & benötigtes SNR --------

SNR_req_dB = EbN0_dB + 10*log10(Rb/BW_channel);

%% -------- Freiraumdämpfung --------
FSPL_dB = 20*log10(d) + 20*log10(fc) + 20*log10(4*pi/c);
path_gain_lin = 10^(-FSPL_dB/20);   % Amplitudenfaktor

%% ====================== FREQUENZABHÄNGIGE DÄMPFUNG ======================

% -------- Path & Frequency --------
d_m        = d;                % Distanz in m
d_km        = d/1000;                % Distanz in m
fc_Hz      = fc; % Carrier freq
fc_GHz     = fc_Hz/1e9;
range_km   = d_m/1000;         % für gaspl & rainpl

% -------- Thermodynamic Standardwerte --------
T_C      = 20;   % Temperatur [°C]
P_hPa    = 1013e2; % Luftdruck [Pa]
rho_gm3  = 7.5;  % Wasserdampf Dichte [g/m³]


%% -------- Gasabsorption mittels ITU-R P.676 --------
L_gas_dB = gaspl(d, fc_Hz, T_C, P_hPa, rho_gm3);

%% -------- Regenabsorption mittels ITU-R P.838 --------
regen_flag = 0;

if regen_flag == 1

    R_mm_per_h = 25;       % starke Regenrate
    elev_deg   = 0;         % Elevation 0° 
    tau_deg    = 0;         % Tilt Polarisation 0°
    pct        = 0.01;      % 0.01 % exceedance
    
    L_rain_dB = rainpl(d, fc_Hz, R_mm_per_h, elev_deg, tau_deg, pct);
else
    L_rain_dB = 0;
end


%% -------- Ausgabe ----------
fprintf('Gas Absorption bei %.2f GHz: %.2f dB\n', fc_GHz    , L_gas_dB);
fprintf('Regen Absorption bei %.2f GHz: %.2f dB\n', fc_GHz    , L_rain_dB);
fprintf('Gesamtdämpfung (Gas + Regen) : %.2f dB\n', L_gas_dB + L_rain_dB);

% -------- Gesamtpfaddämpfung --------
L_total_dB = FSPL_dB + L_gas_dB + L_rain_dB + L_sys_dB;

% -------- Empfangsleistung --------
P_RX_dBm = P_TX_dBm + G_TX_dBi + G_RX_dBi - L_total_dB;


%% -------- Thermisches Rauschen --------
N_thermal_dBm = -174 + 10*log10(BW_channel);


%% ==========================================================
%% AUSGABE
%% ==========================================================

fprintf('\n================ LINK BUDGET ================\n');
fprintf('TX Power: %.2f dBm\n', P_TX_dBm);
fprintf('FSPL: %.2f dB\n', FSPL_dB);
fprintf('RX Power: %.2f dBm\n', P_RX_dBm);
fprintf('Thermal Noise: %.2f dBm\n', N_thermal_dBm);
fprintf('Required SNR: %.2f dB\n', SNR_req_dB);
fprintf('=============================================\n');



%% ADC Parameter

ADC_Bits = 10;                 % ADC resolution
                 
ADC_levels = 2^ADC_Bits;       

% Quantizer limits
ADC_Vmax =  1; % Full scale peak (±1 V)
ADC_Vmin = -1; % Full scale peak (±1 V)

ADC_delta  = (ADC_Vmax - ADC_Vmin) / ADC_levels;

% Sampling
ADC_fs = Fs;  % 160 MHz in deinem Fall

% ADC Quantization Noise
Pq = (ADC_delta^2)/12;
Pq_dBm = 10*log10(Pq/1e-3);

% ADC SNR
SNR_ADC = 6.02*ADC_Bits + 1.76;

% RX-Spannung vor Verstärker (über R Ohm Last)
% R = 50; % R=1 Ohm
P_rx_Watt = 10.^((P_RX_dBm-30)/10);

target_rms = 0.25*ADC_Vmax;

V_rx_rms  = sqrt(P_rx_Watt * R);
V_rx_peak = sqrt(2) * V_rx_rms;

margin = 3;   % ADC degradation margin

% Verstärkungsfaktor für ADC
Gain_rx_linear = target_rms / V_rx_rms;
Gain_rx_dB = 20*log10(Gain_rx_linear);

%% -------- Erforderliche Noise Figure --------
NF_required_dB = P_RX_dBm - N_thermal_dBm - (SNR_req_dB + margin);

%% -------- Receiver Sensitivity --------
Sensitivity_dBm = N_thermal_dBm + NF_required_dB + SNR_req_dB + margin;

%% Optional: in Simulink-Parameter speichern
simulink_params.P_TX_dBm = P_TX_dBm;
simulink_params.P_RX_dBm = P_RX_dBm;
simulink_params.SNR_req_dB = SNR_req_dB;
simulink_params.NF_required_dB = NF_required_dB;
simulink_params.Sensitivity_dBm = Sensitivity_dBm;

save('simulink_params.mat','-struct','simulink_params');

%% Ausgabe 
fprintf('\n===== ADC DESIGN =====\n');
fprintf('ADC SNR: %.2f dB\n', SNR_ADC);
fprintf('Quantization Noise: %.2f dBm\n', Pq_dBm);
fprintf('ADC Input Range: [%g, %g] V\n', ADC_Vmin, ADC_Vmax);
fprintf('ADC Resolution: %d Bits\n', ADC_Bits);
fprintf('Spannung pro LSB: %.6f V\n', ADC_delta);
fprintf('Maximale Peak-Spannung: %.3f V\n', ADC_Vmax);

fprintf('\n===== LNA =====\n');
fprintf('RX Peak Voltage: %.6f V\n', V_rx_peak);
fprintf('Benötigter RX Gain: %.2f (linear), %.2f dB\n', Gain_rx_linear, Gain_rx_dB);
fprintf('Maximale NF: %.2f dB\n', NF_required_dB);

% %% =========================================
% %% MAXIMALE LINK DISTANZ
% %% =========================================
% P_tx = P_TX_dBm;
% G_tx = G_TX_dBi;
% G_rx = G_RX_dBi;
% 
% NF = NF_required_dB;
% 
% SNR_req = SNR_req_dB;
% 
% %% Thermal Noise
% N_thermal = -174 + 10*log10(BW_channel);
% 
% %% maximale erlaubte Path Loss
% L_max = P_tx + G_tx + G_rx - (N_thermal + NF + SNR_req);
% 
% fprintf('\n===== LINK MARGIN =====\n');
% fprintf('Max erlaubte Path Loss: %.2f dB\n', L_max);
% 
% d_vect = linspace(100,20000,500); % 0.1 km – 20 km
% SNR_vec = zeros(1,length(d_vect));
% for i = 1:length(d_vect)
%     FSPL = 20*log10(d_vect(i)) + 20*log10(fc) + 20*log10(4*pi/c);
%     L_gas = gaspl(d_vect(i), fc, T_C, P_hPa, rho_gm3);
%     if regen_flag == 1
% 
%         R_mm_per_h = 25;       % starke Regenrate
%         elev_deg   = 0;         % Elevation 0° 
%         tau_deg    = 0;         % Tilt Polarisation 0°
%         pct        = 0.01;      % 0.01 % exceedance
% 
%         L_rain = rainpl(d_vect(i), fc_Hz, R_mm_per_h, elev_deg, tau_deg, pct);
%     else
%         L_rain = 0;
%     end
%     L_total = FSPL + L_gas + L_rain;
%     P_rx = P_tx + G_tx + G_rx - L_total;
%     SNR = P_rx - (N_thermal + NF);
%     SNR_vec(i) = SNR;
% end
% 
% idx = find(SNR_vec < SNR_req,1);
% 
% d_link_max = d_vect(idx);
% 
% fprintf('\n===== MAXIMALE DISTANZ =====\n');
% fprintf('Max Distance: %.2f km\n', d_link_max/1000);



%% ======================================
%% MODULATOR
%% ======================================
gainI_TX_dB = 0.5;        % TX Gain Fehler I-Kanal [dB]
gainQ_TX_dB = 0.5;        % TX Gain Fehler Q-Kanal [dB]
phaseMismatch_TX_deg = 1; % TX Phase Mismatch [deg]
LO_leakage_TX_dB = -35;   % TX LO-Leakage [dB]
PN_TX_std_deg = 0.01;      % TX Phase Noise RMS [deg]

%% ======================================
%% DEMODULATOR
%% ======================================
% IQ Correction gebraucht
gainI_RX_dB        = 0;       % RX Gain Fehler I-Kanal
gainQ_RX_dB        = 0.5;     % RX Gain Fehler Q-Kanal
phaseMismatch_RX_deg = 1;     % RX Phase Mismatch
LO_leakage_RX_dB   = -30;     % RX LO-Leakage
PN_RX_std_deg      = 0.01;    % RX RMS Phase Noise
freq_offset_Hz = 50; % Frequenzfehler zwischen IQ-Modulator und -Demodulator

alpha = 1e-5; % DC Removal gebraucht
mu = 5e-4;
% -----------------------------
% Parameter
% -----------------------------
alpha_PN = 3e-3;  % Loop Gain (anpassbar für QAM)
beta_PN = 1e-5;   % Low-pass Gewicht für Phase Noise Glättung
% pilot_val = 0+0j;         % Pilotsymbol
pilots = [1+1j, -1+1j, -1-1j, 1-1j];  % echte Pilot-Symbole
pilot_spacing = 20;    % Abstand der Piloten

clear DD_PLL_CPR_Hybrid_Block

%% ======================================
%% DISTANCE vs BER SWEEP
%% ======================================
% 
% model = 'QAM_HF_Modell_Beispiel1';   % Modellname
% 
% distances = linspace(1000,15000,15);  % 1 km – 15 km
% 
% BER = zeros(size(distances));
% SNR = zeros(size(distances));
% % 
% for i = 1:length(distances)
% 
%     d = distances(i);
% 
%     assignin('base','d',d);
% 
%     simOut = sim(model,'StopTime','0.02');
% 
%     BER(i) = simOut.logsout.get('BER').Values.Data(end);
% 
% end
% 
% figure
% 
% semilogy(distances/1000, BER,'o-','LineWidth',2)
% 
% xlabel('Distance [km]')
% ylabel('BER')
% 
% grid on
% title('1024-QAM Link Performance')

