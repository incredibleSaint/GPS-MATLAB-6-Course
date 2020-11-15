figure; 
lenCA = 1023;
accNum = [10];
freqMax = 5e3;
freqStep = 1e3;
threshold = [0 : 0.1 : 8];
dfCoh    = -freqMax : freqStep / accNum : freqMax;
    dfNonCoh = -freqMax : freqStep : freqMax;
fAlProbCoh(1, :) = (posCntCoh + posCntCohNow) / (2 * (k + kNow) * lenCA * length(dfCoh));
        fAlProbNonCoh(1, :) = (posCntNonCoh + posCntNonCohNow) / ((k + kNow) * lenCA * ...
                                                        length(dfNonCoh));
plot(threshold, fAlProbCoh, '.-', 'MarkerSize', 15); grid on;
hold on;
plot(threshold, fAlProbNonCoh, '.-', 'MarkerSize', 15);
f = gca;
f.YScale = 'log';