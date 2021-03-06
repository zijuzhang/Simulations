clear all
close all
% Modulation Scheme
Bandwith = 4.5e6;
deltaF = 15e3;
Nfft = 512;
T = 1/deltaF;
Ts = T/Nfft;
Nsubcarriers = 300;
TimeSample = (0:Nsubcarriers-1)*Ts;
OversampleRate = 8;

SubCarrierIndex = [-Nsubcarriers/2:-1 1: Nsubcarriers/2];
fs = Bandwith/(Nsubcarriers-1);

f = 0:fs:Bandwith; 
temp = fs(end);
M = [4];
TransmitTime = 10e-3;
NumberOfOFDMSymbols = TransmitTime/T;
NumberOfFrames = 1;
NumM = length(M);         % Number of M-arys to be tested

% alpha = 0.22;                                                   % Roll Of Rate
% truncation = 32;                                                % Truncation in respect to number of symbols
% [ InterperlationFilter ] = RaisedCosine( alpha, truncation ,OversampleRate );      % Interperlation Filter

h=[2; -1; -1; 1; -1; -2; 2; 1; 3; 1; 3; -4; 0; 5; -4; -3; 8; -2; -7; 9; 2; -12; 7; 9; -16; 2; 18; -17; -9; 28; -12; -26; 37; 3; -55; 45; 46; -128; 49; 538];

InterperlationFilter = [ h ;flipdim(h,1)];

[Peak, index] = max( InterperlationFilter );                    % Filter Parameters
index = (index-1);
% index = 2*index;

ZeroPadding = zeros(1,(Nfft - Nsubcarriers)/2);

% Configure Test
% --------------
EsNo_dB(:,1) = 35;%linspace(35, 0, 10); % Noise density dB
EsNo_lin = 10.^(EsNo_dB / 10);      % Noise density linear   
NumEsNo = length(EsNo_lin);         % Numb of Iterations
EsNo_dBArray = zeros(NumEsNo,NumM);
EbNo_dBArray = zeros(NumEsNo,NumM);

OFDMSymbol = zeros(1,Nfft);
Ncp = 36;
ReferenceSymbol = zeros(1,Nfft);
Ref = ones(1,Nsubcarriers); 
ReferenceSymbol(SubCarrierIndex+Nfft/2+1) = Ref;

powerRef = mean(abs(Ref).^2);
Lref = fftshift(ReferenceSymbol);
ReferenceSymbol = ifft(fftshift(ReferenceSymbol),Nfft)*sqrt(Nfft);

RefPrefix = ReferenceSymbol((Nfft-Ncp)+1:Nfft);
LocalReplica = ReferenceSymbol;
ReferenceSymbol = [ RefPrefix ReferenceSymbol];
powerReferenceSymbol = mean(abs(ReferenceSymbol).^2);

