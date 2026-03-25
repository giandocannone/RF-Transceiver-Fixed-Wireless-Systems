# Parametric Fixed Wireless Access (FWA) Transceiver Model

## 📊 Project Overview

A **comprehensive, frequency-agnostic MATLAB/Simulink model** for point-to-point Fixed Wireless Access (FWA) systems. The simulator supports **configurable carrier frequencies from 5.9 GHz to mmWave**, enabling realistic RF transceiver modeling with advanced digital signal processing for **M-QAM modulation** (up to 1024-QAM).

This project demonstrates enterprise-grade RF system design suitable for:
- **5G/6G Backhaul** (28 GHz, 39 GHz, 73 GHz)
- **Sub-6 GHz FWA** (5.9 GHz, 3.5 GHz)
- **mmWave Point-to-Point Links** (28–100 GHz)
- **Microwave Backhaul** (6–43 GHz)
- **Proprietary Wireless Systems**

---

## ✨ Key Features

### 🎯 Fully Parametric System Design
- **Carrier Frequency:** User-configurable (5.9 GHz to 100+ GHz)
- **Channel Bandwidth:** Adjustable (14 MHz to 224 MHz, 250 MHz to 1+ GHz)
- **Modulation Schemes:** 4-QAM, 16-QAM, 64-QAM, 256-QAM, 1024-QAM (scalable)
- **Link Distance:** Configurable (100 m to 100+ km)
- **Antenna Gains:** User-defined TX/RX gains
- **Environmental Models:** Gas absorption, rain attenuation (ITU standards)

### 📡 Transmitter (TX) Path
- **Flexible Data Generation:** Random bit streams, configurable frame sizes
- **M-QAM Modulation:** Unit average power normalization
- **Root-Raised-Cosine (RRC) Filtering:** Configurable span & rolloff
- **Digital Predistortion (DPD):** Adaptive cubic polynomial correction
- **DAC Quantization:** Configurable bit resolution
- **Variable Gain Amplifier (VGA):** Dynamic gain control
- **Power Amplifier (PA) Model:** 
  - Cubic nonlinearity with AM/AM & AM/PM
  - Backoff calculation & P1dB compression
- **IQ Modulation:** Frequency-agnostic to arbitrary carrier

### 🌍 Channel Model (Parametric)
- **Free-Space Path Loss (FSPL):** Frequency-dependent
- **Atmospheric Gas Absorption:** ITU-R P.676 standard
- **Rain Attenuation Model:** ITU-R P.838 (optional, configurable rate)
- **AWGN with SNR Control:** Link budget-based SNR injection (extensible)
- **Fading Support:** Framework for Rayleigh/Rician fading (extensible)

### 📡 Receiver (RX) Path
- **Low Noise Amplifier (LNA):** Configurable gain & noise figure
- **Automatic Gain Control (AGC):** Adaptive amplitude normalization
- **ADC Quantization:** Configurable bit resolution & full-scale range
- **DC Offset Removal:** Adaptive IQ baseband correction
- **RRC Matched Filtering:** Matched to TX filter
- **IQ Imbalance Correction:** 
  - Gain mismatch (I/Q channels)
  - Phase mismatch compensation
  - LO leakage correction
- **Phase Tracking (EKF-based CPR):** Extended Kalman Filter for carrier recovery
- **Frequency Offset Correction:** Dynamic synchronization
- **M-QAM Demodulation:** Hard or soft decisions

### 📊 Performance Metrics
- **Bit Error Rate (BER):** Real-time measurement
- **Symbol Error Rate (SER):** Per-modulation tracking
- **Link Budget Analysis:** Sensitivity, SNR requirements, margins
- **Spectral Efficiency:** Bits per second per Hz (under construction)
- **Error Vector Magnitude (EVM):** Constellation quality assessment (under construction)

---

## 📈 Supported Configurations

### Frequency Bands
| Band | Typical Use Case | Supported in Model |
| :--- | :--- | :--- |
| **5.9 GHz** | Sub-6 FWA, DSRC | ✅ Yes |
| **6 GHz** | WiFi 6E Backhaul | ✅ Yes |
| **28 GHz** | 5G mmWave, Backhaul | ✅ Yes |
| **39 GHz** | E-Band Backhaul | ✅ Yes |
| **43 GHz** | Point-to-Point Links | ✅ Yes |
| **73 GHz** | 5G/6G Backhaul | ✅ Yes |
| **100+ GHz** | 6G Research | ✅ Yes (Extensible) |

### Modulation Support
| Modulation | Order | Typical Use | Status |
| :--- | :--- | :--- | :--- |
| **4-QAM** | 2 bits/symbol | Legacy systems | ✅ Converged |
| **16-QAM** | 4 bits/symbol | Robust links | ✅ Converged |
| **64-QAM** | 6 bits/symbol | Standard FWA | ✅ Converged |
| **256-QAM** | 8 bits/symbol | High spectral eff. | ✅ Converged |
| **1024-QAM** | 10 bits/symbol | Premium capacity | ✅ Converged |
| **2048-QAM** | 11 bits/symbol | Premium capacity | ✅ Tested |


