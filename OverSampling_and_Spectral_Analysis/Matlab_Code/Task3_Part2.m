clear all 
close all
M = 4;

[ k, Es, Esnorm, Eb, Ebnorm, SymbolArray ] = GetSymbolArrayData( M );
numBits = k*(2^8);

Txbits = double(rand(1,numBits) > 0.5);
[ TxSymbolIdx, TrCHFrameSize ] = SymbolIndex( Txbits, k );
[ TxSymbol ] = SymbolArray(TxSymbolIdx);
numSymbols = length(TxSymbol);
Freq = 1;
B = 0:Freq/(numSymbols-1):Freq;
Bandwidth = B(end);
Fn = B(end);

FsArray = [4, 8];
for i = 1:length(FsArray)
    Fs = FsArray(i);
    txUpSample = zeros(Fs*numSymbols,1);
    txUpSample(1:Fs:end) = TxSymbol;
    
    n = length(txUpSample);
    t = (0:n-1)/Fs;
    fOverSampled = 0:Fs/(n-1):Fs; 
    FnOverSampled = fOverSampled(end);
    
    Beta = FnOverSampled/Fn;
    
    f = -Fs/2:Fs/(n-1):Fs/2;
    
    
    FilterRec = ones(Fs,1);
    FilterRecOutput = conv(FilterRec,txUpSample);
    N = length(FilterRecOutput);
    T = (0:N-1)/Fs;
    F = -Fs/2:Fs/(N-1):Fs/2;
    Ftmp = F;
    B = 0:Fs/(N-1):Fs;
    BandwidthFilter = B(end);

    figure
    subplot(2,1,1); plot(t,real(txUpSample))
    axis([0 20 -1 1])
    xlabel('Time (sec)');
    ylabel('Amplitude');
    title(['Time Domain Over Sampled Fs = ',num2str(Fs)]);

    subplot(2,1,2); plot(T,real(FilterRecOutput))
    axis([0 20 -1 1])
    xlabel('Time (sec)');
    ylabel('Amplitude');
    title('Time Domain Rectangular Filter');
    pause
    
    figure
    subplot(2,1,1); plot(t,real(txUpSample))
    axis([0 20 -1 1])
    xlabel('Time (sec)');
    ylabel('Amplitude');
    title(['Time Domain Transmitted Bits, Bandwidth = ', num2str(Bandwidth),'Hz']);
    
    subplot(2,1,2); plot(T,real(FilterRecOutput))
    axis([0 20 -1 1])
    xlabel('Time (sec)');
    ylabel('Amplitude');
    title(['Time Domain Over Sampled Fs = ',num2str(Fs), ' Bandwidth = ', num2str(BandwidthFilter),'Hz']);
    pause
    
    txUpSampledB = 10*log10(abs(fft(txUpSample)));
    FilterRecOutputdB = 10*log10(abs(fft(FilterRecOutput)));
    FilterRecOutputdBShift = 10*log10(abs(fftshift(fft(FilterRecOutput))));
    
    figure
    subplot(3,1,1); plot(0:Fs/(n-1):Fs,txUpSampledB)
    xlabel('Frequency');
    ylabel('dB');
    title(['Time Domain Transmitted Bits, Bandwidth = ', num2str(Bandwidth),'Hz']);
    subplot(3,1,2); plot(0:Fs/(N-1):Fs,FilterRecOutputdB)
    xlabel('Frequency');
    ylabel('dB');
    title(['Time Domain Over Sampled Fs = ',num2str(Fs), ' Bandwidth = ', num2str(BandwidthFilter),'Hz']);
    subplot(3,1,3); plot(F,FilterRecOutputdBShift)
    xlabel('Frequency');
    ylabel('dB');
    title(['Time Domain Over Sampled Fs = ',num2str(Fs), ' Bandwidth = ', num2str(BandwidthFilter),'Hz']);
    pause

    val = 65;
    [eyeDRect] = eyeDiagram( val , FilterRecOutput );
    figure
    plot(eyeDRect,'b')
    title('Eye Diagram Rect Filtered Signal');
    pause
    
%     NfftArray = [2^7 2^8 2^9 2^10];
%     
%     for j = 1:2
%         if j ==1
%             x = txUpSample;
%             xTitle = 'Over Sampled Singal   ';
%             tempPlot = txUpSampledB;
%             tempPlot2 = txUpSampledB;
%             tempF = 0:Fs/(n-1):Fs;
%             tempPD = txUpSample;
%         elseif j ==2
%             x = FilterRecOutput;
%             xTitle = 'Rectangular Filtered Singal   ';
%             tempPlot = FilterRecOutputdB;
%             tempPlot2 = FilterRecOutputdBShift;
%             tempF = 0:Fs/(length(FilterRecOutputdB)-1):Fs;
%             tempPD = FilterRecOutput;
%         end
%         for ii = 1:length(NfftArray)
%             
%             Nfft = NfftArray(ii);
%             [ win ] = Hanning( Nfft );
%             
%             F = 0:Fs/(length(x)-1):Fs;
%             Fn = F(Nfft);
%             HF = fft(win,256);
%             FH = -Fn/2:Fn/(length(HF)-1):Fn/2;
%             
% %             figure
% %             plot(1:length(win),sqrt((win.^2)/length(win)),'r')
%             
%             figure
%             plot(FH,20*log10(fftshift(abs(HF))));
%             xlabel('Frequency');
%             ylabel('Amplitude');
%             title('Frequency Response of Hanning filter');
%             
%             [Pxx,F] = pwelch(x,win,[],Nfft,Fs);
%             B =F(end);
%             N = length(Pxx);
%             
%             Fpd = -Fs/2:Fs/(length(tempPD)-1):Fs/2;
%             ProcessingGain = 10*log10(Nfft/2);
%             
%             figure
%             y = fft(tempPD, length(tempPD));
%             y0 = fftshift(y);
%             
%             power = y0.*conj(y0)/length(tempPD);
%             subplot(4,1,1); plot(Fpd,10*log10(abs(power)))
%             title([xTitle,'Periodogram']);
%             
%             subplot(4,1,2); plot(win)
%             axis([0 length(win) 0 1])
%             title([xTitle,'Hanning Window']);
%             
% 
%             subplot(4,1,3); plot(F,ProcessingGain + 10*log10(Pxx),'r')
%             hold on
%             plot(tempF,tempPlot)
%             hold off
%             title([xTitle,'PSD Estimate Fs = ', num2str(Fs),'  Overlap percentage = 50%','  NFFT = ',num2str(Nfft)]);
%             xlabel('Frequency');
%             ylabel('dB');
%             
%             F = -Fs/2:Fs/(N-1):Fs/2;
%             subplot(4,1,4); plot(F,ProcessingGain + 10*log10(fftshift(Pxx)),'r')
%             hold on
%             plot(-Fs/2:Fs/(length(tempPlot)-1):Fs/2,tempPlot2)
%             hold off
%             title([xTitle,'PSD Estimate Fs = ', num2str(Fs),'  Overlap percentage = 50%','  NFFT = ',num2str(Nfft)]);
%             xlabel('Frequency');
%             ylabel('dB');
%             pause
%             
%             figure
%             plot(Fpd,10*log10(abs(power)))
%             hold on
%             plot(F,10*log10(fftshift(Pxx)),'r')
%             hold off
%             pause
%             
%             
%         end
%     end

end