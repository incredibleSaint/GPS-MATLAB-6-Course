function Res = P10_NonCohSearchSats(inRes, Params)
%
% ������� ������������ ������ ��������� � �����-������
%
% ������� ����������
%   inRes - ��������� � ������������ ������, ����������� � Main;
%
% �������� ����������
%   Res - ���������, ������� ���������� �� inRes ����������� ������ ����,
%       �������� �������� ���� ���� � ����.

% �������������� �����������
    Res = inRes;

%% ������������� ����������
    Search = struct( ...
        'NumSats',       [], ... % ������, ���������� ��������� ���������
        'SatNums',       [], ... % ������ 1�NumSats � �������� ���������
            ... % ���������
        'SamplesShifts', [], ... % ������ 1�NumSats, ������ ������� -
            ... % ���������� ��������, ������� ����� ���������� � �����-
            ... % ������ �� ������ ������� ������� CA-���� ����������������
            ... % ��������
        'FreqShifts',    [], ... % ������ 1�NumSats �� ���������� ���������
            ... % ������� ��������� ��������� � ��
        'CorVals',       [], ... % ������ 1�NumSats ������������ ��������
            ... % ����� �������������� ������� ������������� �� �������
            ... % ��������, �� ������� ���� ������� ��������
        'AllCorVals',    zeros(1, 32) ... % ������ ������������ ��������
            ... % ���� ����������� ��� �������
    );

%% ��������� ����������
    % ���������� ��������, ����������� ��� �����������.
        NumCA2Search = Params.P10_NonCohSearchSats.NumCA2Search;

    % ������ ����������� ������ ������������� ����������, ��
        CentralFreqs = Params.P10_NonCohSearchSats.CentralFreqs;

    % ����� �����������
        SearchThreshold = Params.P10_NonCohSearchSats.SearchThreshold;

%% ���������� ����������
    Search.NumCA2Search    = NumCA2Search;
    Search.CentralFreqs    = CentralFreqs;
    Search.SearchThreshold = SearchThreshold;

%% ���ר� ����������
    % ���������� ��������������� ��������� ����������
        NumCFreqs = length(CentralFreqs);

    % ����� CA-���� � ������ ������� �������������
        CALen = 1023 * Res.File.R;

%% �������� ����� �������
NumOfShiftedSamples = 0;
NumOfNeededSamples = NumCA2Search * CALen + CALen - 1;
[sig, fileStruct] = ReadSignalFromFile(inRes.File, ...
    NumOfShiftedSamples, NumOfNeededSamples);

Search.NumSats = 0;
for k = 1 : 32
    
    PSC = GenCACode(k);
    PSC = repelem(PSC, Res.File.R);
    PSC = 2 * PSC - 1;
    PSCref = PSC;
    for n = 1 : NumCA2Search -1
        PSCref = [PSCref PSC];
    end
    PSCref = [PSCref PSC(1 : end - 1)];
%     PSCref = [PSC(Res.File.R + 1 : end) PSC];
    %----------------------------------------------
    Fs    = Res.File.R * 1.023e6;
    dt    = 1 / Fs;
    dFmax = 4e3;
    dF    = 10;
    df    = Search.CentralFreqs;
    PSCduration256chips = 1e-3;%10e-3 / 15 / 10; %6.67e-5 (sec)
    PSCsh = zeros(length(df), CALen);
    for m = 1 : length(df)
        PSC_ = sig .* exp(-1j * 2 * pi * df(m) * dt *...
            (0 : length(sig) - 1));
%         PSCtemp = abs((ifft(fft(PSC_) .* conj(fft(sig)))));
        PSCtemp = abs(conv(PSC_, fliplr(conj(PSC)), 'valid'));
        PSCsh(m, :) = sum(reshape(PSCtemp, CALen, NumCA2Search).');
    %     PSCsh(i,:) = abs(conv(PSC_, conj(fliplr(PSC))));
    end
    
    figure;
    ss = surf(PSCsh);
    set(ss,'LineStyle','none');
    %----------------------
    strMax = max(PSCsh, [], 2);
    [peakCCFfreq, indPeakInFreq] = max(strMax);
    %----- Remove a first peak -----------------------------
    %----- Remove a second peak - remove it too ------------
    %----- For more reliable mean(); -----------------------
    [peakCCFtime, indPeakInTimeFirst] = max(PSCsh(indPeakInFreq, :));
%     ccfWithMax = PSCsh(indPeakInFreq, :);
% %     figure;
% %     plot(ccfWithMax);
%     ccfWithMax(indPeakInTimeFirst - Res.File.R : ...
%                 indPeakInTimeFirst + Res.File.R) = 0;
%     meanCCF = mean(ccfWithMax);
% %     figure; plot(ccfWithMax);
%     [peakCCFtime, indPeakInTimeSec] = max(ccfWithMax);
%     ccfWithMax(indPeakInTimeSec - Res.File.R : ...
%                 indPeakInTimeSec + Res.File.R) = 0;
%     figure; plot(ccfWithMax);
    %------ Compute quality of CCF ----------------------------------------
%     quality = 1 - meanCCF / peakCCFfreq;
    ccfMean = mean(mean(PSCsh));
    ccfMax  = max(max(PSCsh));
    quality = ccfMax / ccfMean;
    fprintf("������� �");
    fprintf(num2str(k));
    if quality >= SearchThreshold
        fprintf(" ������\n");
        Search.NumSats = Search.NumSats + 1;
        Search.SatNums = [Search.SatNums k];
        indPeakInTimeFirst = indPeakInTimeFirst -1;
        Search.SamplesShifts = [Search.SamplesShifts indPeakInTimeFirst];
        Search.FreqShifts = [Search.FreqShifts df(indPeakInFreq)];
        Search.CorVals = [Search.CorVals quality];
    else 
        fprintf(" �� ������\n");
    end
    Search.AllCorVals(k) = quality;
    %-------------------------------------
%     HalfNumCA4Sync = 1;
%     HalfCorLen = 1060;
%     sig = ReadSignalFromFile(inRes.File, ...
%                         0, 2.0460e+07);
%                     
%     eplNumber = 2 * HalfCorLen + 1;
%     
%     CA = GenCACode(Res.Search.SatNums);
%     CA = repelem(CA, Res.File.R);
%     CA = 2 * CA - 1;
%     dt = 1 / inRes.File.Fs0;
%             
%     for epl = 1 : eplNumber
%         for m = 1 : HalfNumCA4Sync
%            sigPart = ...
%                     sig(4092+(Res.Search.SamplesShifts(k)    + ... % ��������� ����� �� P10_NonCohSearchSats
%                                      (indCA -1) * CALen + ... % ������ ��������������� CA-����
%                                        (m -1) * CALen)  + ... % ����� ��� ����������
%                                        (1 : CALen)      + ... % ��� ������ CA-����
%                                         epl - 1 - HalfCorLen);% ��������������� ��������/������ �������������
%            sigCorrFreq = sigPart .* exp(1j * 2 * pi * ...
%                (-Res.Search.FreqShifts(k)) * dt * (1 : CALen));
%            corr(indCA, epl) = corr(epl) + ...
%                                        abs(sigCorrFreq * CA.');
% 
%         end
%     end
    %------------------------------------
end
[Search.CorVals, indDesc] = sort(Search.CorVals, 'descend');
Search.SatNums = Search.SatNums(indDesc);
Search.SamplesShifts = Search.SamplesShifts(indDesc);
Search.FreqShifts = Search.FreqShifts(indDesc);

Res.Search = Search;
end