% Построение кривых вероятности ложной тревоги в зависимости от порога
expNum = 1e4;
accNum = 2;
EbN0 = 0;
df = -5e3 : 1e3 : 5e3;
caCode = GenCACode(1);
caCode = 2 * caCode - 1;
lenCA = length(caCode);
snr = EbN0 - 10 * log10(length(lenCA));
Fs = 1.023e6;
dt = 1 / Fs;
convSum = zeros(length(df), lenCA);
threshold = [0.5 0.8];
for n = 1 : length(threshold)
    for k = 1 : expNum
        for m = 1 : length(df)
            % Input signal (false signal):
            randSig = randi([0 1], 1, accNum * lenCA + lenCA - 1);
            randSig = 2 * randSig - 1;
            inpSig = awgn(randSig, snr + 3, 'measured', 'dB');

            sigShift = inpSig .* exp(1j * 2 * pi * (-df(m)) * dt * ...
                                                        (1 : length(randSig)));
            convRes = conv(sigShift, fliplr(conj(caCode)), 'valid');
            convSum(m, :) = abs(sum(reshape(convRes, lenCA, accNum).'));
        end

    end
end
