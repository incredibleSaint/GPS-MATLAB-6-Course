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
% CurSatNums2Pos = ;
sizeOfEph = size(Res.Ephemeris);
for m = 1 : sizeOfEph(1)
    %--- Определение времени GPS для расчета: ----
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