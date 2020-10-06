% Построение кривых вероятности ложной тревоги в зависимости от порога
expNum = 1e4;
accNum = [10];
EbN0 = 0;
threshold = [3 10];

freqMax = 5e3;
freqStep = 1e3;

caCode = GenCACode(1);
caCode = 2 * caCode - 1;
lenCA = length(caCode);
snr = EbN0 - 10 * log10(length(lenCA));
Fs = 1.023e6;
dt = 1 / Fs;

fAlProbCoh = zeros(length(accNum), length(threshold));
fAlProbNonCoh = zeros(length(accNum), length(threshold));
for acc = 1 : length(accNum)
    cohLen = accNum(acc) * lenCA + lenCA - 1;
    nonCohLen = 2 * accNum(acc) * lenCA + lenCA - 1;
    
    dfCoh    = -freqMax : freqStep / accNum(acc) : freqMax;
    dfNonCoh = -freqMax : freqStep : freqMax;
    
    convSum1 = zeros(length(dfCoh)   , lenCA);
    convSum2 = zeros(length(dfCoh)   , lenCA);
    convSum  = zeros(length(dfNonCoh), lenCA);
    
    for n = 1 : length(threshold)
        posCntCoh = 0;
        posCntNonCoh = 0;
        for k = 1 : expNum
            % Input signal (false signal):
            randSig = randi([0 1], 1, 2 * accNum(acc) * lenCA + ...
                                                            lenCA - 1);
            randSig = 2 * randSig - 1;
            inpSig = awgn(randSig, snr + 3, 'measured', 'dB');
            for m = 1 : length(dfCoh)
                %------ Coherent accumulation (10 + 10): ------
                
                sig1Shift = inpSig(1 : cohLen) .*  ...
                                  exp(1j * 2 * pi *...
                                 (-dfCoh(m)) * dt * (1 : cohLen));
                sig2Shift = inpSig(accNum(acc) * lenCA + 1 : ...
                                   accNum(acc) * lenCA + cohLen) .*  ...
                                                      exp(1j * 2 * pi *...
                                 (-dfCoh(m)) * dt * (1 : cohLen));
                                                        
                convRes1 = conv(sig1Shift, fliplr(conj(caCode)), 'valid');
                convRes2 = conv(sig2Shift, fliplr(conj(caCode)), 'valid');
                
                convSum1(m, :) = abs(sum(reshape(convRes1, lenCA, accNum(acc)).'));
                convSum2(m, :) = abs(sum(reshape(convRes2, lenCA, accNum(acc)).'));
                
                
            end
            quality1 = max(max(convSum1)) / mean(mean(convSum1));
            quality2 = max(max(convSum2)) / mean(mean(convSum2));

            if quality1 >= quality2
%                 bodyOfUncertainty = convSum1;
                quality = quality1;
            else 
%                 bodyOfUncertainty = convSum2;
                quality = quality2;
            end
            
            for m = 1 : length(dfNonCoh)
                %------ Non Coh accumulation (20): ------------
                sigShift = inpSig(1 : nonCohLen) .* ...
                           exp(1j * 2 * pi * dt * (-dfNonCoh(m)) * dt * ...
                                            (1 : nonCohLen));
                convRes = abs(conv(sigShift, fliplr(conj(caCode)), 'valid'));
                convSum(m, :) = sum(reshape(convRes, lenCA, 2 * accNum(acc)).');                                                   
            end
            
            maxConv = max(max(convSum));
            meanConv = mean(mean(convSum));
            qualityNonCoh = maxConv / meanConv;
            if quality > threshold(n)
               posCntCoh = posCntCoh + 1; 
            end
            if qualityNonCoh > threshold(n)
               posCntNonCoh = posCntNonCoh + 1; 
            end
            
        end
        fAlProbCoh(acc, n) = posCntCoh / expNum;
        fAlProbNonCoh(acc, n) = posCntNonCoh / expNum;
        
    end
end
figure; plot(threshold, fAlProbCoh.'); grid on;
hold on;
plot(fAlProbNonCoh.'); grid on;
legend('Coh', 'NonCoh');
