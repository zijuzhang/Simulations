%Generate QPSK Symbols
close all
clear all
figure
colList = hsv(3);
BW = [1.25, 2.5, 5.0, 10.0, 15.0, 20.0]*1e6;
perecentage = (60.*BW).*(0.015./BW);
BWocc = perecentage.*BW;

Narray = [128 256 512 1024 1536 2048];
Nsubcarriersarray = [72 180 300 600 900 1200];
reference_case_rms   =1.5237;   % Speech 12.2Kbps AMR cubic reference value
                                        % equivalent to 20*log10(v_rms) for
                                      % the Speech case
OBW = perecentage.*BW./1e6;
OBW_ref = 3.84;
OBPD_All = 10*log10(OBW/OBW_ref);
K = 1.56;
count = 1;
for n = 0:length(Narray)-1
    OBPD = OBPD_All(n+1);
    N = Narray(n+1);
    Nsubcarriers = Nsubcarriersarray(n+1);
    SubCarrierIndex = [-Nsubcarriers/2:Nsubcarriers/2-1];

    M = 4;
    [ k_QPSK, Es, Esnorm, Eb, Ebnorm, SymbArray_QPSK ] = GetSymbolArrayData( M );
    numBits_QPSK = k_QPSK*N;
    M = 16;
    [ k_16QAM, Es, Esnorm, Eb, Ebnorm, SymbArray_16QAM ] = GetSymbolArrayData( M );
    numBits_16QAM = k_16QAM*N;
    M = 64;
    [ k_64QAM, Es, Esnorm, Eb, Ebnorm, SymbArray_64QAM ] = GetSymbolArrayData( M );
    numBits_64QAM = k_64QAM*N;

    OversampleRate = 4;                                             % Oversample rate

    alpha = 0.22;                                                   % Roll Of Rate
    truncation = 12;                                                % Truncation in respect to number of symbols
    [ InterperlationFilter ] = RaisedCosine( alpha, truncation ,OversampleRate );      % Interperlation Filter
    NumberOfBlocks = 10^4;
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

        % Oversample
        OVA_QPSK = zeros(OversampleRate*N,1);
        OVA_16QAM = zeros(OversampleRate*N,1);
        OVA_64QAM = zeros(OversampleRate*N,1);

        OVA_QPSK(1:OversampleRate:end) = Symbols_QPSK;
        OVA_16QAM(1:OversampleRate:end) = Symbols_16QAM;
        OVA_64QAM(1:OversampleRate:end) = Symbols_64QAM;

        % Apply Interperation Filter
        Pulse_shapped_QPSK = conv(OVA_QPSK,InterperlationFilter);
        Pulse_shapped_16QAM = conv(OVA_16QAM,InterperlationFilter);
        Pulse_shapped_64QAM = conv(OVA_64QAM,InterperlationFilter);

        % Calculate Peak to Mean Ration
        Peak_to_mean_QPSK(1,i) = max(abs(Pulse_shapped_QPSK).^2)/mean(abs(Pulse_shapped_QPSK).^2);
        Peak_to_mean_16QAM(1,i) = max(abs(Pulse_shapped_16QAM).^2)/mean(abs(Pulse_shapped_16QAM).^2);
        Peak_to_mean_64QAM(1,i) = max(abs(Pulse_shapped_64QAM).^2)/mean(abs(Pulse_shapped_64QAM).^2);

        % OFDMA

        OFDMSymbol_QPSK = zeros(1,N);
        OFDMSymbol_16QAM = zeros(1,N);
        OFDMSymbol_64QAM = zeros(1,N);

        % Map Symbols to Subcarrier
        OFDMSymbol_QPSK(SubCarrierIndex+N/2+1) = Symbols_QPSK(1:Nsubcarriers);
        OFDMSymbol_16QAM(SubCarrierIndex+N/2+1) = Symbols_16QAM(1:Nsubcarriers);
        OFDMSymbol_64QAM(SubCarrierIndex+N/2+1) = Symbols_64QAM(1:Nsubcarriers);

        %Apply IFFT
        ifft_OFDMSymbol_QPSK = ifft(OFDMSymbol_QPSK,N)*sqrt(N);
        ifft_OFDMSymbol_16QAM = ifft(OFDMSymbol_16QAM,N)*sqrt(N);
        ifft_OFDMSymbol_64QAM = ifft(OFDMSymbol_64QAM,N)*sqrt(N);

        % Oversample
        ifft_OVA_QPSK = zeros(OversampleRate*N,1);
        ifft_OVA_16QAM = zeros(OversampleRate*N,1);
        ifft_OVA_64QAM = zeros(OversampleRate*N,1);

        ifft_OVA_QPSK(1:OversampleRate:end) = ifft_OFDMSymbol_QPSK;
        ifft_OVA_16QAM(1:OversampleRate:end) = ifft_OFDMSymbol_16QAM;
        ifft_OVA_64QAM(1:OversampleRate:end) = ifft_OFDMSymbol_64QAM;

        % Apply Interperation Filter
        ifft_Pulse_shapped_QPSK = conv(ifft_OVA_QPSK,InterperlationFilter);
        ifft_Pulse_shapped_16QAM = conv(ifft_OVA_16QAM,InterperlationFilter);
        ifft_Pulse_shapped_64QAM = conv(ifft_OVA_64QAM,InterperlationFilter);

        % Calculate Peak to Mean Ration
        Peak_to_mean_OFDM_QPSK(1,i) = max(abs(ifft_Pulse_shapped_QPSK).^2)/mean(abs(ifft_Pulse_shapped_QPSK).^2);
        Peak_to_mean_OFDM_16QAM(1,i) = max(abs(ifft_Pulse_shapped_16QAM).^2)/mean(abs(ifft_Pulse_shapped_16QAM).^2);
        Peak_to_mean_OFDM_64QAM(1,i) = max(abs(ifft_Pulse_shapped_64QAM).^2)/mean(abs(ifft_Pulse_shapped_64QAM).^2);
        
        % Calculate cubic metric (cubic)

        filter_output = ifft_Pulse_shapped_QPSK;
        v_abs=abs(filter_output);
        v_scale=sqrt(mean(v_abs.*v_abs));
        v_normalised=v_abs/v_scale;

        v_cubed=v_normalised.*v_normalised.*v_normalised;
        v_rms=sqrt(mean(v_cubed.*v_cubed));
        raw_cubic_metric_QPSK(1,i) = 20*log10(v_rms);
        WPD_QPSK(1,i) = ((raw_cubic_metric_QPSK(1,i)-reference_case_rms)/K);
        cubic_OFDM_QPSK(1,i) = WPD_QPSK(1,i)+ OBPD;
        
        filter_output = ifft_Pulse_shapped_16QAM;
        v_abs=abs(filter_output);
        v_scale=sqrt(mean(v_abs.*v_abs));
        v_normalised=v_abs/v_scale;

        v_cubed=v_normalised.*v_normalised.*v_normalised;
        v_rms=sqrt(mean(v_cubed.*v_cubed));
        raw_cubic_metric_16QAM(1,i) = 20*log10(v_rms);
        WPD_16QAM(1,i) = ((raw_cubic_metric_16QAM(1,i)-reference_case_rms)/K);
        cubic_OFDM_16QAM(1,i) = WPD_16QAM(1,i)+ OBPD;
        
        filter_output = ifft_Pulse_shapped_64QAM;
        v_abs=abs(filter_output);
        v_scale=sqrt(mean(v_abs.*v_abs));
        v_normalised=v_abs/v_scale;

        v_cubed=v_normalised.*v_normalised.*v_normalised;
        v_rms=sqrt(mean(v_cubed.*v_cubed));
        raw_cubic_metric_64QAM(1,i) = 20*log10(v_rms);
        WPD_64QAM(1,i) = ((raw_cubic_metric_64QAM(1,i)-reference_case_rms)/K);
        cubic_OFDM_64QAM(1,i) = WPD_64QAM(1,i) + OBPD;

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

        % Calculate Peak to Mean Ration
        Peak_to_mean_SC_FDMA_QPSK(1,i) = max(abs(ifft_Pulse_shapped_SC_OFDMA_QPSK).^2)/mean(abs(ifft_Pulse_shapped_SC_OFDMA_QPSK).^2);
        Peak_to_mean_SC_FDMA_16QAM(1,i) = max(abs(ifft_Pulse_shapped_SC_OFDMA_16QAM).^2)/mean(abs(ifft_Pulse_shapped_SC_OFDMA_16QAM).^2);
        Peak_to_mean_SC_FDMA_64QAM(1,i) = max(abs(ifft_Pulse_shapped_SC_OFDMA_64QAM).^2)/mean(abs(ifft_Pulse_shapped_SC_OFDMA_64QAM).^2);

    end

    % Power
    Peak_to_mean_QPSK_dB = 10*log10(Peak_to_mean_QPSK);
    Peak_to_mean_16QAM_dB = 10*log10(Peak_to_mean_16QAM);
    Peak_to_mean_64QAM_dB = 10*log10(Peak_to_mean_64QAM);

    Peak_to_mean_OFDM_QPSK_dB = 10*log10(Peak_to_mean_OFDM_QPSK);
    Peak_to_mean_OFDM_16QAM_dB = 10*log10(Peak_to_mean_OFDM_16QAM);
    Peak_to_mean_OFDM_64QAM_dB = 10*log10(Peak_to_mean_OFDM_64QAM);

    Peak_to_mean_SC_FDMA_QPSK_dB = 10*log10(Peak_to_mean_SC_FDMA_QPSK);
    Peak_to_mean_SC_FDMA_16QAM_dB = 10*log10(Peak_to_mean_SC_FDMA_16QAM);
    Peak_to_mean_SC_FDMA_64QAM_dB = 10*log10(Peak_to_mean_SC_FDMA_64QAM);
   
    % Plot CDF

    % Normall


    MarkerArray = ['+','o','*','x','p','h'];
    Marker = MarkerArray(n+1);
    NormMarker = ['-',Marker];
    if n+1 ==3
        [a,x]=hist(Peak_to_mean_QPSK_dB,[0:0.5:15]);
        t = cumsum(a)/sum(a);
        semilogy(x,abs(1-t),NormMarker,'col', colList(1,:))
        Leg{count} = ['QPSK N = ', num2str(N)];
        count = count+1;
        hold on


        [a,x]=hist(Peak_to_mean_16QAM_dB,[0:0.5:15]);
        t = cumsum(a)/sum(a);
        semilogy(x,abs(1-t),NormMarker,'col', colList(2,:))
        Leg{count} = ['16 QAM N = ', num2str(N)];
        count = count+1;

        [a,x]=hist(Peak_to_mean_64QAM_dB,[0:0.5:15]);
        t = cumsum(a)/sum(a);
        semilogy(x,abs(1-t),NormMarker,'col', colList(3,:))
        Leg{count} = ['64 QAM N = ', num2str(N)];
        count = count+1;
        
        % SC-FDMA
        SCFDMAMarker = [':',Marker];
        [a,x]=hist(Peak_to_mean_SC_FDMA_QPSK_dB,[0:0.5:15]);
        t = cumsum(a)/sum(a);
        semilogy(x,abs(1-t),SCFDMAMarker,'col', colList(1,:))
        Leg{count} = ['SC FDMA QPSK N = ', num2str(N)];
        count = count+1;
        hold on

        [a,x]=hist(Peak_to_mean_SC_FDMA_16QAM_dB,[0:0.5:15]);
        t = cumsum(a)/sum(a);
        semilogy(x,abs(1-t),SCFDMAMarker,'col', colList(2,:))
        Leg{count} = ['SC FDMA 16 QAM N = ', num2str(N)];
        count = count+1;

        [a,x]=hist(Peak_to_mean_SC_FDMA_64QAM_dB,[0:0.5:15]);
        t = cumsum(a)/sum(a);
        semilogy(x,abs(1-t),SCFDMAMarker,'col', colList(3,:))
        Leg{count} = ['SC FDMA 64 QAM N = ', num2str(N)];
        count = count+1;
    end