refPower = abs(sum(ReferenceSymbol))^2;
RefIndex = 1:8:NumberOfOFDMSymbols;
RefNumb = length(RefIndex);
for m = 1:NumM
    [ k, Es, Esnorm, Eb, Ebnorm, SymbolArray ] = GetSymbolArrayData( M(m) );
    for i = 1:NumEsNo
        Frame = [];
        Frame_Aligned = [];
        for numFrame = 1:NumberOfFrames
            count = 1;
            for ii = 1:NumberOfOFDMSymbols
                TxPacket = double(rand(1,Nsubcarriers*k) > 0.5);
                [ TxSymbolIdx, TrCHFrameSize ] = SymbolIndex( TxPacket, k );
                [ TxSymbol ] = SymbolArray(TxSymbolIdx); 
                OFDMSymbol(SubCarrierIndex+Nfft/2+1) = TxSymbol;
                
                powerOFDMSymbol = mean(abs(OFDMSymbol).^2);
                outputIDFT = ifft(fftshift(OFDMSymbol),Nfft)*sqrt(Nfft);
                poweroutputIDFT = mean(abs(outputIDFT).^2);
                CyclicPrefix = outputIDFT((Nfft-Ncp)+1:Nfft);
                outputIDFT_CP = [CyclicPrefix outputIDFT];
                poweroutputIDFT_CP = mean(abs(outputIDFT_CP).^2);
                if ii== RefIndex(count) 
                        outputIDFT_CP = ReferenceSymbol;
                        if count<length(RefIndex)
                            count = count+1;
                        end
                end

                Frame = [Frame outputIDFT_CP];
                NumSymbols = length(Frame);
                
            end
            powerFrame = mean(abs(Frame).^2);
            
            % Oversample
            OVA_Frame = zeros(1,OversampleRate*length(Frame));
            OVA_Frame(1:OversampleRate:end) = Frame;

            Frame = conv(OVA_Frame,OversampleRate*InterperlationFilter);
        
            % Amplifier Model
            BackOffdB = 0; 
            BackOffLin = 10.^(BackOffdB / 10); 
            Frame = Frame./BackOffLin;
            [ AM_AM_OFDM_QPSK, AM_PM_OFDM_QPSK, CW_OFDM_QPSK ] = AmplifierModel( Frame, BackOffdB);
            v = Frame;
            w = CW_OFDM_QPSK;
            e = abs(v-w).^2; 
            EVM = sqrt(mean(e)/mean(abs(v).^2))*100;           
             
            CWfft = 20*log10(abs(fftshift(fft(CW_OFDM_QPSK)*1/sqrt(length(CW_OFDM_QPSK)))));
            figure
            f = OversampleRate*7.68;
            F = -f/2:f/(length(Frame)-1):f/2;
