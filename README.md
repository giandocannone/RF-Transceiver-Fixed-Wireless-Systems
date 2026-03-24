# RF-Transceiver-Fixed-Wireless-Systems
RF Transceiver Model with M-QAM Modulation (up to 1024).

TX Path:
├── [Random Integer] 
├── [Integer to Bit Converter]
├── [M-QAM Modulator]
├── [RRC Tx Filter]  
├── [Adaptive DPD] 
├── [DAC] 
├── [VGA Control] 
├── [IQ Modulator] 
├── [Cubic PA] 
├── [Tx Antenna Gain] 
├── [Path Loss]

RX Path:
├── [Rx Antenna Gain] 
├── [Cubic Poly]
├── [IQ Modulator]
├── [ADC] 
├── [DC Correction/Offset Removal] 
├── [RRC Rx Filter] 
├── [AGC] 
├── [IQ Imbalance Correction] 
├── [EKF Phase Tracking] 
├── [M-QAM Demodulator] 
├── [Error Rate Calculation] -
├── [Bit to Integer Converter] 
├── [Error Rate Calculation] 

## 📋 License

This project is **dual-licensed**:

### Free (Open Source)
✅ **Apache License 2.0** for non-commercial use
- Academic research and education
- Non-profit projects
- Community contributions

See [LICENSE](./LICENSE) file for full details.

### Commercial License
💼 For commercial use (products, services, consulting), contact:

**📧 Email:** giandocannone@gmail.com  
**🔗 LinkedIn:** [giandocannone](linkedin.com/in/giandocannone)
---

## 👤 Author

**[Giandomenico Cannone]**
- 🎓 [Master Degree in Telecommunication Engineering / RF, Microwave and mmWave Engineering]
- 💼 RF/Wireless Systems Engineer, Project Manager, Product Manager, Data Analyst
- 🔬 Focus: RF, Microwave and mmWave systems and components, data analysis

Questions or collaboration opportunities? Get in touch!