### Link Scenarios
| Distance | Attenuation Model | Notes |
| :--- | :--- | :--- |
| **< 1 km** | FSPL only | Indoor/short-range |
| **1–10 km** | FSPL + Gas | Typical FWA backhaul |
| **10–50 km** | FSPL + Gas + Rain | Long-distance links |
| **50+ km** | Extended propagation | Research/specialized |

---

## 🛠️ Installation & Quick Start

### Requirements
- **MATLAB** R2024a or later
- **Simulink** (core simulation engine)
- **Communications Toolbox** (M-QAM, RRC, modulation)
- **Signal Processing Toolbox** (filtering, DSP blocks)
- **Optional:** RF Toolbox (advanced RF analysis)

## 📋 License

This project is **dual-licensed** under a **Non-Commercial / Commercial model**:

### ✅ Free (Non-Commercial / Academic)
You may use, modify, and distribute this project **only for non-commercial purposes**:

- Academic research and education  
- Non-profit projects  
- Community contributions

**Key conditions:**
- Retain copyright notice and license
- Include the LICENSE file with redistributions
- Modifications must be clearly marked

See [LICENSE](./LICENSE) for full terms.

---

### 💼 Commercial License
For **any commercial use**, including but not limited to:

- Proprietary products or software  
- Commercial services or consulting  
- Industrial applications  
- Redistribution or licensing for profit

You **must obtain a separate commercial license** from the author.

**Contact for commercial licensing:**

- **📧 Email:** giandocannone@gmail.com  
- **🔗 LinkedIn:** [linkedin.com/in/giandocannone](https://www.linkedin.com/in/giandocannone)

> Commercial licensing terms are negotiable and customized per use case.

## 👤 Author

**[Giandomenico Cannone]**
- 🎓 [Master Degree in Telecommunication Engineering / RF, Microwave and mmWave Engineering]
- 💼 RF/Wireless Systems Engineer, Project Manager, Product Manager, Data Analyst
- 🔬 Focus: RF, Microwave and mmWave systems and components, data analysis

Questions or collaboration opportunities? Get in touch!


### FWA-Transceiver-Model/
├── README.md                              # This documentation
├── LICENSE                                # Dual license (Apache 2.0 + Commercial)
├── .gitignore                             # MATLAB ignore rules
├── QAM_Bewertung_System_Parameter.m       # ← EDIT THIS for different scenarios
└── QAM_HF_Modell_Beispiel1.slx            # Simulink model (frequency-agnostic)


```matlab
- ### Step 1: Initialize System Parameters

% Navigate to project directory
cd /path/to/your/FWA-Transceiver

% Run parameter initialization
run('QAM_Bewertung_System_Parameter.m')

% This generates: simulink_params.mat
% Contains all system configuration parameters

M                   % Modulation order (16, 64, 256, 1024)
k                   % Bits per symbol (auto-calculated: log2(M))
BW_channel          % Channel bandwidth [Hz]
rolloff             % RRC rolloff factor (typical: 0.2-0.3)
span                % RRC filter span in symbols
sps                 % Samples per symbol (typical: 2-4)
Fs                  % Sampling frequency [Hz] (auto-calculated)

fc                  % Carrier frequency [Hz]
d                   % Link distance [meters]
c                   % Speed of light [m/s] (3e8)

G_TX_dBi            % TX antenna gain [dBi]
G_RX_dBi            % RX antenna gain [dBi]
L_sys_dB            % System losses (cables, connectors) [dB]

P_TX_W              % TX power [Watts]
Gain_Tx_dB          % PA linear gain [dB]
P1dB_dBm            % PA 1dB compression point [dBm]
OIP3_dBm            % PA OIP3 [dBm]
PAPR_dB             % Peak-to-Average Power Ratio [dB]
DAC_Bits            % DAC resolution (typical: 12)

ADC_Bits            % ADC resolution (typical: 10-12)
ADC_Vmax            % ADC full-scale voltage [V]
NF_required_dB      % Receiver Noise Figure [dB]

T_C                 % Temperature [°C]
P_hPa               % Air pressure [Pa]
rho_gm3             % Water vapor density [g/m³]
regen_flag          % Include rain? (0=No, 1=Yes)
R_mm_per_h          % Rain rate if enabled [mm/h]

% Frequency & Bandwidth
fc = 42e9;              % Carrier frequency [Hz] ← ADJUST HERE
BW_channel = 224e6;     % Channel bandwidth [Hz] ← ADJUST HERE

% Modulation
M = 256;                % Modulation order: 16, 64, 256, 1024 ← ADJUST HERE

% Link Parameters
d = 7000;               % Distance [meters] ← ADJUST HERE
G_TX_dBi = 35;          % TX antenna gain [dBi] ← ADJUST HERE
G_RX_dBi = 35;          % RX antenna gain [dBi] ← ADJUST HERE

% Environmental
regen_flag = 0;         % Include rain? (0=No, 1=Yes) ← ADJUST HERE

### Step 2: Initialize System Parameters

% Open Simulink model
open('QAM_HF_Modell_Beispiel1.slx')

% Run simulation (press Play button or use command line)
sim('QAM_HF_Modell_Beispiel1')

% View results in Simulink-Model:
% - BER (Bit Error Rate)
% - SER (Symbol Error Rate)




