% Построение кривых вероятности правильного обнаружения в зависимости от
% ОСШ
tic
% profile on;
expNum = 1e4;
accNum = [10];
EbN0 = [-40 -30 -26 -25 -24 -22 -20 -18];%[ -26 -25 -24];
thresholdCoh = [3 5 10];
thresholdNonCoh = [2 3 5];

freqMax = 1e3;
freqStep = 1e3;

caCode = GenCACode(1);
caCode = 2 * caCode - 1; 
lenCA = length(caCode);
caCodeLong = caCode;
for k = 1 : 2 * accNum
    caCodeLong = [caCodeLong caCode];
end

snr = EbN0 - 10 * log10(length(lenCA));
Fs = 1.023e6;
dt = 1 / Fs;

corrDetProbCoh = zeros(length(snr), length(thresholdCoh));
corrDetProbNonCoh = zeros(length(snr), length(thresholdCoh));


for indSnr = 1 : length(snr)

	cohLen = accNum * lenCA + lenCA - 1;
	nonCohLen = 2 * accNum * lenCA + lenCA - 1;
	
	dfCoh    = 0;%-freqMax : freqStep / accNum : freqMax;
	dfNonCoh = 0;%-freqMax : freqStep : freqMax;
	
	convSum1 = zeros(length(dfCoh)   , lenCA);
	convSum2 = zeros(length(dfCoh)   , lenCA);
	convSum  = zeros(length(dfNonCoh), lenCA);
	
 		posCntCoh    = zeros(1, length(thresholdCoh));
 		posCntNonCoh = zeros(1, length(thresholdNonCoh));
		for k = 1 : expNum
			% Input signal (false signal):
			inpSig = awgn(caCodeLong, snr(indSnr) + 3, 'measured', 'dB');
% 			for m = 1 : length(dfCoh)
% 				%------ Coherent accumulation (10 + 10): ------
% 				
% 				sig1Shift = inpSig(1 : cohLen) ;%.*  ... because df = 0
% % 								  exp(1j * 2 * pi *...
% % 								 (-dfCoh(m)) * dt * (1 : cohLen));
% 				sig2Shift = inpSig(accNum * lenCA + 1 : ...
% 								   accNum * lenCA + cohLen); % .*  ...
% % 													  exp(1j * 2 * pi *...
% % 								 (-dfCoh(m)) * dt * (1 : cohLen));
% 														
% 				convRes1 = conv(sig1Shift, fliplr(conj(caCode)), 'valid');
% 				convRes2 = conv(sig2Shift, fliplr(conj(caCode)), 'valid');
% 				
% 				convSum1(m, :) = abs(sum(reshape(convRes1, lenCA, accNum).'));
% 				convSum2(m, :) = abs(sum(reshape(convRes2, lenCA, accNum).'));
% 				
% 				
% 			end
			
			
% 			for m = 1 : length(dfNonCoh)
				%------ Non Coh accumulation (20): ------------
				sigShift = inpSig(1 : nonCohLen) ; %.* ...
% 						   exp(1j * 2 * pi * dt * (-dfNonCoh(m)) * dt * ...
% 											(1 : nonCohLen));
				convRes = (conv(sigShift, fliplr(conj(caCode)), 'valid'));
				convSum(m, :) = sum(reshape(abs(convRes), lenCA, 2 * accNum).');                                                   
% 			end
			% Coh conv:
            convSum1 = abs(sum(reshape(convRes(1 : lenCA * accNum), ...
                                                        lenCA, accNum).'));
                                                    
            convSum2 = abs(sum(reshape(convRes(1 + lenCA * accNum : ...
                                               lenCA * 2 * accNum), ...
                                                        lenCA, accNum).'));
                                    
            quality1 = max(max(convSum1)) / mean(mean(convSum1));
			quality2 = max(max(convSum2)) / mean(mean(convSum2));

			if quality1 >= quality2
%                 bodyOfUncertainty = convSum1;
				quality = quality1;
			else 
%                 bodyOfUncertainty = convSum2;
				quality = quality2;
			end
            %--------------
			maxConv = max(max(convSum));
			meanConv = mean(mean(convSum));
			qualityNonCoh = maxConv / meanConv;
            
            for n = 1 : length(thresholdCoh)
                if quality > thresholdCoh(n)
                    posCntCoh(n) = posCntCoh(n) + 1; 
                end
                if qualityNonCoh > thresholdNonCoh(n)
                   posCntNonCoh(n) = posCntNonCoh(n) + 1; 
                end
            end
			
			
		end
		corrDetProbCoh(indSnr, :) = posCntCoh / expNum;
		corrDetProbNonCoh(indSnr, :) = posCntNonCoh / expNum;
		
end
fig = figure; p1 = plot(EbN0, corrDetProbCoh, '.-', 'MarkerSize', 15);
% f = gca;
% f.YScale = 'log';
grid on;
title("Вероятность правильного обнаружения");
hold on;
xlabel('E_b/N_0, dB')
plot(EbN0, corrDetProbNonCoh); grid on;
%--- Legend ------------

for k = 1 : length(thresholdCoh)
    str = ['Coh,    threshold = ' num2str(thresholdCoh(k))];
    coefStr(k, 1 : length(str)) = str;
end
for k = 1 : length(thresholdNonCoh)
    str = ['NonCoh, threshold = ' num2str(thresholdNonCoh(k))];
    coefStr(length(thresholdCoh) + k, 1 : length(str)) = str;                                            
end
legend(coefStr);
[status, msg, msgId] = mkdir('MyResults');
cd MyResults;
savefig(fig, 'CorrDetProbV2.fig');
cd ..
% legend('Coh', 'Coh', 'NonCoh', 'NonCoh');
toc
% profile viewer