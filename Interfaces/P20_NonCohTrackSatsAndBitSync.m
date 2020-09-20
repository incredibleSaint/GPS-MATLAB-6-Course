function Res = P20_NonCohTrackSatsAndBitSync(inRes, Params)
%
% Функция некогерентного трекинга спутников и битовой синхронизации
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
    Track = struct( ...
        'SamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',       {cell(Res.Search.NumSats, 1)} ...
    );
    % Каждая ячейка cell-массивов SamplesShifts и CorVals является массивом
    %   1xN, где N - количество периодов CA-кода соответствующего спутника,
    %   найденных в файле-записи (N может быть разным для разных
    %   спутников).
    % Каждый элемент массива SamplesShifts{k} - количество отсчётов,
    %   которые надо пропустить в файле-записи до начала соответствующего
    %   периода CA-кода.
    % Каждый элемент массива CorVals{k} - комплексное значение корреляции
    %   части сигнала, содержащей соответствующий период CA-кода, с опорным
    %   сигналом.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % Каждый элемент массива CAShifts - количество периодов CA-кода,
    %   которые надо пропустить до начала бита.
    % Каждая строка массива Cors - корреляции, по позиции минимума которых
    %   определяется битовая синхронизация.

%% УСТАНОВКА ПАРАМЕТРОВ
    % Количество периодов CA-кода между соседними синхронизациями по
    % времени (NumCA2NextSync >= 1, NumCA2NextSync = 1 - синхронизация для
    % каждого CA-кода)
        NumCA2NextSync = Params.P20_NonCohTrackSatsAndBitSync.NumCA2NextSync;

    % Половина количества дополнительных периодов CA-кода, используемых для
    % синхронизации по времени
        HalfNumCA4Sync = Params.P20_NonCohTrackSatsAndBitSync.HalfNumCA4Sync;

    % Количество учитываемых значений задержки/набега синхронизации по
    % времени
        HalfCorLen = Params.P20_NonCohTrackSatsAndBitSync.HalfCorLen;

    % Период, с которым производится отображение числа обработанных
    % CA-кодов
        NumCA2Disp = Params.P20_NonCohTrackSatsAndBitSync.NumCA2Disp;

    % Максимальное число обрабатываемых CA-кодов (inf - до конца файла!)
        MaxNumCA2Process = Params.P20_NonCohTrackSatsAndBitSync.MaxNumCA2Process;

    % Количество бит, используемых для битовой синхронизации
        NBits4Sync = Params.P20_NonCohTrackSatsAndBitSync.NBits4Sync;

%% СОХРАНЕНИЕ ПАРАМЕТРОВ
    Track.NumCA2NextSync   = NumCA2NextSync;
    Track.HalfNumCA4Sync   = HalfNumCA4Sync;
    Track.HalfCorLen       = HalfCorLen;
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% РАСЧЁТ ПАРАМЕТРОВ
    % Длина CA-кода с учётом частоты дискретизации
        CALen = 1023 * Res.File.R;

    % Количество периодов CA-кода, приходящихся на один бит
        CAPerBit = 20;

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ТРЕКИНГ
    % Строка состояния
        fprintf('%s Трекинг спутников\n', datestr(now));
    for k = 1:Res.Search.NumSats
        % Строка состояния
            fprintf('%s     Трекинг спутника №%02d (%d из %d) ...\n', ...
                datestr(now), Res.Search.SatNums(k), k, ...
                Res.Search.NumSats);
            
            ...
                
        % Строка состояния
            fprintf('%s         Завершено.\n', datestr(now));
    end
    % Добавим новое поле с результатами в Res
        Res.Track = Track;

    % Строка состояния
        fprintf('%s     Завершено.\n', datestr(now));    

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - БИТОВАЯ СИНХРОНИЗАЦИЯ