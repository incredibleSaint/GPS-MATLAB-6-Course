% Тело неопределенности АКФ, а также его сечения при df = 0 и t = 0:
clear; close all;
logScale = 0;
PSC = GenCACode( 1 );
PSC = 2 * PSC - 1;
a   = abs(((ifft(fft(PSC).* conj(fft(PSC))))));
plot(a)
%----------------------------------------------
Fs    = 1.023e6;
dt    = 1 / Fs;
dFmax = 4 * 10^3;
dF    = 10;
df    = -dFmax : dF : dFmax;
PSCduration256chips = 1e-3;%10e-3 / 15 / 10; %6.67e-5 (sec)
% PSCsh = zeros(length(df), 2 * length( PSC ) - 1 );
PSCsh = zeros( length(df), length( PSC ) );
for i = 1:length(df)
    PSC_ = PSC .* exp(1j * 2 * pi * df(i) * dt * (1 : length( PSC ) ) );
    PSCsh(i,:) = abs((ifft(fft(PSC) .* conj(fft(PSC_)))));
%     PSCsh(i,:) = abs(conv(PSC_, conj(fliplr(PSC))));
end
figure;
ss = surf(PSCsh);
set(ss,'LineStyle','none');

figure;
plot(PSCsh);
acfMax = max(max(PSCsh));
if logScale == 1
    PSCsh  = 10*log10(PSCsh/acfMax);
end
%----------------- delta(f) = 0 ----------------------------
figure;
% plot([1 : 2 * length( PSC ) - 1]*dF, PSCsh((length(df) + 1)/2, :));% f = 0;
plot([1 : length( PSC )] * dF, PSCsh((length(df) + 1)/2, :));% f = 0;
xlabel('t, sec');
ylabel('P, dB');
title('ACF, when delta(f) = 0');
xt = get(gca, 'XTick');% 'XTick' Values
set(gca, 'XTick', xt, 'XTickLabel', xt*PSCduration256chips...
                                /length(PSCsh((length(df) + 1)/2,:))); 
grid on;
%----------------- delta(t) = 0 ----------------------------
figure;
% plot(PSCsh(1, length( PSC )));
plot(df, PSCsh(:, 1));
hold on;
% x = 1:1:length(PSCsh(:,length( PSC )));
% y = -1*ones(1,length(PSCsh(:,length( PSC ))));
% plot(x,y);
xlabel('F, Hz');
ylabel('P, dB');
title('ACF, when delta(t) = 0');
% xt = get(gca, 'XTick');% 'XTick' Values
% set(gca, 'XTick', xt, 'XTickLabel', xt*dF - dFmax); 
grid on;
%%
matr = zeros(121,2045);
k=1;
for f = -4000 : 10 : 4000
    CAshifted = PSC.*exp(1i*2*pi*f/(1.023*10^6).*[1:1023]);
    matr(k,:) = conv([CAshifted(2:end) CAshifted CAshifted(1:end-1)],conj(fliplr(PSC)),'valid');
    k = k + 1;
end
figure;
surf(abs(matr), 'EdgeColor', 'none'); %тело неопределённости
figure;
plot(( abs(matr(:, 1023))) );  
%%
% %-------------------- 2D ACF -------------------------------

PSC = GenCACode( 1 );
for i = 1:length(df)
    for k = 0 : 1022
        PSCtemp = circshift( PSC, k);
        PSC_ = PSCtemp.*exp(1j*2*pi*df(i)*dt*(1 : length( PSC ) ) );
    %    PCSsh(i,:) = abs((ifft(fft(PSC).* conj(fft(PCS_)))));
        convol = abs(conv(PSC, conj(fliplr(PSC_)), 'valid'));
        ccf2D(i, k + 1) = max(convol);
    end
end
figure;
ss = surf( [0 : 1022], df, ccf2D);
set(ss,'LineStyle','none');
%%
% Первичные и вторичные последовательности (PSC, SSC) ортогональны 
% друг к другу (нет корреляции);
SSC = 2 * GenCACode( 2 ) - 1;
acf = abs(conv(PSC, conj(fliplr(SSC))));
figure;
plot(acf);
max(acf)
%%
close all
PSC = Generate_Primary_Synchronisation_Code;
acf0 = abs(conv([PSC PSC], PSC));
figure;
% plot(10*log10(acf0/max(max(acf0))));
plot(acf0);
% 
PSC = Generate_Primary_Synchronisation_Code;
acf1 = abs(conv([PSC PSC], PSC, 'same'));
figure;
% plot(10*log10(acf1/max(max(acf1))));
plot(acf1);
%
PSC = Generate_Primary_Synchronisation_Code;
acf2 = abs(conv([PSC PSC], PSC, 'valid'));
figure;
% plot(10*log10(acf2/max(max(acf2))));
plot(acf2);
%%
close all; clear;
dtNs = 0 : 300;
dt = dtNs * 1e-9;
c = 3e8;
sigma1 = c * dt;
sigma2 = sigma1;
sigma3 = sigma2;
sigma123 = sqrt( sigma1 .^ 2 + sigma2 .^ 2 + sigma3 .^ 2 );
figure;
plot( dtNs , sigma123 );
xlabel( "СКО 1PPS, нс");
ylabel( "СКО местоположения, м");
grid on;