close all
clear all
h=[2
-1
-1
1
-1
-2
2
1
-3
1
3
-4
0
5
-4
-3
8
-2
-7
9
2
-12
7
9
-16
2
18
-17
-9
28
-12
-26
37
3
-55
45
46
-128
49
538];

OFDMFilter = [ h ;flipdim(h,1)];
OFDMInterperlationFilter=[-5
0
30
0
-103
0
278
0
-697
0
2545
4096
2545
0
-697
0
278
0
-103
0
30
0
-5
];

BW = [1.25, 2.5, 5.0, 10.0, 15.0, 20.0]*1e6;
perecentage = (60.*BW).*(0.015./BW);
BWocc = perecentage.*BW;
T = 1/15e3;
Narray = [128 256 512 1024 1536 2048];
Nsubcarriersarray = [72 180 300 600 900 1200];
reference_case_rms   =1.5237;   % Speech 12.2Kbps AMR cubic reference value
                                        % equivalent to 20*log10(v_rms) for
                                      % the Speech case
OBW = perecentage.*BW./1e6;
OBW_ref = 3.84;
OBPD_All = 10*log10(OBW/OBW_ref);
K = 1.56;
NumberOfBlocks = 140;

Peak_to_mean_QPSK_dB = zeros(length(Narray),NumberOfBlocks);
Peak_to_mean_16QAM_dB = zeros(length(Narray),NumberOfBlocks);
Peak_to_mean_64QAM_dB = zeros(length(Narray),NumberOfBlocks);
Peak_to_mean_OFDM_QPSK_dB = zeros(length(Narray),NumberOfBlocks);
Peak_to_mean_OFDM_16QAM_dB = zeros(length(Narray),NumberOfBlocks);
Peak_to_mean_OFDM_64QAM_dB = zeros(length(Narray),NumberOfBlocks);
Peak_to_mean_SC_FDMA_QPSK_dB = zeros(length(Narray),NumberOfBlocks);
Peak_to_mean_SC_FDMA_16QAM_dB = zeros(length(Narray),NumberOfBlocks);
Peak_to_mean_SC_FDMA_64QAM_dB = zeros(length(Narray),NumberOfBlocks);
Non_Lin_Peak_to_mean_QPSK_dB = zeros(length(Narray),NumberOfBlocks);
Non_Lin_Peak_to_mean_16QAM_dB = zeros(length(Narray),NumberOfBlocks);
Non_Lin_Peak_to_mean_64QAM_dB = zeros(length(Narray),NumberOfBlocks);
Non_Lin_Peak_to_mean_OFDM_QPSK_dB = zeros(length(Narray),NumberOfBlocks);
Non_Lin_Peak_to_mean_OFDM_16QAM_dB = zeros(length(Narray),NumberOfBlocks);
Non_Lin_Peak_to_mean_OFDM_64QAM_dB = zeros(length(Narray),NumberOfBlocks);
Non_Lin_Peak_to_mean_SC_FDMA_QPSK_dB = zeros(length(Narray),NumberOfBlocks);
Non_Lin_Peak_to_mean_SC_FDMA_16QAM_dB = zeros(length(Narray),NumberOfBlocks);
Non_Lin_Peak_to_mean_SC_FDMA_64QAM_dB = zeros(length(Narray),NumberOfBlocks);
    
% for n = 2
    Frame_OFDM_QPSK = [];
    n = 2;
    
    OBPD = OBPD_All(n+1);
    N = Narray(n+1);
    SampleRate = N/T;
   Gp1 = SampleRate- BW(n+1);
   Gp2 = BW(n+1)-BWocc(n+1);
   GP = Gp1+Gp2;
   temp1 = BW(n+1)/2;
   temp2 = BWocc(n+1)/2;
   temp3 = SampleRate/2;
   measurments = [-temp1 temp1];
   measurments2 = [(temp1+GP) (temp1+GP)+BWocc(n+1)];
   measurments3 = [(temp1+GP) (temp1+GP)+BWocc(n+1)];
    Nsubcarriers = Nsubcarriersarray(n+1);
