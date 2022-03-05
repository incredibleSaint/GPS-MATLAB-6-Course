function Res = P70_GetRXPoses(inRes, Params)
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
    % Positioning = struct(  ...
    %   'RX+Poses', cell(N, M), ...
    %   'CAStep', CAStep, ...
    %   'isCommonRxTime', isCommonRxTime ...
    % );
    
    % Количество строк N cell-массива RXPoses совпадает с количеством
    %   подкадров спутников с одинаковыми значениями TOW. Количество
    %   столбцов определяется количеством вычислений координат на
    %   длительности одного подкадра и зависит от параметра CAStep,
    %   определяемого ниже.
    % CAStep - шаг в периодах CA-кода между соседними вычислениями
    %   координат.
    % isCommonRxTime - параметр, определяющий как вычислять параметры
    %   спутников: в одно время приёмника или в разное.

%% УСТАНОВКА ПАРАМЕТРОВ
    % Шаг в периодах CA-кода между соседними вычислениями координат. Всего
    % в подкадре 6000 периодов CA-кода, поэтому, например, CAStep = 1000
    % приведёт к вычислению 6 координат за один подкадр.
        CAStep = Params.P70_GetRXPoses.CAStep;
        CAInSbfr = 20 * 300;
        numCompsForSubfr = floor(CAInSbfr / CAStep);
        numCAIn1Sec = 1e3;
    % Вариант вычисления координат.
    % isCommonRxTime = 1 - координаты спутников вычисляются в одинаковый
    %   момент  времени приёмника, соответствующий разным меткам
    %   времени GPS
    % isCommonRxTime = 0 - координаты спутников вычисляются в разные
    %   моменты времени приёмника, соответствующие одинаковой метке
    %   времени GPS
        isCommonRxTime = Params.P70_GetRXPoses.isCommonRxTime;
        
    % Порядковые номера спутников, учитываемых при вычислении координат:
    % 'all' - все спутники;
    % 'firstX' - первые Х спутников, например 'first5';
    % [1, 2, 5, 7] - конкретные номера.
        SatNums2Pos = Params.P70_GetRXPoses.SatNums2Pos;

%% РАСЧЁТ ПАРАМЕТРОВ
    % Интервал дискретизации сигнала
        dt = 1/Res.File.Fs;

    % Определим конкретные номера спутников
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
    
%% РАСЧЁТ КООРДИНАТ

lenSatNums = length(CurSatNums2Pos);

% Найти начало первого подкадра пришедшего последним сигнала 
% это будет первый SampleNum, для которого будем вычислять позицию
[CAIndexOfStartSbfr, sampleNumOfStartSubfr] = FindSubframeStart(Res, ...
                                                            lenSatNums);
startSampleNum = max(sampleNumOfStartSubfr(CurSatNums2Pos));

sizeOfEph = size(Res.Ephemeris);
sampleNum = startSampleNum;

for m = 1 : sizeOfEph(1) -2
    for n = 1 : numCompsForSubfr
    %--- Определение времени GPS для расчета: ----
    
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
% найти начало первого подкадра пришедшего последним сигнала 
% это будет первый SampleNum, для которого будем вычислять позицию
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
% Функция определяет tGPS для отсчёта сигнала SampleNum
%
% Входные переменные
%   SampleNum - номер отсчёта записи, для которого надо расчитать время
%       GPS;
%   SamplesNums - номера первых отсчётов CA-кодов текущего спутника;
%   RefCANum - номер CA-кода, который является первым в подкадре, в котором
%       передаётся значение RefTOW;
%   RefTOW - значение RefTOW;
%   dt - интервал дискретизации записи.
%
% Выходные переменные
%   tGPS - время GPS в отсчёт SampleNum.

% Константы
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