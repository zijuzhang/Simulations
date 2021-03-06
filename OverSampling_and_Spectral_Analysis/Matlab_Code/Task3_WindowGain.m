clear all
close all
Fs = 8;
No = (1);    % Noise Spectral Density
SingalSize = 2^12;
Noise = (((randn(1,SingalSize))+1i*(randn(1,SingalSize)))/(sqrt(2))); 
Noise=Noise';
x=Noise; 
amp = 1;
F_s = 2^12-1;
F_w = 10;
nsec = 1;
dur= nsec*F_s;
t = (0:1/F_s:nsec);
n = 0:dur;

x = amp*exp(1i*2*pi*n*F_w/F_s).';
[ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( x );

% x = ones(SingalSize,1);
coherentPowerGain = sum(abs(x)).^2;
% x =x/length(x);
powerX = sum(abs(x).^2);
meanpowerX = mean(abs(x).^2);
% x = x/powerX; 
powerX = sum(abs(x).^2);
meanpowerX = mean(abs(x).^2);
coherentPowerGain = sum(abs(x)).^2;
varx = var(x);  % unit variance 
MeanX = mean(x);
plot(x)
M = length(x);
NfftArray = [2^7 2^8];
[Pxx,f] = pwelch(x);
figure
plot(20*log10(abs(Pxx)))
for i = 1:length(NfftArray)
    Nfft = NfftArray(i);
     
    % Hanning Window
    % -------------- 
    [ win ] = Hanning( Nfft );  
    figure 
    plot(win)  
    figure
    plot(20*log10(fftshift(abs(fft(win)))))
    Ls = length(win);
     
    noverlap = fix(0.5.*Ls);
    
    k = (M-noverlap)./(Ls-noverlap);
    k = fix(k);
    
    % Define Overlap  
    % --------------
    LminusOverlap = Ls-noverlap;
    xStart = 1:LminusOverlap:k*LminusOverlap;
    xEnd   = xStart+Ls-1;
     
    Sxx = zeros(Nfft,1);                    % Power Spectrum Density accumulator
    WindowEnergy = sum(abs(win).^2);        % Compensates for the power of the window, DC gain of window function
    coherentPowerGain = sum(abs(win)).^2;
    [ Normx, ux, Ex, Px, XRMS, simga2, DCGain, PowerGain ] = SignalInfo( win );
    for ii = 1:k,
        xk = x(xStart(ii):xEnd(ii));
        xw = xk.*win;
        Xx = fft(xw,Nfft);
%         figure 
%             HF = fft(x,length(x));
%     F = -1/2:1/(length(HF)-1):1/2;
%     subplot(2,1,1); plot(F,20*log10(fftshift(abs(HF))));
%      subplot(2,1,2);
        
        P = Xx.*conj(Xx)/Px;      % Auto spectrum.
%         plot(20*log10(abs(P)))
%                 figure
%         plot(20*log10(abs(P)))
        Sxx = Sxx + P;                      % Sum scaled periodograms
    end
    Sxx = Sxx./k;                           % Average the sum of the periodogram
    Pxx = Sxx./Fs; % Scale by the sampling frequency to obtain the psd

    MeanPxx = mean(Pxx); 
    figure
     
    HF = fft(x,length(x));
    F = -1/2:1/(length(HF)-1):1/2;
    temp =20*log10(abs(fftshift(Pxx)));
    subplot(2,1,1); plot(F,20*log10(fftshift(abs(HF))));
     title('FFT of original signal')
    F = -Fs/2:Fs/(length(Pxx)-1):Fs/2;
    subplot(2,1,2); plot(F,20*log10(abs(fftshift(Pxx))))
    title(['PSD Estimate Fs = ', num2str(Fs),'  Overlap percentage = 50%','  NFFT = ',num2str(Nfft)]);
    hold off
    pause
end