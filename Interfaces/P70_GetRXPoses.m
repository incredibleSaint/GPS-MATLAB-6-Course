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
        CAInSbfr = 20 * 300;
        numCompsForSubfr = floor(CAInSbfr / CAStep);
        numCAIn1Sec = 1e3;
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

lenSatNums = length(CurSatNums2Pos);

% ����� ������ ������� �������� ���������� ��������� ������� 
% ��� ����� ������ SampleNum, ��� �������� ����� ��������� �������
[CAIndexOfStartSbfr, sampleNumOfStartSubfr] = FindSubframeStart(Res, ...
                                                            lenSatNums);
startSampleNum = max(sampleNumOfStartSubfr(CurSatNums2Pos));

sizeOfEph = size(Res.Ephemeris);
sampleNum = startSampleNum;

for m = 1 : sizeOfEph(1)
    for n = 1 : numCompsForSubfr
    %--- ����������� ������� GPS ��� �������: ----
    
    inGPSTimes = zeros(1, lenSatNums);
    inTimeShifts = zeros(1, lenSatNums);
    SamplesNums = zeros(1, lenSatNums);
    Es = cell(1, lenSatNums);
    for k = 1 : lenSatNums
        samplesShifts = Res.Track.SamplesShifts{CurSatNums2Pos(k), 1};

        RefCANum = Res.Ephemeris{m, k}.CANum;

        sampleNum = startSampleNum + 2046 * CAStep * ((m - 1) * numCompsForSubfr + (n - 1));

        inGPSTimes(k) = GettGPS(sampleNum, samplesShifts, RefCANum, ...
                              Res.Ephemeris{m, CurSatNums2Pos(k)}.TOW, dt);
        Es{1, k} = Res.Ephemeris{m, CurSatNums2Pos(k)};
        SamplesNums(k) = sampleNum;
    end
    %---------------------------------
    
    %---------------------------------
    Params.CurSatNums2Pos  = CurSatNums2Pos;
    inTimeShifts = inGPSTimes(1) - inGPSTimes;
    UPos{m, n} = P71_GetOneRXPos(Es, inGPSTimes, inTimeShifts,...); 
                                                   SamplesNums, Params);
    UPos{m, n}.tGPS = inGPSTimes;
    
    end
%     P76_ExportResults

end
Res.Positioning.RXPoses = UPos;
P76_ExportResults(UPos, Params);
end

function [CAIndexOfStartSbfr, sampleNumOfStartSubfr] = ...
                                         FindSubframeStart(Res, lenSatNums)
% ����� ������ ������� �������� ���������� ��������� ������� 
% ��� ����� ������ SampleNum, ��� �������� ����� ��������� �������
CANumInBit = 20; 
CAIndexOfStartSbfr = zeros(1, Res.Search.NumSats);
sampleNumOfStartSubfr = zeros(1, Res.Search.NumSats);

for k = 1 : lenSatNums 
    CAIndexOfStartSbfr(k) = (Res.BitSync.CAShifts(k) ) + ...%+ 1) + ...
                                    Res.SubFrames.BitShift(k) * CANumInBit;
    samplesShifts = Res.Track.SamplesShifts{k, 1};
    sampleNumOfStartSubfr(k) = samplesShifts(CAIndexOfStartSbfr(k));
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
    indLessThanSampleNum = SamplesNums < SampleNum;
    indBiggerThanSampleNum = SamplesNums > SampleNum;
    SampleNumsLess = SamplesNums(indLessThanSampleNum);
    SampleNumsBigger = SamplesNums(indBiggerThanSampleNum);
    diffLess = SampleNum - SampleNumsLess(end);
    diffBigger = SampleNumsBigger(1) - SampleNum;
    NearestCANum = length(SampleNumsLess);
    if diffLess < diffBigger
       CAStartSample = SampleNumsLess(end);
    elseif diffLess > diffBigger
        CAStartSample = SampleNumsBigger(1);
        NearestCANum = NearestCANum + 1;
        if diffLess == 2046 
            NearestCANum = NearestCANum + 1;
        end
    elseif diffLess == diffBigger
        CAStartSample = SampleNum;
        NearestCANum = NearestCANum + 1;
    end
%     NearestCANum = length(SampleNumsLess);
    tGPS = (RefTOW - 1) * 6 + (NearestCANum - RefCANum) * TCA + ...% (RefTOW - 1): because this TOW value for next subframe, not current
                                    (SampleNum - CAStartSample) * dt;
end