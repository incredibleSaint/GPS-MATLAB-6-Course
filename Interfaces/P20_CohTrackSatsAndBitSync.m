  function Res = P20_CohTrackSatsAndBitSync(inRes, Params)
%
% ������� ������������ �������� ��������� � ������� �������������
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
        'SamplesShifts',     {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',           {cell(Res.Search.NumSats, 1)}, ...
        'HardSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'FineSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'EPLCorVals',        {cell(Res.Search.NumSats, 1)}, ...
        'DLL',               {cell(Res.Search.NumSats, 1)}, ...
        'FPLL',              {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������ cell-�������� SamplesShifts, CorVals, HardSamplesShifts
    %   FineSamplesShifts �������� �������� 1xN, ��� N - ����������
    %   �������� CA-���� ���������������� ��������, ��������� � �����-
    %   ������ (N ����� ���� ������ ��� ������ ���������).
    % ������ ������� ������� SamplesShifts{k} - ������� ����������
    %   ��������, ������� ���� ���������� � �����-������ �� ������
    %   ���������������� ������� CA-����.
    % ������ ������� ������� CorVals{k} - ����������� �������� ����������
    %   ����� �������, ���������� ��������������� ������ CA-����, � �������
    %   ��������.
    % ������ ������� �������� HardSamplesShifts{k}, FineSamplesShifts{k} -
    %   �������������� ������� � ����� ����� �������� SamplesShifts{k}.
    % ������ ������ cell-������� EPLCorVals �������� �������� 3xN ��������
    %   Early, Promt � Late ����������. ��� ����: SamplesShifts{k} =
    %   EPLCorVals{k}(2, :).
    % DLL, FPLL - ��� ������������� ���� ���� � �������-���� �������.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % ������ ������� ������� CAShifts - ���������� �������� CA-����,
    %   ������� ���� ���������� �� ������ ����.
    % ������ ������ ������� Cors - ����������, �� ������� �������� �������
    %   ������������ ������� �������������.

%% ��������� ����������
    % ������� ��������
        DLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.DLL.FilterOrder;
        FPLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterOrder;
        
    % � DLL � FPLL ����� ��������� ������� ������ ��� ������� �� ��� �����
    % ����������
        % ������ ��������
            DLL.FilterBands  = Params.P20_CohTrackSatsAndBitSync.DLL.FilterBands;
            FPLL.FilterBands = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterBands;
            
        % ���������� �������� ���������� ��� ����������
            DLL.NumsIntCA  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsIntCA;
            FPLL.NumsIntCA = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsIntCA;

	% ��������� ���������� �������� CA-����, ����������� ��� ��������
	% ������������� �������� ����� ����������� DLL � FPLL. ��������
	% �������� �� �������� integrate and dump
        DLL.NumsCA2CheckState  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsCA2CheckState;
        FPLL.NumsCA2CheckState = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsCA2CheckState;
        
    % ��������� �������� ��� �������� ����� �����������
    % ���� �������� > HiTr, �� ��������� � ��������� (����� ���������)
    %   ���������
    % ���� �������� < LoTr, �� ��������� � ���������� (�����
    %   ��������������)���������
        DLL.HiTr = Params.P20_CohTrackSatsAndBitSync.DLL.HiTr;
        DLL.LoTr = Params.P20_CohTrackSatsAndBitSync.DLL.LoTr;
        
        FPLL.HiTr = Params.P20_CohTrackSatsAndBitSync.FPLL.HiTr;
        FPLL.LoTr = Params.P20_CohTrackSatsAndBitSync.FPLL.LoTr;

    % ������, � ������� ������������ ����������� ����� ������������
    % CA-�����
        NumCA2Disp = Params.P20_CohTrackSatsAndBitSync.NumCA2Disp;

    % ������������ ����� �������������� CA-����� (inf - �� ����� �����!)
        MaxNumCA2Process = Params.P20_CohTrackSatsAndBitSync.MaxNumCA2Process;

    % ���������� ���, ������������ ��� ������� �������������
        NBits4Sync = Params.P20_CohTrackSatsAndBitSync.NBits4Sync;

%% ���������� ����������
    % Track.FPLL = FPLL; % �� �����, ��� ��� �� ����� ����� ������� �
    % Track.DLL = DLL;   % �����
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% ���ר� ����������
    % ����� CA-���� � ������ ������� �������������
        CALen = 1023 * Res.File.R;

    % ���������� �������� CA-����, ������������ �� ���� ���
        CAPerBit = 20;

    % ������������ CA-����, ��
        TCA = 10^-3;

%% �������� ����� ������� - ������� � ������� �������������