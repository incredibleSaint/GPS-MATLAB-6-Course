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
numCAinBit = 20;
numBitsInSubframe = 300;
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
%-------------------------------------------------------------
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
        s = size(ENames);
        for m = 4 : s(2)
            E.(ENames{m}) = NaN;
        end
end

function [outE, isNew, isGathered] = CheckAndAddE(inE, SFNum, SFData, ENames)
% E = MakeEmptyE(ENames);
% В зависимости от номера подкадра мы сравниваем значение либо IODC, либо
% IODE, имеющееся в InE с тем же значением в SFData, потом сравниваем
% значения IODC и IODE в inE

% Если нужно создавать новую E, то сделаем это, в противном случае
% скопируем E со входа
        
% Обновим пустые поля outE значениями из SFData
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
% Проверим, остались ли пустые поля
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