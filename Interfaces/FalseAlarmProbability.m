% РџРѕСЃС‚СЂРѕРµРЅРёРµ РєСЂРёРІС‹С… РІРµСЂРѕСЏС‚РЅРѕСЃС‚Рё Р»РѕР¶РЅРѕР№ С‚СЂРµРІРѕРіРё РІ Р·Р°РІРёСЃРёРјРѕСЃС‚Рё РѕС‚ РїРѕСЂРѕРіР°
fprintf("РќР°С‡Р°Р»Рѕ Р›РѕР¶РЅРѕР№ С‚СЂРµРІРѕРіРё")
profile on;
tic
expNum = 1e6;
accNum = [10];
EbN0 = -25;
threshold = [0 : 0.1 : 8];

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
    posCntCoh    = zeros(1, length(threshold));
    posCntNonCoh = zeros(1, length(threshold));
%     for n = 1 : length(threshold)

        for k = 1 : expNum
            % Input signal (false signal):
            randSig = randi([0 1], 1, nonCohLen);
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

            convSum1 = convSum1 / mean(mean(convSum1));
            convSum2 = convSum2 / mean(mean(convSum2));
            
%             posCntCoh = posCntCoh + sum(sum(convSum1 > threshold(n))) + ...
%                                     sum(sum(convSum2 > threshold(n)));
            
%             if quality1 >= quality2
% %                 bodyOfUncertainty = convSum1;
%                 quality = quality1;
%             else 
% %                 bodyOfUncertainty = convSum2;
%                 quality = quality2;
%             end
            
            for m = 1 : length(dfNonCoh)
                %------ Non Coh accumulation (20): ------------
                sigShift = inpSig(1 : nonCohLen) .* ...
                           exp(1j * 2 * pi * dt * (-dfNonCoh(m)) * dt * ...
                                            (1 : nonCohLen));
                convRes = abs(conv(sigShift, fliplr(conj(caCode)), 'valid'));
                convSum(m, :) = sum(reshape(convRes, lenCA, 2 * accNum(acc)).');                                                   
            end
            convSum = convSum / mean(mean(convSum));
            
            for n = 1 : length(threshold)
                posCntCoh(n) = posCntCoh(n) + ...
                                    sum(sum(convSum1 > threshold(n))) + ...
                                        sum(sum(convSum2 > threshold(n)));

                posCntNonCoh(n) = posCntNonCoh(n) + ...
                                          sum(sum(convSum > threshold(n)));
            end
%             maxConv = max(max(convSum));
%             meanConv = mean(mean(convSum));
%             qualityNonCoh = maxConv / meanConv;

%             if quality > threshold(n)
%                posCntCoh = posCntCoh + 1; 
%             end
%             if qualityNonCoh > threshold(n)
%                posCntNonCoh = posCntNonCoh + 1; 
%             end
            
        end
        fAlProbCoh(acc, :) = posCntCoh / (2 * expNum * lenCA * length(dfCoh));
        fAlProbNonCoh(acc, :) = posCntNonCoh / (expNum * lenCA * ...
                                                        length(dfNonCoh));
        
%     end
end
figure; plot(threshold, fAlProbCoh, '.-', 'MarkerSize', 15); grid on;
hold on;
plot(threshold, fAlProbNonCoh, '.-', 'MarkerSize', 15);
f = gca;
f.YScale = 'log';
xlabel("РџРѕСЂРѕРі, Max / Mean");
title("Р’РµСЂРѕСЏС‚РЅРѕСЃС‚СЊ Р»РѕР¶РЅРѕР№ С‚СЂРµРІРѕРіРё");
legend('Coh', 'NonCoh');
toc
profile viewer