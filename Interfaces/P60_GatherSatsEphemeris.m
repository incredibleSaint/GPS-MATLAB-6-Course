function Res = P60_GatherSatsEphemeris(inRes, Params) %#ok<INUSD>
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
    % Ephemeris = cell(N, Res.Search.NumSats);
    
    % ���������� ����� cell-������� Ephemeris ��������� � �����������
    % ��������� ��������� � ���������� ��������� TOW (�����������, 
    % ����������� ������ �� ��������, � ������� SatsData.isSat2Use = 1).
    % ���������� Ephemeris �������� ���������, ���������� �������� ����
    % ���������� �������, ������� � �������� ���������, � ����� ����������
    % ����� ��������, ����� ������� CA ��������, ������������ �������� TOW,
    % ��� �������� ����� ��� ����������. ���� ������ ���������� ������� ��
    % �������, �� ������� cell-������� ������ ���� ������.

%% ��������� ����������
numCAinBit = 20;
numBitsInSubframe = 300;
%% ���ר� ����������
    % ����� ���� ����� ��������, ���������� ���������� Ephemeris
    ENames = { ...
    ... % ��� ���� �� ��������� � ������������� ����������
            'SFNum', ... % ���������� ����� �������� ��������,
                ... % ���������������� ������� ������ (��������) Ephemeris
            'CANum', ... % ����� CA-���� ��������, � �������� ����������
                ... % ������� � ���������� ������� SFNum
            'TOW', ... % �������� TOW, ������������ � �������� � ����������
                ... % ������� SFNum. ��� �������� ���������� ��� ����
                ... % ��������� ����� ������ Ephemeris
            ...
    ... % ���� � ������������� �����������
            'WeekNumber', ...
            'CodesOnL2', ...
            'URA', ...
            'URA_in_meters', ...
            'SV_Health_Summary', ...
            'SV_Health', ...
            'IODC', ...
            'L2_P_Data_Flag', ...
            'T_GD', ...
            't_oc', ...
            'a_f2', ...
            'a_f1', ...
            'a_f0', ...
            'IODE', ...
            'C_rs', ...
            'Delta_n', ...
            'M_0', ...
            'C_uc', ...
            'ecc', ...
            'C_us', ...
            'sqrtA', ...
            't_oe', ...
            'Fit_Interval_Flag', ...
            'AODO', ...
            'C_ic', ...
            'Omega_0', ...
            'C_is', ...
            'i_0', ...
            'C_rc', ...
            'omega', ...
            'DOmega', ...
            'IODE', ...
            'IDOT', ...
    };

%% �������� ����� ������� - ���� �� ��������� ���������
% ����������� ����� �������� TOW ��� ���� ���������:
TOW = zeros(1, Res.Search.NumSats);
for k = 1 : Res.Search.NumSats
    if Res.SatsData.isSat2Use(k) == 1
        str = Res.SatsData.HOW{k, 1};
        TOW(k) = str(1).TOW_Count;
    end
end
TOW_MIN_Common = max(TOW);
%-------------------------------------------------------------
% ��������� ��� ������� �������� ���������� ������ ���������, 
% � ������� ����������� TOW_MIN_Common:
subfrNumMinCommon = zeros(1, Res.Search.NumSats);
for k = 1 : Res.Search.NumSats
    if Res.SatsData.isSat2Use(k) == 1
        sizeStr = size(Res.SatsData.HOW{k, 1});
        for m = 1 : sizeStr(2)
            str = Res.SatsData.HOW{k, 1};
            TOWCurr = str(m).TOW_Count;
            if TOWCurr == TOW_MIN_Common
               subfrNumMinCommon(k) = m;
               break; 
            end
        end
    end