%             F = 0:f/(length(CWfft)-1):f;
            plot(F,20*log10(abs(fftshift(fft(Frame)*1/sqrt(length(Frame))))))
            hold on
            plot(F,CWfft,'r') 
            xlabel('Frequency MHz')
            ylabel('Magnitude')
            legend( 'Input', 'Output')
            
            ChannelF = [-2.25 2.25];
            [F1min F1] = min(abs(F-ChannelF(1)));
            [F2min F2] = min(abs(F-ChannelF(2)));
            ChannelPower = CWfft(1,F1:F2-1);
            ChannelF = [3.84 3.84+4.5];
            [F1min F1] = min(abs(F-ChannelF(1)));
            [F2min F2] = min(abs(F-ChannelF(2)));
            AddjacentChannel1 = CWfft(1,F1:F2-1);
            ChannelF = [-4.5-3.84 -3.84];
            [F1min F1] = min(abs(F-ChannelF(1)));
            [F2min F2] = min(abs(F-ChannelF(2)));
            AddjacentChannel2 = CWfft(1,F1:F2-1);

            % Addajacent Channel Power

            [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( ChannelPower );
            chpXRMS = XRMS;
            [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( AddjacentChannel1 );
            addj1XRMS = XRMS;
            [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( AddjacentChannel2 );
            addj2XRMS = XRMS;
            title(['EVM = ', num2str(EVM),'%', ' Channel Power = ', num2str(chpXRMS),'dB' ' adjacent Power 1 = -' num2str(addj1XRMS),'dB', ' adjacent Power 2 = -' num2str(addj2XRMS),'dB'])
        end
    end
end

                 
%             % Channel 
%             % ------- 
%             ChannelSize = 37;
%             Taps = 2;
%             x = randn(1, Taps); y = randn(1, Taps); % Random Variables X and Y with Gaussian Distribution mean zero variance one
%             rayleighFade =(1 + 1i.*y)/sqrt(2);       % Normalised Ralyiegh random Variable
%             Delay = randi(Ncp,1,Taps); % Shifted by Delay OFDM symbol
%             h = zeros(1,ChannelSize);
%             h(Delay) = rayleighFade; % Delay Unit Power
%             NormalisationTerm = 1/sqrt(Taps);
%             h = h*NormalisationTerm; % Normalised to unit power
%             powerh = sum(abs(h).^2);
%             Frame_Channel = Frame;%conv(Frame,h);     

%             % AWGN
%             % ----
%             N = length(Frame_Channel);
%             No = (Es./EsNo_lin(i));    % Noise Spectral Density
%             NoiseVar = No;             % Noise Variance
%             AWGN = sqrt(No)*(randn(1,N)+1i*randn(1,N))*(1/sqrt(2));     % Normalised AWGN in respect to Esnorm
            
%             powerFrameChannel = mean(abs(Frame_Channel).^2);
%             Frame = conv(Frame,InterperlationFilter);
%             FrameRecieved = Frame;%+AWGN;
%                                  
%             % Reciever
%             % --------
%             rPoint = index+OversampleRate*Ncp+1;  
%             checkpoint = Nfft*7;
%             FrameTest = FrameRecieved(rPoint:end);
% 
%             NumberOfPacketsLeft = floor(length(FrameRecieved)/(OversampleRate*(Nfft+Ncp)));
%             while NumberOfPacketsLeft
%                 RefSymobl = FrameTest(1:OversampleRate:OversampleRate*Nfft);
%                 Rxref = fft(RefSymobl,Nfft)*1/sqrt(Nfft);
%                 Hchannel = Rxref./Lref; 
%                 Hchannel = [Hchannel(2:151) Hchannel(363:end)];
%                 Hn = Hchannel;
%                 rPoint = OversampleRate*(Nfft+Ncp)+1; 
%                 FrameTest = FrameTest(rPoint:end);
%                 NumberOfPacketsLeft = NumberOfPacketsLeft-1;
%                 if NumberOfPacketsLeft >= 8
%                     for sync = 1:7
%                         SampledSymbol = FrameTest(1:OversampleRate:OversampleRate*Nfft);
%                         Yn =fft(SampledSymbol,Nfft)*1/sqrt(Nfft);
%                         Yn = [Yn(2:151) Yn(363:end)];
%                         Xn = Yn./Hn;
%                         Frame_Aligned = [Frame_Aligned Xn];
%                         FrameTest = FrameTest(rPoint:end);
%                         NumberOfPacketsLeft = NumberOfPacketsLeft-1;
%                     end
%                 else
%                     for sync = 1:NumberOfPacketsLeft
%                         SampledSymbol = FrameTest(1:OversampleRate:OversampleRate*Nfft);
%                         Yn =fft(SampledSymbol,Nfft)*1/sqrt(Nfft);
%                         Yn = [Yn(2:151) Yn(363:end)];
%                         Xn = Yn./Hn;
%                         Frame_Aligned = [Frame_Aligned Xn];
%                         NumberOfPacketsLeft = NumberOfPacketsLeft-1;
%                         if sync < NumberOfPacketsLeft
%                             FrameTest = FrameTest(rPoint:end);
%                         end
%                     end
%                 end
%             end 
%             
%         end
% 
% 
%         x=FrameRecieved.';
%         [ Pxx ] = WelchEstimate( x, Nfft, 1 );
%         
%         figure
%         HF = fft(x,length(x));
%         f = 7.68;
% 
%         subplot(3,1,1);
%         F = -f/2:f/(length(Pxx)-1):f/2;
%         plot(F,20*log10(abs((Pxx))))
% 
%         set(gca, 'FontSize',14); 
%         title(['Welch Power Spectrum Estimate = ','  Overlap Percentage = 50%','  NFFT = ',num2str(Nfft)]);
%         xlabel('Frequency (MHz)', 'FontSize',14);
%         ylabel('Magnitude dB', 'FontSize',14);
%         
%         subplot(3,1,2); 
%         F = -f/2:f/(Nfft-1):f/2;
%         plot(F,20*log10((abs(fft(SampledSymbol,Nfft)))));
%         set(gca, 'FontSize',14); 
%         title('FFT, OFDM Symbol')
%         xlabel('Frequency (MHz)', 'FontSize',14);
%         ylabel('Magnitude dB', 'FontSize',14);
%         hold off
%         
%         subplot(3,1,3); 
%         plot(Frame_Aligned,'o')
%         set(gca, 'FontSize',14); 
%         title( ' QPSK Constellation OFDM ')
%         xlabel('I', 'FontSize',14);
%         ylabel('Q', 'FontSize',14);
