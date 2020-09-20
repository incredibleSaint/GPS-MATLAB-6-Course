function Params = Setup()

% Main
    % ����� ���������, � ������� ���� ������ ���������� Main
        Main.StartProcNum = 1; %  1 <= StartProcNum <= length(FuncNames)

    % ����� ���������, �� ������� ���� ��������� ���������� Main
        Main.StopProcNum = 7; %  1 <= StopProcNum <= length(FuncNames) �
            % StartProcNum <= StopProcNum

	% ����� ���� ��������� - ��������������� ��� StartProcNum = 1, �����
	%   �� ���� �������� ��������� � ����������
    % 'Coh'/'NonCoh' - ����������� ��������� / ������������� ���������
        Main.ProcessType = 'NonCoh';

    % ���� ������������� ���������� �����������
        Main.isDraw = 3; % 0 - �� ��������; 1 - ��������; 2 - �������� �
            % ���������; 3 - ��������, ��������� � ���������

    % ����� ����� �����-������
        % ���������� � �������-��������
            Main.SigDirName = 'C:\Users\Incredible\Desktop\Studies\Programming\MATLAB\NIR\GPS\Signal';
        % ��� �����-������
            Main.SigFileName = '30_08_2018__19_38_33_x02_1ch_16b_15pos_90000ms.dat';

    % ��� ����� ��� �������� �����������
    % ���� StartProcNum = 1, �� �� ���� ������ ���������
        Main.LoadFileName = 'Rate2';

    % ��� ����� ��� ���������� �����������
        Main.SaveFileName = 'Rate2';

    % ���������� ��� ���������� �����������
        Main.SaveDirName = 'Results_Rate2_NonCoh';

    % ��������� ��������� �����-������
        Main.HeadLenInBytes = 0;
        Main.NumOfChannels  = 1;
        Main.ChanNum        = 0;
        Main.DataType       = 'int16';
        Main.Fs0            = 2.046*10^6;
        Main.dF             = 0;
        Main.FsDown         = 1;
        Main.FsUp           = 1;

% P10_NonCohSearchSats
    % ���������� ��������, ����������� ��� �����������.
        P10_NonCohSearchSats.NumCA2Search = 20;
    % ������ ����������� ������ ������������� ����������, ��
        P10_NonCohSearchSats.CentralFreqs = -6000 : 1000 : 6000;
    % ����� �����������
        P10_NonCohSearchSats.SearchThreshold = 3.0;

% P10_CohSearchSats
    % ���������� ��������, ����������� ��� �����������.
    % ��� ������������ ����������� 1 <= NumCA2Search <= 10
        P10_CohSearchSats.NumCA2Search = 10;
    % ������ ����������� ������ ������������� ����������, ��
        P10_CohSearchSats.CentralFreqs = -6000 : ...
            1000/P10_CohSearchSats.NumCA2Search : 6000;
    % ����� �����������
        P10_CohSearchSats.SearchThreshold = 10;

% P20_NonCohTrackSatsAndBitSync
    % ���������� �������� CA-���� ����� ��������� ��������������� ��
    % ������� (NumCA2NextSync >= 1, NumCA2NextSync = 1 - ������������� ���
    % ������� CA-����)
        P20_NonCohTrackSatsAndBitSync.NumCA2NextSync = 100;

    % �������� ���������� �������������� �������� CA-����, ������������ ���
    % ������������� �� �������
        P20_NonCohTrackSatsAndBitSync.HalfNumCA4Sync = 10;

    % ���������� ����������� �������� ��������/������ ������������� ��
    % �������
        P20_NonCohTrackSatsAndBitSync.HalfCorLen = 2;

    % ������, � ������� ������������ ����������� ����� ������������
    % CA-�����
        P20_NonCohTrackSatsAndBitSync.NumCA2Disp = 5*10^3;

    % ������������ ����� �������������� CA-����� (inf - �� ����� �����!)
        P20_NonCohTrackSatsAndBitSync.MaxNumCA2Process = inf;

    % ���������� ���, ������������ ��� ������� �������������
        P20_NonCohTrackSatsAndBitSync.NBits4Sync = 100;

% P20_CohTrackSatsAndBitSync
    % ������� ��������
        P20_CohTrackSatsAndBitSync.DLL.FilterOrder = 2;
        P20_CohTrackSatsAndBitSync.FPLL.FilterOrder = [2, 3];

    % � DLL � FPLL ����� ��������� ������� ������ ��� ������� �� ��� �����
    % ����������
        % ������ ��������
            P20_CohTrackSatsAndBitSync.DLL.FilterBands  = [0.05; 0.05; ...
                0.05; 0.05];
            P20_CohTrackSatsAndBitSync.FPLL.FilterBands = [ ...
                5, 5; ...
                5, 5; ...
                5, 5; ...
                2, 2];

        % ���������� �������� ���������� ��� ����������
            P20_CohTrackSatsAndBitSync.DLL.NumsIntCA  = [4, 10, 20, 20];
            P20_CohTrackSatsAndBitSync.FPLL.NumsIntCA = [4, 10, 20, 20];

	% ��������� ���������� �������� CA-����, ����������� ��� ��������
	% ������������� �������� ����� ����������� DLL � FPLL. ��������
	% �������� �� �������� integrate and dump
        P20_CohTrackSatsAndBitSync.DLL.NumsCA2CheckState  = [100, 100, ...
            100, 100];
        P20_CohTrackSatsAndBitSync.FPLL.NumsCA2CheckState = [100, 100, ...
            100, 100];

    % ��������� �������� ��� �������� ����� �����������
    % ���� �������� > HiTr, �� ��������� � ��������� (����� ���������)
    %   ���������
    % ���� �������� < LoTr, �� ��������� � ���������� (�����
    %   ��������������)���������
        P20_CohTrackSatsAndBitSync.DLL.HiTr = [0.5 0.5 0.5 0.5];
        P20_CohTrackSatsAndBitSync.DLL.LoTr = [0.05 0.05 0.05 0.05];

        P20_CohTrackSatsAndBitSync.FPLL.HiTr = [0.5 0.5 0.5 0.5];
        P20_CohTrackSatsAndBitSync.FPLL.LoTr = [0.05 0.05 0.05 0.05];

    % ������, � ������� ������������ ����������� ����� ������������
    % CA-�����
        P20_CohTrackSatsAndBitSync.NumCA2Disp = 5*10^3;

    % ������������ ����� �������������� CA-����� (inf - �� ����� �����!)
        P20_CohTrackSatsAndBitSync.MaxNumCA2Process = inf; % inf;

    % ���������� ���, ������������ ��� ������� �������������
        P20_CohTrackSatsAndBitSync.NBits4Sync = 100;

