function Res = P20_NonCohTrackSatsAndBitSync(inRes, Params)
%
% ������� �������������� �������� ��������� � ������� �������������
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
    Track = struct( ...
        'SamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',       {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������ cell-�������� SamplesShifts � CorVals �������� ��������
    %   1xN, ��� N - ���������� �������� CA-���� ���������������� ��������,
    %   ��������� � �����-������ (N ����� ���� ������ ��� ������
    %   ���������).
    % ������ ������� ������� SamplesShifts{k} - ���������� ��������,
    %   ������� ���� ���������� � �����-������ �� ������ ����������������
    %   ������� CA-����.
    % ������ ������� ������� CorVals{k} - ����������� �������� ����������
    %   ����� �������, ���������� ��������������� ������ CA-����, � �������
    %   ��������.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % ������ ������� ������� CAShifts - ���������� �������� CA-����,
    %   ������� ���� ���������� �� ������ ����.
    % ������ ������ ������� Cors - ����������, �� ������� �������� �������
    %   ������������ ������� �������������.

%% ��������� ����������
    % ���������� �������� CA-���� ����� ��������� ��������������� ��
    % ������� (NumCA2NextSync >= 1, NumCA2NextSync = 1 - ������������� ���
    % ������� CA-����)
        NumCA2NextSync = Params.P20_NonCohTrackSatsAndBitSync.NumCA2NextSync;

    % �������� ���������� �������������� �������� CA-����, ������������ ���
    % ������������� �� �������
        HalfNumCA4Sync = Params.P20_NonCohTrackSatsAndBitSync.HalfNumCA4Sync;

    % ���������� ����������� �������� ��������/������ ������������� ��
    % �������
        HalfCorLen = Params.P20_NonCohTrackSatsAndBitSync.HalfCorLen;

    % ������, � ������� ������������ ����������� ����� ������������
    % CA-�����
        NumCA2Disp = Params.P20_NonCohTrackSatsAndBitSync.NumCA2Disp;

    % ������������ ����� �������������� CA-����� (inf - �� ����� �����!)
        MaxNumCA2Process = Params.P20_NonCohTrackSatsAndBitSync.MaxNumCA2Process;

    % ���������� ���, ������������ ��� ������� �������������
        NBits4Sync = Params.P20_NonCohTrackSatsAndBitSync.NBits4Sync;

%% ���������� ����������
    Track.NumCA2NextSync   = NumCA2NextSync;
    Track.HalfNumCA4Sync   = HalfNumCA4Sync;
    Track.HalfCorLen       = HalfCorLen;
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% ���ר� ����������
    % ����� CA-���� � ������ ������� �������������
        CALen = 1023 * Res.File.R;

    % ���������� �������� CA-����, ������������ �� ���� ���
        CAPerBit = 20;

%% �������� ����� ������� - �������
    % ������ ���������
        fprintf('%s ������� ���������\n', datestr(now));
    NumOfShiftedSamples = 0;
    necessMin = (MaxNumCA2Process + HalfNumCA4Sync * 2 + 2) * CALen;

    if Res.File.SamplesLen > necessMin && MaxNumCA2Process ~= Inf
        NumOfNeededSamples = necessMin;
    else
        NumOfNeededSamples = Res.File.SamplesLen;
        MaxNumCA2Process   = floor(Res.File.SamplesLen / CALen - 2);
    end

    sig = ReadSignalFromFile(inRes.File, ...
                        NumOfShiftedSamples, NumOfNeededSamples);
                    
    eplNumber = 2 * HalfCorLen + 1;
    
    for k = 1 : Res.Search.NumSats
        % ������ ���������
        fprintf('%s     ������� �������� �%02d (%d �� %d) ...\n', ...
            datestr(now), Res.Search.SatNums(k), k, ...
            Res.Search.NumSats);

        CA = GenCACode(Res.Search.SatNums(k));
        CA = repelem(CA, Res.File.R);
        CA = 2 * CA - 1;
        dt = 1 / inRes.File.Fs0;
        
        cnt = 0;     % ������� ������������ ��-�����
                     % � ������� ��������� �������������
        dShift = 0;  % ������� ����� ������������� ���������� ����������
        syncCnt = 0; % ������� �������������
        
        syncCorr = zeros(floor(MaxNumCA2Process / NumCA2NextSync), ...
                                                                eplNumber);
        synchrCorrInd = zeros(1, MaxNumCA2Process);
        corr    = zeros(1, MaxNumCA2Process);
        corrAbs = zeros(1, MaxNumCA2Process);
        phaseCA = zeros(1, MaxNumCA2Process);
        samplesShifts = zeros(1, MaxNumCA2Process);
        
        for indCA = 1 : MaxNumCA2Process
            sigPart = ...
                    sig((Res.Search.SamplesShifts(k)     + ... % ��������� ����� �� P10_NonCohSearchSats.m
                                     (indCA -1) * CALen  + ... % ������ ��������������� CA-����
                                             (1 : CALen) + ... % ��� ������ CA-����
                                                    dShift )); % ����� �������������
            sigCorrFreq = sigPart .* exp(1j * 2 * pi * ...
               (-Res.Search.FreqShifts(k)) * dt * (1 : CALen));
            corr(indCA) = sigCorrFreq * CA.';
            phaseCA(indCA) = angle(corr(indCA)) / pi;
            corrAbs(indCA) = abs(corr(indCA));

            cnt = cnt + 1;
            if cnt == NumCA2NextSync % it's time for synchronization
                cnt = 0;
                syncCnt =  syncCnt + 1;
                
                for epl = 1 : eplNumber
                    for m = 1 : 2 * HalfNumCA4Sync % accumulation cycle
                       sigPart =  sig((Res.Search.SamplesShifts(k) + ... % ��������� ����� �� P10_NonCohSearchSats.m
                                               (indCA -1) * CALen  + ... % ������ ��������������� CA-����
                                                   (m -1) * CALen) + ... % ����� ��� ����������
                                                       (1 : CALen) + ... % ��� ������ CA-����
                                                            dShift + ... % ����� �������������
                                                   epl - 1 - HalfCorLen);% ��������������� ��������/������ �������������
                       sigCorrFreq = sigPart .* exp(1j * 2 * pi * ...
                           (-Res.Search.FreqShifts(k)) * dt * (1 : CALen));
                       syncCorr(syncCnt, epl) = syncCorr(syncCnt, epl) + ...
                                                   abs(sigCorrFreq * CA.');
                    end
                end
                                           
               [~, maxInd] = max(syncCorr(syncCnt, :));
               if maxInd ~= eplNumber - HalfCorLen % do a synchr shift
                   dShift = dShift + maxInd - (eplNumber - HalfCorLen);
               end
                           
            end
            synchrCorrInd(indCA) = dShift;
            samplesShifts(indCA) = Res.Search.SamplesShifts(k) + dShift + ...
                                                       (indCA - 1) * CALen;
        end
        %---- Save Results ----
        Track.SamplesShifts{k, 1} = samplesShifts;
        Track.CorVals{k, 1}       = corr;
        %---- Plot Results ----
        figure;
        subplot(3, 1, 1);
        plot(corrAbs, '.-');
        hold on;
        p = plot(corrAbs, '.', 'MarkerIndices', ...
                                    1 : NumCA2NextSync : length(phaseCA));
        p.MarkerSize = 15;
        p.MarkerEdgeColor = 'g';
        grid on;
        strBelow = ['������ ���������� � �A-������ ��� �������� �', ...
                                          num2str(Res.Search.SatNums(k))];
        str = {'������������� �������', strBelow};
        title(str);
        xlabel('����� ������������� CA-����');
        
        subplot(3, 1, 2);
        p = plot(phaseCA, '.');
        p.MarkerSize = 5;
        hold on; 
        p = plot(phaseCA, '.', 'MarkerIndices', ...
                                    1 : NumCA2NextSync : length(phaseCA));
        p.Color = [0 1 0];
        p.MarkerSize = 15;
        grid on;
        title(['���� ���������� � ��������� ��-���� ��� �������� �', ...
                                          num2str(Res.Search.SatNums(k))]);
        xlabel('����� ������������� CA-����');
        ylabel('����, \pi');                              
        
        subplot(3, 1, 3);
        plot(synchrCorrInd, 'Marker', '.');
        grid on;
        hold on;
        p = plot(synchrCorrInd, '.', 'MarkerIndices', ...
                                    1 : NumCA2NextSync : length(phaseCA));
        p.MarkerSize = 15;
        p.MarkerEdgeColor = 'g';
        title(['������ ������������� ����� ������������� ��� �������� �', ...
                                          num2str(Res.Search.SatNums(k))]);
        xlabel('����� ������������� CA-����');
        ylabel('����� � �������� F_{s0}');
        % ������ ���������
            fprintf('%s         ���������.\n', datestr(now));
    end
    % ������� ����� ���� � ������������ � Res
    Res.Track = Track;

    % ������ ��������� 
        fprintf('%s     ���������.\n', datestr(now));    

%% �������� ����� ������� - ������� �������������