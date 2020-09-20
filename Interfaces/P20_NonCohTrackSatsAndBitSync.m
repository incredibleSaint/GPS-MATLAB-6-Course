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
    for k = 1:Res.Search.NumSats
        % ������ ���������
            fprintf('%s     ������� �������� �%02d (%d �� %d) ...\n', ...
                datestr(now), Res.Search.SatNums(k), k, ...
                Res.Search.NumSats);
            
            ...
                
        % ������ ���������
            fprintf('%s         ���������.\n', datestr(now));
    end
    % ������� ����� ���� � ������������ � Res
        Res.Track = Track;

    % ������ ���������
        fprintf('%s     ���������.\n', datestr(now));    

%% �������� ����� ������� - ������� �������������