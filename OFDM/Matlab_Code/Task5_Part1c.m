close all
clear all
F = 4.5e6;
fc = [-60e3 -45e3 -30e3 -15e3 15e3 30e3 45e3 60e3];
f = -100e3:1e3:100e3;
% f(f==0)=1;
T = 1/15e3;
A = 1;
Nsub = 3;
to=0;
GF = zeros(length(f),length(fc));
for i = 1:length(fc)
    ftemp = (f-fc(i));
    ftemp(ftemp==0)=1;
    Gf = A*T*(sin(pi.*ftemp*T)./(pi.*ftemp*T)).*exp(-1i*2*pi*ftemp*to);
    GF(:,i)=Gf;
end
    [Peak Index]=max(GF);
    for i = 1:length(Index)
       Fstr{i}= num2str(f(Index(i)));
    end
    figure
    plot(f,GF)
    xlabel('Frequency', 'FontSize',14);
    ylabel('Amplitude', 'FontSize',14);
    set(gca, 'FontSize',14); 
    legend(Fstr)