%     % OFDM
%     test = n+1;
%     if test == 1||test == 6
%         OFDMMarker = ['-.',Marker];
%         [a,x]=hist(Peak_to_mean_OFDM_QPSK_dB,[0:0.5:15]);
%         t = cumsum(a)/sum(a);
%         semilogy(x,abs(1-t),OFDMMarker,'col', colList(1,:))
%         Leg{count} = ['OFDM QPSK N = ', num2str(N)];
%         count = count+1;
%         hold on
%     end
%     
%     if test == 2||test == 6
%         [a,x]=hist(Peak_to_mean_OFDM_16QAM_dB,[0:0.5:15]);
%         t = cumsum(a)/sum(a);
%         semilogy(x,abs(1-t),OFDMMarker,'col', colList(2,:))
%         Leg{count} = ['OFDM 16 QAM N = ', num2str(N)];
%         count = count+1;
%     end
%     if test == 3||test == 6
%         [a,x]=hist(Peak_to_mean_OFDM_64QAM_dB,[0:0.5:15]);
%         t = cumsum(a)/sum(a);
%         semilogy(x,abs(1-t),OFDMMarker,'col', colList(3,:))
%         Leg{count} = ['OFDM 64 QAM N = ', num2str(N)];
%         count = count+1;
%     end
%     set(gca, 'FontSize',14); 
%     title('OFDM Symbols')
%     xlabel('Peak to Mean, x dB');
%     ylabel('Probability , X>=x');
%     legend(Leg)
%     grid on
    
    figure
    plot(Peak_to_mean_OFDM_QPSK)
    hold on
    plot(raw_cubic_metric_QPSK,'r')
    var(cubic_OFDM_QPSK)
    var(cubic_OFDM_16QAM)
    var(cubic_OFDM_64QAM)
    grid on


end