% P30_NonCohDemodSatsSigs
    P30_NonCohDemodSatsSigs = [];

% P30_CohDemodSatsSigs
    P30_CohDemodSatsSigs = [];

% P40_GetSubFrames
    P40_GetSubFrames = [];

% P50_ParseSubFrames
    P50_ParseSubFrames = [];

% P60_GatherSatsEphemeris
    P60_GatherSatsEphemeris = [];
    
% P70_GetRXPoses
    % ��� � �������� CA-���� ����� ��������� ������������ ���������. �����
    % � �������� 6000 �������� CA-����, �������, ��������, CAStep = 1000
    % ������� � ���������� 6 ��������� �� ���� �������.
        P70_GetRXPoses.CAStep = 600;

    % ������� ���������� ���������.
    % isCommonRxTime = 1 - ���������� ��������� ����������� � ����������
    %   ������  ������� ��������, ��������������� ������ ������
    %   ������� GPS
    % isCommonRxTime = 0 - ���������� ��������� ����������� � ������
    %   ������� ������� ��������, ��������������� ���������� �����
    %   ������� GPS
        P70_GetRXPoses.isCommonRxTime = 1;

    % ���������� ������ ���������, ����������� ��� ���������� ���������:
    % 'all' - ��� ��������;
    % 'firstX' - ������ � ���������, �������� 'first5';
    % [1, 2, 5, 7] - ���������� ������.
        P70_GetRXPoses.SatNums2Pos = 'first6';

% P71_GetOneRXPos
    % ������������ ����� ��������
        P71_GetOneRXPos.MaxNumIters = 100;
    % ������������ ��������� ��������� ������������ ����� ���������
    % ���������� (�). ���� ����������� ��������� ������, �� ����
    % ���������������
        P71_GetOneRXPos.MaxDelta = 0.1;

% P72_GetSatPos
    P72_GetSatPos = [];

% P73_RenewSatPos
    P73_RenewSatPos = [];

% P74_Cartesian2Spherical
    P74_Cartesian2Spherical.AlgType = 0;
        % 0 - �� ��������� ��
        % 1 - �� �����

    P74_Cartesian2Spherical.EllipseType = 0;
        % 0 - WGS84
        % 1 - ��-90
        % 2 - ���������� - 1942

% P75_CalculateSatElAz
    P75_CalculateSatElAz = [];

% P76_ExportResults
    % ����� �� ��������� ����� ������� ��������
        P76_ExportResults.isSaveUserPoses = 1;
    % ����� �� ��������� ����� ������� ���������
        P76_ExportResults.isSaveSatsPoses = 0;
    % ����� �� ��������� ��� ��������� ��������
        P76_ExportResults.isCalcCoordinatesVariance = 1;
    % ����� �� ���������� ����� ������� ��������
        P76_ExportResults.isNumerateLabels = 1;
    % ��� ����� ��� ���������� �����������
        P76_ExportResults.FileName = 'Res.kml';

% �������� ��� ��������� � ���������
    Params = struct( ...
        'Main', Main, ...
        'P10_NonCohSearchSats', P10_NonCohSearchSats, ...
        'P10_CohSearchSats', P10_CohSearchSats, ...
        'P20_NonCohTrackSatsAndBitSync', P20_NonCohTrackSatsAndBitSync, ...
        'P20_CohTrackSatsAndBitSync', P20_CohTrackSatsAndBitSync, ...
        'P30_NonCohDemodSatsSigs', P30_NonCohDemodSatsSigs, ...
        'P30_CohDemodSatsSigs', P30_CohDemodSatsSigs, ...
        'P40_GetSubFrames', P40_GetSubFrames, ...
        'P50_ParseSubFrames', P50_ParseSubFrames, ...
        'P60_GatherSatsEphemeris', P60_GatherSatsEphemeris, ...
        'P70_GetRXPoses', P70_GetRXPoses, ...
        'P71_GetOneRXPos', P71_GetOneRXPos, ...
        'P72_GetSatPos', P72_GetSatPos, ...
        'P73_RenewSatPos', P73_RenewSatPos, ...
        'P74_Cartesian2Spherical', P74_Cartesian2Spherical, ...
        'P75_CalculateSatElAz', P75_CalculateSatElAz, ...
        'P76_ExportResults', P76_ExportResults ...
        );