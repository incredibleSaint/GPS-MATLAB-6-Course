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
        MaxNumCA2Process = Res.File.SamplesLen / CALen - 2;
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
            
            
            corr = zeros(MaxNumCA2Process, eplNumber);
            for indCA = 1 : MaxNumCA2Process
                for epl = 1 : eplNumber
                    for m = 1 : HalfNumCA4Sync
                       sigPart = ...
                                sig((Res.Search.SamplesShifts(k)    + ... % ��������� ����� �� P10_NonCohSearchSats
                                NumCA2NextSync * (indCA -1) * CALen + ... % ������ ��������������� CA-����
                                                   (m -1) * CALen)  + ... % ����� ��� ����������
                                                   (1 : CALen)      + ... % ��� ������ CA-����
                                                    epl - 1 - HalfCorLen);% ��������������� ��������/������ �������������
                       sigCorrFreq = sigPart .* exp(1j * 2 * pi * ...
                           (-Res.Search.FreqShifts(k)) * dt * (1 : CALen));
                       corr(indCA, epl) = corr(indCA, epl) + ...
                                                   abs(sigCorrFreq * CA.');

                    end
                end
            end
            figure;
            surf((corr));
                
        % ������ ���������
            fprintf('%s         ���������.\n', datestr(now));
    end
    % ������� ����� ���� � ������������ � Res
        Res.Track = Track;

    % ������ ���������
        fprintf('%s     ���������.\n', datestr(now));    

%% �������� ����� ������� - ������� �������������