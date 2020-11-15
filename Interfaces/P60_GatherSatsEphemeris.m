function Res = P60_GatherSatsEphemeris(inRes, Params) %#ok<INUSD>
%
% Функция сбора навигационной информации для спутников, у которых было
% найдено хотя бы одно значение TOW_Count_Message
%
% Входные переменные
%   inRes - структура с результатами модели, объявленная в Main;
%
% Выходные переменные
%   Res - структура, которая отличается от inRes добавлением нового поля,
%       описание которого дано ниже в коде.

% Пересохранение результатов
    Res = inRes;

%% ИНИЦИАЛИЗАЦИЯ РЕЗУЛЬТАТА
    % Ephemeris = cell(N, Res.Search.NumSats);
    
    % Количество строк cell-массива Ephemeris совпадает с количеством
    % подкадров спутников с одинаковым значением TOW (естественно, 
    % учитываются только те спутники, у которых SatsData.isSat2Use = 1).
    % Элементами Ephemeris являются структуры, содержащие значения всех
    % параметров первого, второго и третьего подкадров, а также порядковый
    % номер подкадра, номер первого CA подкадра, передаваемое значение TOW,
    % для которого верна эта информация. Если полную информацию собрать не
    % удалось, то элемент cell-массива должен быть пустым.

%% УСТАНОВКА ПАРАМЕТРОВ

%% РАСЧЁТ ПАРАМЕТРОВ
    % Имена всех полей структур, являющихся элементами Ephemeris
    ENames = { ...
    ... % Эти поля не относятся к навигационной информации
            'SFNum', ... % Порядковый номер подкадра спутника,
                ... % соответствующего текущей строке (подкадру) Ephemeris
            'CANum', ... % Номер CA-кода спутника, с которого начинается
                ... % подкадр с порядковым номером SFNum
            'TOW', ... % Значение TOW, передаваемое в подкадре с порядковым
                ... % номером SFNum. Это значение одинаковое для всех
                ... % элементов одной строки Ephemeris
            ...
    ... % Поля с навигационной информацией
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

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ЦИКЛ ПО НАЙДЕННЫМ СПУТНИКАМ
% Минимальное общее значение TOW для всех спутников:
TOW = zeros(1, Res.Search.NumSats);
for k = 1 : Res.Search.NumSats
    if Res.SatsData.isSat2Use(k) == 1
        str = Res.SatsData.HOW{k, 1};
        TOW(k) = str(1).TOW_Count;
    end
end
TOW_MIN_Common = max(TOW);

% Определим для каждого спутника порядковые номера подкадров, 
% в которых встречается TOW_MIN_Common:
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
            % заполняем эфемериды
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



    % Строка состояния
    
    % Определим порядковые номера спутников, для которых мы будем пытаться
    % собирать эфемериды
    % Определим значения TOW, общие для всех спутников
        
    % Для каждого спутника определим порядковый номер подкадра, в котором
    % встречается первое значение TOW общее с остальными спутниками

    % Заготовим результат
            
    % Теперь попробуем для каждого подкадра каждого спутника определить
    % эфемериды

    % Добавим новое поле с результатами в Res

    % Строка состояния
        
    

end

function E = MakeEmptyE(ENames)
    % Создадим все поля

    % Установим в поля, не относящиеся к навигационным данным, произвольные
    % параметры, чтобы тест isGathered проходил успешно (см. CheckAndAddE)
        E.SFNum = -1;
        E.CANum = -1;
        E.TOW   = -1;
end

function [outE, isNew] = CheckAndAddE(inE, SFNum, SFData, ENames)
E = MakeEmptyE(ENames);
% В зависимости от номера подкадра мы сравниваем значение либо IODC, либо
% IODE, имеющееся в InE с тем же значением в SFData, потом сравниваем
% значения IODC и IODE в inE

% Если нужно создавать новую E, то сделаем это, в противном случае
% скопируем E со входа
        
% Обновим пустые поля outE значениями из SFData
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
% Проверим, остались ли пустые поля
end