%     SubCarrierIndex = [2:Nsubcarriers/2 (Nsubcarriers/2:Nsubcarriers)+N-Nsubcarriers ];
    SubCarrierIndex = [-Nsubcarriers/2:-1 1: Nsubcarriers/2];
%     SubCarrierIndex = [-Nsubcarriers/2:Nsubcarriers/2-1];
    % W-CDMA
    Nwcdma = 256;
    SubCarrierIndex_W_CDMA = [-Nwcdma/2:Nwcdma/2-1];
    M = 4;
    [ k_QPSK, Es, Esnorm, Eb, Ebnorm, SymbArray_QPSK ] = GetSymbolArrayData( M );
    numBits_QPSK = k_QPSK*N;
    M = 16;
    [ k_16QAM, Es, Esnorm, Eb, Ebnorm, SymbArray_16QAM ] = GetSymbolArrayData( M );
    numBits_16QAM = k_16QAM*N;
    M = 64;
    [ k_64QAM, Es, Esnorm, Eb, Ebnorm, SymbArray_64QAM ] = GetSymbolArrayData( M );
    numBits_64QAM = k_64QAM*N;

    OversampleRate = 2;                                             % Oversample rate
    f = OversampleRate*SampleRate;
    alpha = 0.22;                                                   % Roll Of Rate
    truncation = 96;                                                % Truncation in respect to number of symbols
    [ InterperlationFilter ] = RaisedCosine( alpha, truncation ,OversampleRate );      % Interperlation Filter
    [Ipeak, index] = max(InterperlationFilter);
    index = index -1;
    
    Peak_to_mean_QPSK = zeros(1,NumberOfBlocks);
    Peak_to_mean_16QAM = zeros(1,NumberOfBlocks);
    Peak_to_mean_64QAM = zeros(1,NumberOfBlocks);
    Peak_to_mean_OFDM_QPSK = zeros(1,NumberOfBlocks);
    Peak_to_mean_OFDM_16QAM = zeros(1,NumberOfBlocks);
    Peak_to_mean_OFDM_64QAM = zeros(1,NumberOfBlocks);
    Peak_to_mean_SC_FDMA_QPSK = zeros(1,NumberOfBlocks);
    Peak_to_mean_SC_FDMA_16QAM = zeros(1,NumberOfBlocks);
    Peak_to_mean_SC_FDMA_64QAM = zeros(1,NumberOfBlocks);
    cubic_OFDM_QPSK = zeros(1,NumberOfBlocks);
    cubic_OFDM_16QAM = zeros(1,NumberOfBlocks);
    cubic_OFDM_64QAM = zeros(1,NumberOfBlocks);
    raw_cubic_metric_QPSK = zeros(1,NumberOfBlocks);
    raw_cubic_metric_16QAM = zeros(1,NumberOfBlocks);
    raw_cubic_metric_64QAM = zeros(1,NumberOfBlocks);
    WPD_QPSK = zeros(1,NumberOfBlocks);
    WPD_16QAM = zeros(1,NumberOfBlocks);
    WPD_64QAM = zeros(1,NumberOfBlocks);
    Non_Lin_Peak_to_mean_QPSK = zeros(1,NumberOfBlocks);
    Non_Lin_Peak_to_mean_16QAM = zeros(1,NumberOfBlocks);
    Non_Lin_Peak_to_mean_64QAM = zeros(1,NumberOfBlocks);
    Non_Lin_Peak_to_mean_OFDM_QPSK = zeros(1,NumberOfBlocks);
    Non_Lin_Peak_to_mean_OFDM_16QAM = zeros(1,NumberOfBlocks);
    Non_Lin_Peak_to_mean_OFDM_64QAM = zeros(1,NumberOfBlocks);
    Non_Lin_Peak_to_mean_SC_FDMA_QPSK = zeros(1,NumberOfBlocks);
    Non_Lin_Peak_to_mean_SC_FDMA_16QAM = zeros(1,NumberOfBlocks);
    Non_Lin_Peak_to_mean_SC_FDMA_64QAM = zeros(1,NumberOfBlocks);
    
    for i = 1:NumberOfBlocks
        % Generate Bits
        Bits_QPSK = rand(1,numBits_QPSK) > 0.5;
        Bits_16QAM = rand(1,numBits_16QAM) > 0.5;
        Bits_64QAM = rand(1,numBits_64QAM) > 0.5;

        % Generate Symbol Index
        [ Idx_QPSK, BlockSize ] = SymbolIndex( Bits_QPSK, k_QPSK );
        [ Idx_16QAM, BlockSize_16QAM ] = SymbolIndex( Bits_16QAM, k_16QAM );
        [ Idx_64QAM, BlockSize_64QAM ] = SymbolIndex( Bits_64QAM, k_64QAM );
 
        % Generate Symbols
        Symbols_QPSK = SymbArray_QPSK(Idx_QPSK);
        Symbols_16QAM = SymbArray_16QAM(Idx_16QAM);
        Symbols_64QAM = SymbArray_64QAM(Idx_64QAM);
        
        % W-CDMA
        WDCMAymbol_QPSK = zeros(1,N);
        WDCMASymbol_16QAM = zeros(1,N);
        WDCMASymbol_64QAM = zeros(1,N);
        
        % Map Symbols to Subcarrier
        WDCMAymbol_QPSK(SubCarrierIndex_W_CDMA+N/2+1) = Symbols_QPSK(1:Nwcdma);
        WDCMASymbol_16QAM(SubCarrierIndex_W_CDMA+N/2+1) = Symbols_16QAM(1:Nwcdma);
        WDCMASymbol_64QAM(SubCarrierIndex_W_CDMA+N/2+1) = Symbols_64QAM(1:Nwcdma);
        

        % Oversample
        OVA_QPSK = zeros(OversampleRate*N,1);
        OVA_16QAM = zeros(OversampleRate*N,1);
        OVA_64QAM = zeros(OversampleRate*N,1);

        OVA_QPSK(1:OversampleRate:end) = WDCMAymbol_QPSK;
        OVA_16QAM(1:OversampleRate:end) = WDCMASymbol_16QAM;
        OVA_64QAM(1:OversampleRate:end) = WDCMASymbol_64QAM;

        % Apply Interperation Filter
        Pulse_shapped_QPSK = conv(OVA_QPSK,InterperlationFilter);
        Pulse_shapped_16QAM = conv(OVA_16QAM,InterperlationFilter);
        Pulse_shapped_64QAM = conv(OVA_64QAM,InterperlationFilter);
        
