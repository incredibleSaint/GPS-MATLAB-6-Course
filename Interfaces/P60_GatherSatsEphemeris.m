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
            'e', ...
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

for k = 1 : Res.Search.NumSats
    if Res.SatsData.isSat2Use(k) == 1
        E = MakeEmptyE(ENames);
        strHOW = Res.SatsData.HOW{k, 1};
        firstCommonSubfrID = strHOW(subfrNumMinCommon(k)).Subframe_ID;
        shiftToFirstSF1 = 6 - firstCommonSubfrID;
        
        sizeStr = size(Res.SatsData.HOW{k, 1});
        subfrNum = sizeStr(2);
        cntSF = 0;
%         cntCommon = 0;
%         firstSubfrNum = Res.SatsData.HOW{k, 1}.Subframe_ID;
%         E = MakeEmptyE(ENames);
        for m = (subfrNumMinCommon(k) + shiftToFirstSF1) : subfrNum    
            % ��������� ���������
            cntSF = cntSF + 1;
   
            if cntSF == 1
               SFNum = 1;
               str = Res.SatsData.SF1{k, 1};
               SFData = str(m);
               [E, isNew] = CheckAndAddE(E, SFNum, SFData, ENames)
            elseif cntSF == 2
               SFNum = 2;
               str = Res.SatsData.SF2{k, 1};
               SFData = str(m);
               [E, isNew] = CheckAndAddE(E, SFNum, SFData, ENames)
            elseif cntSF == 3
               SFNum = 3;
               str = Res.SatsData.SF3{k, 1};
               SFData = str(m);
               [E, isNew] = CheckAndAddE(E, SFNum, SFData, ENames)
            end
            if cntSF == 3
                break;
            end
            
        end
    end
end



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
end

function [outE, isNew] = CheckAndAddE(inE, SFNum, SFData, ENames)
E = MakeEmptyE(ENames);
% � ����������� �� ������ �������� �� ���������� �������� ���� IODC, ����
% IODE, ��������� � InE � ��� �� ��������� � SFData, ����� ����������
% �������� IODC � IODE � inE

% ���� ����� ��������� ����� E, �� ������� ���, � ��������� ������
% ��������� E �� �����
        
% ������� ������ ���� outE ���������� �� SFData
isNew = 0;
if SFNum == 1
    inE.WeekNumber = SFData.weekNumber;
    inE.CodesOnL2 = SFData.CAorPCodeOn;
    inE.URA = SFData.UraIndex;
    outE.URA_in_meters = 0;
    outE.SV_Health_Summary = 0;%SFData.
    outE.SV_Health = SFData.svHealth;
    outE.IODC = SFData.IODC;
    outE.L2_P_Data_Flag = SFData.L2PDataFlag;
    outE.T_GD = SFData.Tgd;
    outE.t_oc = SFData.t_oc;
    outE.a_f2 = SFData.a_f2;
    outE.a_f1 = SFData.a_f1;
    outE.a_f0 = SFData.a_f0;
elseif SFNum == 2
    inE.IODE = SFData.IODE;
    inE.C_rs = SFData.C_rs;
    inE.Delta_n = SFData.dn;
    inE.M_0 = SFData.M_0;
    inE.C_uc = SFData.C_uc;
    inE.e = SFData.ecc;
    inE.C_us = SFData.C_us;
    inE.sqrtA = SFData.sqrtA;
    inE.t_oe = SFData.t_oe;
    inE.Fit_Interval_Flag = SFData.FitIntervalFlag;
    inE.AODO = SFData.AODO;
elseif SFNum == 3
	inE.C_ic = SFData.C_ic;
    inE.Omega_0 = SFData.OMEGA_0;
    inE.C_is = SFData.C_is;
    inE.i_0 = SFData.i_0;
    inE.C_rc = SFData.C_rc;
    inE.omega = SFData.w;
    inE.DOmega = SFData.OMEGA_dot;
    inE.IODE = SFData.IODE;
    inE.IDOT = SFData.IDOT;
    
end
outE = inE;
end

function isGathered = CheckE(E, ENames)
% ��������, �������� �� ������ ����
end