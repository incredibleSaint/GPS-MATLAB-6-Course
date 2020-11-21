function Res = P70_GetRXPoses(inRes, Params)
%
% ������� ����� ������������� ���������� ��� ���������, � ������� ����
% ������� ���� �� ���� �������� TOW_Count_Message
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
    % Positioning = struct(  ...
    %   'RX+Poses', cell(N, M), ...
    %   'CAStep', CAStep, ...
    %   'isCommonRxTime', isCommonRxTime ...
    % );
    
    % ���������� ����� N cell-������� RXPoses ��������� � �����������
    %   ��������� ��������� � ����������� ���������� TOW. ����������
    %   �������� ������������ ����������� ���������� ��������� ��
    %   ������������ ������ �������� � ������� �� ��������� CAStep,
    %   ������������� ����.
    % CAStep - ��� � �������� CA-���� ����� ��������� ������������
    %   ���������.
    % isCommonRxTime - ��������, ������������ ��� ��������� ���������
    %   ���������: � ���� ����� �������� ��� � ������.

%% ��������� ����������
    % ��� � �������� CA-���� ����� ��������� ������������ ���������. �����
    % � �������� 6000 �������� CA-����, �������, ��������, CAStep = 1000
    % ������� � ���������� 6 ��������� �� ���� �������.
        CAStep = Params.P70_GetRXPoses.CAStep;
        
    % ������� ���������� ���������.
    % isCommonRxTime = 1 - ���������� ��������� ����������� � ����������
    %   ������  ������� ��������, ��������������� ������ ������
    %   ������� GPS
    % isCommonRxTime = 0 - ���������� ��������� ����������� � ������
    %   ������� ������� ��������, ��������������� ���������� �����
    %   ������� GPS
        isCommonRxTime = Params.P70_GetRXPoses.isCommonRxTime;
        
    % ���������� ������ ���������, ����������� ��� ���������� ���������:
    % 'all' - ��� ��������;
    % 'firstX' - ������ � ���������, �������� 'first5';
    % [1, 2, 5, 7] - ���������� ������.
        SatNums2Pos = Params.P70_GetRXPoses.SatNums2Pos;

%% ���ר� ����������
    % �������� ������������� �������
        dt = 1/Res.File.Fs;

    % ��������� ���������� ������ ���������
        if ischar(SatNums2Pos)
            if strcmp(SatNums2Pos, 'all')
                CurSatNums2Pos = 1:Res.Search.NumSats;
            else
                Buf = str2double(SatNums2Pos(6:end));
                CurSatNums2Pos = 1:Buf;
            end
        else
            CurSatNums2Pos = SatNums2Pos;
        end
    
%% ���ר� ���������
% CurSatNums2Pos = ;
sizeOfEph = size(Res.Ephemeris);
for m = 1 : sizeOfEph(1)
    %--- ����������� ������� GPS ��� �������: ----
    inGPSTimes = zeros(1, CurSatNums2Pos(end));
    inTimeShifts = zeros(1, CurSatNums2Pos(end));
    SampleNums = zeros(1, CurSatNums2Pos(end));
    Es = cell(1, CurSatNums2Pos(end));
    for k = CurSatNums2Pos
%         strHOW = Res.SatsData.HOW{k, 1};
        inGPSTimes(k) = Res.Ephemeris{m, k}.TOW;
        Es{1, k} = Res.Ephemeris{m, k};
    end
    %---------------------------------
    Params.CurSatNums2Pos = CurSatNums2Pos;
%     Es{1, :} = Res.Ephemeris{m, :};
    UPos = P71_GetOneRXPos(Es, inGPSTimes, inTimeShifts,...); 
                                                   SampleNums, Params);
%     P76_ExportResults
end
end

function tGPS = GettGPS(SampleNum, SamplesNums, RefCANum, RefTOW, dt)
%
% ������� ���������� tGPS ��� ������� ������� SampleNum
%
% ������� ����������
%   SampleNum - ����� ������� ������, ��� �������� ���� ��������� �����
%       GPS;
%   SamplesNums - ������ ������ �������� CA-����� �������� ��������;
%   RefCANum - ����� CA-����, ������� �������� ������ � ��������, � �������
%       ��������� �������� RefTOW;
%   RefTOW - �������� RefTOW;
%   dt - �������� ������������� ������.
%
% �������� ����������
%   tGPS - ����� GPS � ������ SampleNum.

% ���������
    TCA = 10^-3;
    indLessThanSampleNum = SampleNums < SampleNum;
    indBiggerThanSampleNum = SampleNums > SampleNum;
    SampleNumsLess = SampleNums(indLessThanSampleNum);
    SampleNumsBigger = SampleNums(indBiggerThanSampleNum);
    diffLess = SampleNum - SampleNumsLess(end);
    diffBigger = SampleNumsBigger(1) - SampleNum;
    if diffLess < diffBigger
       startCASample = SampleNumsLess(end);
       
    end
    tGPS = RefTOW * 6 + (
end