% %         % Apply 2nd Interperation Filter
% %         Pulse_shapped_QPSK = conv(Pulse_shapped_QPSK,InterperlationFilter);
        
        BackOffdB = 0; 
        BackOffLin = 10.^(BackOffdB / 10);   
        
        PSfft = 20*log10(abs((fft(Pulse_shapped_QPSK./BackOffLin)*1/sqrt(length(Pulse_shapped_QPSK)))));
        F = 0:f/(length(Pulse_shapped_QPSK)-1):f;
%         F = 0:f/(length(ifft_Pulse_shapped_QPSK)-1):f;
        figure
        plot(F,PSfft)
        hold on
        
        % Amplifier Model
        [ AM_AM_QPSK, AM_PM_QPSK, CW_QPSK ] = AmplifierModel( Pulse_shapped_QPSK );
        [ AM_AM_16QAM, AM_PM_16QAM, CW_16QAM ] = AmplifierModel( Pulse_shapped_16QAM );
        [ AM_AM_64QAM , AM_PM_64QAM , CW_64QAM ] = AmplifierModel( Pulse_shapped_64QAM );
        
       
        CWfft = 20*log10(abs(fftshift(fft(CW_QPSK)*1/sqrt(length(CW_QPSK)))));
        plot(F,CWfft,'r')
        v = Pulse_shapped_QPSK./BackOffLin;
        w = CW_QPSK;
        e = abs(v-w).^2; 
        EVM = sqrt(mean(e)/mean(abs(v).^2))*100;