end
%------------------------------------------------------------
ephemerisCell = cell(sizeStr(2), Res.Search.NumSats);
for k = 1 : Res.Search.NumSats
    if Res.SatsData.isSat2Use(k) == 1
        
        E = MakeEmptyE(ENames);
        strHOW = Res.SatsData.HOW{k, 1};
        firstCommonSubfrID = strHOW(subfrNumMinCommon(k)).Subframe_ID;
        shiftToFirstSF1 = 6 - firstCommonSubfrID;
        
        sizeStr = size(Res.SatsData.HOW{k, 1});
        subfrNum = sizeStr(2);
        cntSF = 0;
        
        isNewArr = zeros(1, subfrNum);
        isGatheredArr = zeros(1, subfrNum);
        for m = (subfrNumMinCommon(k) + shiftToFirstSF1) : subfrNum
            cntSF = cntSF + 1;
   
            if cntSF == 1
               SFNum = 1;
               str = Res.SatsData.SF1{k, 1};
               SFData = str(m);
               [E, isNew(m), isGatheredArr(m)] = CheckAndAddE(...
                                                E, SFNum, SFData, ENames);
            elseif cntSF == 2
               SFNum = 2;
               str = Res.SatsData.SF2{k, 1};
               SFData = str(m);
               [E, isNew(m), isGatheredArr(m)] = CheckAndAddE(...
                                                E, SFNum, SFData, ENames);
            elseif cntSF == 3
               SFNum = 3;
               str = Res.SatsData.SF3{k, 1};
               SFData = str(m);
               [E, isNew(m), isGatheredArr(m)] = CheckAndAddE(...
                                                E, SFNum, SFData, ENames);
            end
            E.SFNum = m;
            E.CANum = (Res.BitSync.CAShifts(k) +1) + ...
                       Res.SubFrames.BitShift(k) * numCAinBit + ...
                       (m - 1) * numBitsInSubframe * numCAinBit;
            E.TOW = strHOW(m).TOW_Count;
            
            ephemerisCell{m, k} = E;
            
            if cntSF == 5
                cntSF  = 0;
            end
            
        end
    end
    IsGatheredIndexes = find(isGatheredArr == 1);
    for m = 1 : IsGatheredIndexes(1) - 1
        E.SFNum = m;          
        E.CANum = (Res.BitSync.CAShifts(k) +1) + ...
                   Res.SubFrames.BitShift(k) * numCAinBit + ...
                   (m - 1) * numBitsInSubframe * numCAinBit;
        E.TOW = strHOW(m).TOW_Count;
        ephemerisCell{m, k} = E;
    end
end

Res.Ephemeris = ephemerisCell;


    % ������ ���������
    
    % ��������� ���������� ������ ���������, ��� ������� �� ����� ��������
    % �������� ���������
    % ��������� �������� TOW, ����� ��� ���� ���������
        
    % ��� ������� �������� ��������� ���������� ����� ��������, � �������
    % ����������� ������ �������� TOW ����� � ���������� ����������

    % ��������� ���������
            
    % ������ ��������� ��� ������� �������� ������� �������� ����������
    % ���������

    % ������� ����� ���� � ������������ � Res

    % ������ ���������
        
    

end

function E = MakeEmptyE(ENames)
    % �������� ��� ����

    % ��������� � ����, �� ����������� � ������������� ������, ������������
    % ���������, ����� ���� isGathered �������� ������� (��. CheckAndAddE)
        E.SFNum = -1;
        E.CANum = -1;
        E.TOW   = -1;
        s = size(ENames);
        for m = 4 : s(2)
            E.(ENames{m}) = NaN;
        end
end

function [outE, isNew, isGathered] = CheckAndAddE(inE, SFNum, SFData, ENames)
% E = MakeEmptyE(ENames);
% � ����������� �� ������ �������� �� ���������� �������� ���� IODC, ����
% IODE, ��������� � InE � ��� �� ��������� � SFData, ����� ����������
% �������� IODC � IODE � inE

% ���� ����� ��������� ����� E, �� ������� ���, � ��������� ������
% ��������� E �� �����
        
% ������� ������ ���� outE ���������� �� SFData
isNew = 0;
isGathered = CheckE(inE, ENames);
%-- In case if IODC or IODE has changed --------------
%- (It means that there are new ephemeris) -----------
if isGathered
    if SFNum == 1
        if inE.IODC ~= SFData.IODC
            isNew = 1;
            inE = MakeEmptyE(ENames);
        end
    elseif SFNum == 2 || SFNum == 3
        if inE.IODE ~= SFData.IODE
            isNew = 1;
            inE = MakeEmptyE(ENames);
        end
    end
end
%----------------------------------------
isGathered = CheckE(inE, ENames);
if ~isGathered
    if SFNum == 1
        shiftInStruct = 3;


    elseif SFNum == 2
        shiftInStruct = 16;

    elseif SFNum == 3
        shiftInStruct = 27;

    end
    SFDataSize = size(fieldnames(SFData));
    for k = 1 : SFDataSize
       if(any(isnan(inE.(ENames{k + shiftInStruct}))) && ...
                           any(~isnan(SFData.(ENames{k + shiftInStruct}))))
           inE.(ENames{k + shiftInStruct}) = ...
                                        SFData.(ENames{k + shiftInStruct});
       end
    end
end
outE = inE;
end

function isGathered = CheckE(E, ENames)
% ��������, �������� �� ������ ����
s = size(fieldnames(E));
isGatheredArr = zeros(1, s(1));
for n = 1 : s(1)
    isGatheredArr(n) = any(isnan(E.(ENames{n})));
end
if any(isGatheredArr)
    isGathered = 0;
else
    isGathered = 1;
end
end