%         ChannelF = [-2.25 2.25];
%         [F1min F1] = min(abs(F-ChannelF(1)));
%         [F2min F2] = min(abs(F-ChannelF(2)));
%         ChannelPower = CWfft(F1:F2-1,1);
%         ChannelF = [3.84 3.84+4.5];
%         [F1min F1] = min(abs(F-ChannelF(1)));
%         [F2min F2] = min(abs(F-ChannelF(2)));
%         AddjacentChannel1 = CWfft(F1:F2-1,1);
%         ChannelF = [-4.5-3.84 -3.84];
%         [F1min F1] = min(abs(F-ChannelF(1)));
%         [F2min F2] = min(abs(F-ChannelF(2)));
%         AddjacentChannel2 = CWfft(F1:F2-1,1);
%  
%         % Addajacent Channel Power
%         
%         [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( ChannelPower );
%         chpXRMS = XRMS;
%         [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( AddjacentChannel1 );
%         addj1XRMS = XRMS;
%         [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( AddjacentChannel2 );
%         addj2XRMS = XRMS;
%         title(['EVM = ', num2str(EVM),'%', ' Channel Power = ', num2str(chpXRMS),'dB' ' adjacent Power 1 = -' num2str(addj1XRMS),'dB', ' adjacent Power 2 = -' num2str(addj2XRMS),'dB'])
%         
        
        % Calculate Peak to Mean Ration
        Peak_to_mean_QPSK(1,i) = max(abs(Pulse_shapped_QPSK).^2)/mean(abs(Pulse_shapped_QPSK).^2);
        Peak_to_mean_16QAM(1,i) = max(abs(Pulse_shapped_16QAM).^2)/mean(abs(Pulse_shapped_16QAM).^2);
        Peak_to_mean_64QAM(1,i) = max(abs(Pulse_shapped_64QAM).^2)/mean(abs(Pulse_shapped_64QAM).^2);
        
        % Non-Linear Model
        Non_Lin_Peak_to_mean_QPSK(1,i) = max(abs(CW_QPSK).^2)/mean(abs(CW_QPSK).^2);
        Non_Lin_Peak_to_mean_16QAM(1,i) = max(abs(CW_16QAM).^2)/mean(abs(CW_16QAM).^2);
        Non_Lin_Peak_to_mean_64QAM(1,i) = max(abs(CW_64QAM).^2)/mean(abs(CW_64QAM).^2);

        % OFDMA
        OFDMSymbol_QPSK = zeros(1,N);
        OFDMSymbol_16QAM = zeros(1,N);
        OFDMSymbol_64QAM = zeros(1,N);

        % Map Symbols to Subcarrier
        OFDMSymbol_QPSK(SubCarrierIndex+N/2+1) = Symbols_QPSK(1:Nsubcarriers);
        OFDMSymbol_16QAM(SubCarrierIndex+N/2+1) = Symbols_16QAM(1:Nsubcarriers);
        OFDMSymbol_64QAM(SubCarrierIndex+N/2+1) = Symbols_64QAM(1:Nsubcarriers);

        % Apply IFFT
        ifft_OFDMSymbol_QPSK = ifft(fftshift(OFDMSymbol_QPSK),N)*sqrt(N);
        ifft_OFDMSymbol_16QAM = ifft(fftshift(OFDMSymbol_16QAM),N)*sqrt(N);
        ifft_OFDMSymbol_64QAM = ifft(fftshift(OFDMSymbol_64QAM),N)*sqrt(N);
        
        % Apply  Filter
        F = 0:7.68/(N-1):7.68;
        figure
        plot(F,20*log10(abs(fft(OFDMFilter,N)*1/sqrt(N))))
        hold on
        ifft_OFDMSymbol_QPSK = conv(ifft_OFDMSymbol_QPSK,OFDMFilter);
        
        F = 0:7.68/(length(ifft_OFDMSymbol_QPSK)-1):7.68;
        plot(F,20*log10(abs(fft(ifft_OFDMSymbol_QPSK)*1/sqrt(length(ifft_OFDMSymbol_QPSK)))),'r')
        
        % Oversample
        ifft_OVA_QPSK = zeros(OversampleRate*length(ifft_OFDMSymbol_QPSK),1);
        ifft_OVA_16QAM = zeros(OversampleRate*N,1);
        ifft_OVA_64QAM = zeros(OversampleRate*N,1);

        ifft_OVA_QPSK(1:OversampleRate:end) = ifft_OFDMSymbol_QPSK;
        ifft_OVA_16QAM(1:OversampleRate:end) = ifft_OFDMSymbol_16QAM;
        ifft_OVA_64QAM(1:OversampleRate:end) = ifft_OFDMSymbol_64QAM;

        % Apply Interperation Filter
        ifft_Pulse_shapped_QPSK = conv(ifft_OVA_QPSK,OFDMInterperlationFilter);
        ifft_Pulse_shapped_16QAM = conv(ifft_OVA_16QAM,OFDMInterperlationFilter);
        ifft_Pulse_shapped_64QAM = conv(ifft_OVA_64QAM,OFDMInterperlationFilter);
        
        figure;plot(20*log10(abs(fft(ifft_Pulse_shapped_QPSK)*1/sqrt(length(ifft_Pulse_shapped_QPSK)))))
        
        [ Pxx ] = WelchEstimate( ifft_Pulse_shapped_QPSK, 512, 7.68e6 );
        figure
        F = 0:7.68/(N-1):7.68;
        plot(F,20*log10(Pxx))
%         % Frame
%         Frame_OFDM_QPSK = [Frame_OFDM_QPSK ifft_Pulse_shapped_QPSK.'];
%         % Calculate cubic metric (cubic)
%         filter_output = ifft_Pulse_shapped_QPSK;
%         v_abs=abs(filter_output);
%         v_scale=sqrt(mean(v_abs.*v_abs));
%         v_normalised=v_abs/v_scale;
% 
%         v_cubed=v_normalised.*v_normalised.*v_normalised;
%         v_rms=sqrt(mean(v_cubed.*v_cubed));
%         raw_cubic_metric_QPSK(1,i) = 20*log10(v_rms);
%         WPD_QPSK(1,i) = ((raw_cubic_metric_QPSK(1,i)-reference_case_rms)/K);
%         cubic_OFDM_QPSK(1,i) = WPD_QPSK(1,i)+ OBPD;
%         
%         filter_output = ifft_Pulse_shapped_16QAM;
%         v_abs=abs(filter_output);
%         v_scale=sqrt(mean(v_abs.*v_abs));
%         v_normalised=v_abs/v_scale;
% 
%         v_cubed=v_normalised.*v_normalised.*v_normalised;
%         v_rms=sqrt(mean(v_cubed.*v_cubed));
%         raw_cubic_metric_16QAM(1,i) = 20*log10(v_rms);
%         WPD_16QAM(1,i) = ((raw_cubic_metric_16QAM(1,i)-reference_case_rms)/K);
%         cubic_OFDM_16QAM(1,i) = WPD_16QAM(1,i)+ OBPD;
%         
%         filter_output = ifft_Pulse_shapped_64QAM;
%         v_abs=abs(filter_output);
%         v_scale=sqrt(mean(v_abs.*v_abs));
%         v_normalised=v_abs/v_scale;
% 
%         v_cubed=v_normalised.*v_normalised.*v_normalised;
%         v_rms=sqrt(mean(v_cubed.*v_cubed));
%         raw_cubic_metric_64QAM(1,i) = 20*log10(v_rms);
%         WPD_64QAM(1,i) = ((raw_cubic_metric_64QAM(1,i)-reference_case_rms)/K);
%         cubic_OFDM_64QAM(1,i) = WPD_64QAM(1,i) + OBPD; 
%         figure 
%         f=4.5;
%         plot(0:f/(N-1):f,20*log10(abs((fft(ifft_OFDMSymbol_QPSK)))))
%         figure
%         plot(20*log10(abs(fft(ifft_OVA_QPSK))))
%         figure
%         plot(20*log10(abs(fft(ifft_Pulse_shapped_QPSK))))
        


        BackOffdB = 0; 
        BackOffLin = 10.^(BackOffdB / 10);   
        
        PSfft = 20*log10(abs((fft(ifft_Pulse_shapped_QPSK./BackOffLin)*1/sqrt(length(ifft_Pulse_shapped_QPSK)))));
        f = OversampleRate*7.68;
        F = 0:f/(length(ifft_Pulse_shapped_QPSK)-1):f;
%         F = 0:f/(length(ifft_Pulse_shapped_QPSK)-1):f;
        figure
        plot(F,PSfft)
        hold on
        
        % Amplifier Model
        [ AM_AM_OFDM_QPSK, AM_PM_OFDM_QPSK, CW_OFDM_QPSK ] = AmplifierModel( ifft_Pulse_shapped_QPSK);
        [ AM_AM_OFDM_16QAM, AM_PM_OFDM_16QAM, CW_OFDM_16QAM ] = AmplifierModel( ifft_Pulse_shapped_16QAM );
        [ AM_AM_OFDM_64QAM , AM_PM_OFDM_64QAM , CW_OFDM_64QAM ] = AmplifierModel( ifft_Pulse_shapped_64QAM );
        
        CWfft = 20*log10(abs((fft(CW_OFDM_QPSK)*1/sqrt(length(CW_OFDM_QPSK)))));
        plot(F,CWfft,'r')
        v = ifft_Pulse_shapped_QPSK;
        w = CW_OFDM_QPSK;
        e = abs(v-w).^2; 
        EVM = sqrt(mean(e)/mean(abs(v).^2))*100;
        
%         figure
%         f = 7.68e6; 
%         F = 0:f/(OversampleRate*N-1):f;
%         plot(MUxfft)
%         hold on
%         plot(CWfft,'r')
%         legend('Input','Output')
%         title(['Back Off dB = ', num2str(BackOffdB)])

%         f1 = 1;
%         f2 = 2;
%         f_IM3_1 = 2*f1-f2;
%         f_IM3_2 = 2*f2-f1;
%         P0(i) = (CWfft(f1+1)+CWfft(f2+1))/2;
%         P03(i) = (CWfft(f_IM3_1+1)+CWfft(f_IM3_2+1))/2;
% 
%         IMD3 = P0(i)-P03(i);
%         OIP3(i) = (IMD3/2)+P0(i);
        [ Pxx ] = WelchEstimate( CW_OFDM_QPSK, 512, 7.68e6 );
        figure
        F = 0:f/(512-1):f;
        plot(F,20*log10((Pxx)))
        
%         ChannelF = [-2.25 2.25];
%         [F1min F1] = min(abs(F-ChannelF(1)));
%         [F2min F2] = min(abs(F-ChannelF(2)));
%         ChannelPower = CWfft(F1:F2-1,1);
%         ChannelF = [3.84 3.84+4.5];
%         [F1min F1] = min(abs(F-ChannelF(1)));
%         [F2min F2] = min(abs(F-ChannelF(2)));
%         AddjacentChannel1 = CWfft(F1:F2-1,1);
%         ChannelF = [-4.5-3.84 -3.84];
%         [F1min F1] = min(abs(F-ChannelF(1)));
%         [F2min F2] = min(abs(F-ChannelF(2)));
%         AddjacentChannel2 = CWfft(F1:F2-1,1);
%  
%         % Addajacent Channel Power
%         
%         [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( ChannelPower );
%         chpXRMS = XRMS;
%         [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( AddjacentChannel1 );
%         addj1XRMS = XRMS;
%         [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( AddjacentChannel2 );
%         addj2XRMS = XRMS;
%         title(['EVM = ', num2str(EVM),'%', ' Channel Power = ', num2str(chpXRMS),'dB' ' Addjacent Power 1 = -' num2str(addj1XRMS),'dB', ' Addjacent Power 2 = -' num2str(addj2XRMS),'dB'])
%         
        % Calculate Peak to Mean Ration
        Peak_to_mean_OFDM_QPSK(1,i) = max(abs(ifft_Pulse_shapped_QPSK).^2)/mean(abs(ifft_Pulse_shapped_QPSK).^2);
        Peak_to_mean_OFDM_16QAM(1,i) = max(abs(ifft_Pulse_shapped_16QAM).^2)/mean(abs(ifft_Pulse_shapped_16QAM).^2);
        Peak_to_mean_OFDM_64QAM(1,i) = max(abs(ifft_Pulse_shapped_64QAM).^2)/mean(abs(ifft_Pulse_shapped_64QAM).^2);
        
        % Non-Linear Model
        Non_Lin_Peak_to_mean_OFDM_QPSK(1,i) = max(abs(CW_OFDM_QPSK).^2)/mean(abs(CW_OFDM_QPSK).^2);
        Non_Lin_Peak_to_mean_OFDM_16QAM(1,i) = max(abs(CW_OFDM_16QAM).^2)/mean(abs(CW_OFDM_16QAM).^2);
        Non_Lin_Peak_to_mean_OFDM_64QAM(1,i) = max(abs(CW_OFDM_64QAM).^2)/mean(abs(CW_OFDM_64QAM).^2);
        

        % SC-FDMA
        % Apply DFT
        fft_Symbols_QPSK = fft(Symbols_QPSK(1:Nsubcarriers),Nsubcarriers)/sqrt(Nsubcarriers);
        fft_Symbols_16QAM = fft(Symbols_16QAM(1:Nsubcarriers),Nsubcarriers)/sqrt(Nsubcarriers);
        fft_Symbols_64QAM = fft(Symbols_64QAM(1:Nsubcarriers),Nsubcarriers)/sqrt(Nsubcarriers);

        % Generate SC-OFDMA Symbols
        SC_FDMASymbol_QPSK = zeros(1,N);
        SC_FDMASymbol_16QAM = zeros(1,N);
        SC_FDMASymbol_64QAM = zeros(1,N);

        % Map Symbols to Subcarrier
        SC_FDMASymbol_QPSK(SubCarrierIndex+N/2+1) = fft_Symbols_QPSK;
        SC_FDMASymbol_16QAM(SubCarrierIndex+N/2+1) = fft_Symbols_16QAM;
        SC_FDMASymbol_64QAM(SubCarrierIndex+N/2+1) = fft_Symbols_64QAM;

        % Apply IFFT
        SC_OFDMA_QPSK = ifft(SC_FDMASymbol_QPSK,N)*sqrt(N);
        SC_OFDMA_16QAM = ifft(SC_FDMASymbol_16QAM,N)*sqrt(N);
        SC_OFDMA_64QAM = ifft(SC_FDMASymbol_64QAM,N)*sqrt(N);

        % Oversample
        ifft_OVA_SC_OFDMA_QPSK = zeros(OversampleRate*N,1);
        ifft_OVA_SC_OFDMA_16QAM = zeros(OversampleRate*N,1);
        ifft_OVA_SC_OFDMA_64QAM = zeros(OversampleRate*N,1);

        ifft_OVA_SC_OFDMA_QPSK(1:OversampleRate:end) = SC_OFDMA_QPSK;
        ifft_OVA_SC_OFDMA_16QAM(1:OversampleRate:end) = SC_OFDMA_16QAM;
        ifft_OVA_SC_OFDMA_64QAM(1:OversampleRate:end) = SC_OFDMA_64QAM;

        % Apply Interperation Filter
        ifft_Pulse_shapped_SC_OFDMA_QPSK = conv(ifft_OVA_SC_OFDMA_QPSK,InterperlationFilter);
        ifft_Pulse_shapped_SC_OFDMA_16QAM = conv(ifft_OVA_SC_OFDMA_16QAM,InterperlationFilter);
        ifft_Pulse_shapped_SC_OFDMA_64QAM = conv(ifft_OVA_SC_OFDMA_64QAM,InterperlationFilter);
        
        % Amplifier Model
        [ AM_AM_SC_OFDMA_QPSK, AM_PM_SC_OFDMA_QPSK, CW_SC_OFDMA_QPSK ] = AmplifierModel( ifft_Pulse_shapped_SC_OFDMA_QPSK );
        [ AM_AM_SC_OFDMA_16QAM, AM_PM_SC_OFDMA_16QAM, CW_SC_OFDMA_16QAM ] = AmplifierModel( ifft_Pulse_shapped_SC_OFDMA_16QAM );
        [ AM_AM_SC_OFDMA_64QAM , AM_PM_SC_OFDMA_64QAM , CW_SC_OFDMA_64QAM ] = AmplifierModel( ifft_Pulse_shapped_SC_OFDMA_64QAM );

        % Calculate Peak to Mean Ration
        Peak_to_mean_SC_FDMA_QPSK(1,i) = max(abs(ifft_Pulse_shapped_SC_OFDMA_QPSK).^2)/mean(abs(ifft_Pulse_shapped_SC_OFDMA_QPSK).^2);
        Peak_to_mean_SC_FDMA_16QAM(1,i) = max(abs(ifft_Pulse_shapped_SC_OFDMA_16QAM).^2)/mean(abs(ifft_Pulse_shapped_SC_OFDMA_16QAM).^2);
        Peak_to_mean_SC_FDMA_64QAM(1,i) = max(abs(ifft_Pulse_shapped_SC_OFDMA_64QAM).^2)/mean(abs(ifft_Pulse_shapped_SC_OFDMA_64QAM).^2);
        
        % Non-Linear Model
        Non_Lin_Peak_to_mean_SC_FDMA_QPSK(1,i) = max(abs(CW_SC_OFDMA_QPSK).^2)/mean(abs(CW_SC_OFDMA_QPSK).^2);
        Non_Lin_Peak_to_mean_SC_FDMA_16QAM(1,i) = max(abs(CW_SC_OFDMA_16QAM).^2)/mean(abs(CW_SC_OFDMA_16QAM).^2);
        Non_Lin_Peak_to_mean_SC_FDMA_64QAM(1,i) = max(abs(CW_SC_OFDMA_64QAM).^2)/mean(abs(CW_SC_OFDMA_64QAM).^2);

    end
%     % Power
%     Peak_to_mean_QPSK_dB(n+1,:) = 10*log10(Peak_to_mean_QPSK);
%     Peak_to_mean_16QAM_dB(n+1,:) = 10*log10(Peak_to_mean_16QAM);
%     Peak_to_mean_64QAM_dB(n+1,:) = 10*log10(Peak_to_mean_64QAM);
% 
%     Peak_to_mean_OFDM_QPSK_dB(n+1,:) = 10*log10(Peak_to_mean_OFDM_QPSK);
%     Peak_to_mean_OFDM_16QAM_dB(n+1,:) = 10*log10(Peak_to_mean_OFDM_16QAM);
%     Peak_to_mean_OFDM_64QAM_dB(n+1,:) = 10*log10(Peak_to_mean_OFDM_64QAM);
% 
%     Peak_to_mean_SC_FDMA_QPSK_dB(n+1,:) = 10*log10(Peak_to_mean_SC_FDMA_QPSK);
%     Peak_to_mean_SC_FDMA_16QAM_dB(n+1,:) = 10*log10(Peak_to_mean_SC_FDMA_16QAM);
%     Peak_to_mean_SC_FDMA_64QAM_dB(n+1,:) = 10*log10(Peak_to_mean_SC_FDMA_64QAM);
%     
%     % Power
%     Non_Lin_Peak_to_mean_QPSK_dB(n+1,:) = 10*log10(Non_Lin_Peak_to_mean_QPSK);
%     Non_Lin_Peak_to_mean_16QAM_dB(n+1,:) = 10*log10(Non_Lin_Peak_to_mean_16QAM);
%     Non_Lin_Peak_to_mean_64QAM_dB(n+1,:) = 10*log10(Non_Lin_Peak_to_mean_64QAM);
% 
%     Non_Lin_Peak_to_mean_OFDM_QPSK_dB(n+1,:) = 10*log10(Non_Lin_Peak_to_mean_OFDM_QPSK);
%     Non_Lin_Peak_to_mean_OFDM_16QAM_dB(n+1,:) = 10*log10(Non_Lin_Peak_to_mean_OFDM_16QAM);
%     Non_Lin_Peak_to_mean_OFDM_64QAM_dB(n+1,:) = 10*log10(Non_Lin_Peak_to_mean_OFDM_64QAM);
%     
%     Non_Lin_Peak_to_mean_SC_FDMA_QPSK_dB(n+1,:) = 10*log10(Non_Lin_Peak_to_mean_SC_FDMA_QPSK);
%     Non_Lin_Peak_to_mean_SC_FDMA_16QAM_dB(n+1,:) = 10*log10(Non_Lin_Peak_to_mean_SC_FDMA_16QAM);
%     Non_Lin_Peak_to_mean_SC_FDMA_64QAM_dB(n+1,:) = 10*log10(Non_Lin_Peak_to_mean_SC_FDMA_64QAM);
    
% end


