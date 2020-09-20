function Params = Setup()

% Main
    % Номер процедуры, с которой надо начать выполнение Main
        Main.StartProcNum = 1; %  1 <= StartProcNum <= length(FuncNames)

    % Номер процедуры, на которой надо закончить выполнение Main
        Main.StopProcNum = 7; %  1 <= StopProcNum <= length(FuncNames) и
            % StartProcNum <= StopProcNum

	% Выбор типа обработки - устанавливается для StartProcNum = 1, чтобы
	%   не быть случайно изменённым в дальнейшем
    % 'Coh'/'NonCoh' - когерентная обработка / некогерентная обработка
        Main.ProcessType = 'NonCoh';

    % Флаг необходимости прорисовки результатов
        Main.isDraw = 3; % 0 - не рисовать; 1 - рисовать; 2 - рисовать и
            % сохранять; 3 - рисовать, сохранять и закрывать

    % Выбор имени файла-записи
        % Директория с файлами-записями
            Main.SigDirName = 'C:\Users\Incredible\Desktop\Studies\Programming\MATLAB\NIR\GPS\Signal';
        % Имя файла-записи
            Main.SigFileName = '30_08_2018__19_38_33_x02_1ch_16b_15pos_90000ms.dat';

    % Имя файла для загрузки результатов
    % Если StartProcNum = 1, то не надо ничего загружать
        Main.LoadFileName = 'Rate2';

    % Имя файла для сохранения результатов
        Main.SaveFileName = 'Rate2';

    % Директория для сохранения результатов
        Main.SaveDirName = 'Results_Rate2_NonCoh';

    % Параметры структуры файла-записи
        Main.HeadLenInBytes = 0;
        Main.NumOfChannels  = 1;
        Main.ChanNum        = 0;
        Main.DataType       = 'int16';
        Main.Fs0            = 2.046*10^6;
        Main.dF             = 0;
        Main.FsDown         = 1;
        Main.FsUp           = 1;

% P10_NonCohSearchSats
    % Количество периодов, учитываемых при обнаружении.
        P10_NonCohSearchSats.NumCA2Search = 20;
    % Массив центральных частот анализируемых диапазонов, Гц
        P10_NonCohSearchSats.CentralFreqs = -6000 : 1000 : 6000;
    % Порог обнаружения
        P10_NonCohSearchSats.SearchThreshold = 3.0;

% P10_CohSearchSats
    % Количество периодов, учитываемых при обнаружении.
    % Для когерентного обнаружения 1 <= NumCA2Search <= 10
        P10_CohSearchSats.NumCA2Search = 10;
    % Массив центральных частот анализируемых диапазонов, Гц
        P10_CohSearchSats.CentralFreqs = -6000 : ...
            1000/P10_CohSearchSats.NumCA2Search : 6000;
    % Порог обнаружения
        P10_CohSearchSats.SearchThreshold = 10;

% P20_NonCohTrackSatsAndBitSync
    % Количество периодов CA-кода между соседними синхронизациями по
    % времени (NumCA2NextSync >= 1, NumCA2NextSync = 1 - синхронизация для
    % каждого CA-кода)
        P20_NonCohTrackSatsAndBitSync.NumCA2NextSync = 100;

    % Половина количества дополнительных периодов CA-кода, используемых для
    % синхронизации по времени
        P20_NonCohTrackSatsAndBitSync.HalfNumCA4Sync = 10;

    % Количество учитываемых значений задержки/набега синхронизации по
    % времени
        P20_NonCohTrackSatsAndBitSync.HalfCorLen = 2;

    % Период, с которым производится отображение числа обработанных
    % CA-кодов
        P20_NonCohTrackSatsAndBitSync.NumCA2Disp = 5*10^3;

    % Максимальное число обрабатываемых CA-кодов (inf - до конца файла!)
        P20_NonCohTrackSatsAndBitSync.MaxNumCA2Process = inf;

    % Количество бит, используемых для битовой синхронизации
        P20_NonCohTrackSatsAndBitSync.NBits4Sync = 100;

% P20_CohTrackSatsAndBitSync
    % Порядок фильтров
        P20_CohTrackSatsAndBitSync.DLL.FilterOrder = 2;
        P20_CohTrackSatsAndBitSync.FPLL.FilterOrder = [2, 3];

    % И DLL и FPLL имеют несколько режимов работы для каждого из них нужно
    % определить
        % Полосы фильтров
            P20_CohTrackSatsAndBitSync.DLL.FilterBands  = [0.05; 0.05; ...
                0.05; 0.05];
            P20_CohTrackSatsAndBitSync.FPLL.FilterBands = [ ...
                5, 5; ...
                5, 5; ...
                5, 5; ...
                2, 2];

        % Количество периодов накопления для фильтрации
            P20_CohTrackSatsAndBitSync.DLL.NumsIntCA  = [4, 10, 20, 20];
            P20_CohTrackSatsAndBitSync.FPLL.NumsIntCA = [4, 10, 20, 20];

	% Определим количество периодов CA-кода, учитываемых для проверки
	% необходимости перехода между состояниями DLL и FPLL. Проверка
	% работает по принципу integrate and dump
        P20_CohTrackSatsAndBitSync.DLL.NumsCA2CheckState  = [100, 100, ...
            100, 100];
        P20_CohTrackSatsAndBitSync.FPLL.NumsCA2CheckState = [100, 100, ...
            100, 100];

    % Граничные значения для перехода между состояниями
    % Если значение > HiTr, то переходим в следующее (более робастное)
    %   состояние
    % Если значение < LoTr, то переходим в предыдущее (более
    %   чувствительное)состояние
        P20_CohTrackSatsAndBitSync.DLL.HiTr = [0.5 0.5 0.5 0.5];
        P20_CohTrackSatsAndBitSync.DLL.LoTr = [0.05 0.05 0.05 0.05];

        P20_CohTrackSatsAndBitSync.FPLL.HiTr = [0.5 0.5 0.5 0.5];
        P20_CohTrackSatsAndBitSync.FPLL.LoTr = [0.05 0.05 0.05 0.05];

    % Период, с которым производится отображение числа обработанных
    % CA-кодов
        P20_CohTrackSatsAndBitSync.NumCA2Disp = 5*10^3;

    % Максимальное число обрабатываемых CA-кодов (inf - до конца файла!)
        P20_CohTrackSatsAndBitSync.MaxNumCA2Process = inf; % inf;

    % Количество бит, используемых для битовой синхронизации
        P20_CohTrackSatsAndBitSync.NBits4Sync = 100;

% P30_NonCohDemodSatsSigs
    P30_NonCohDemodSatsSigs = [];

% P30_CohDemodSatsSigs
    P30_CohDemodSatsSigs = [];

% P40_GetSubFrames
    P40_GetSubFrames = [];

% P50_ParseSubFrames
    P50_ParseSubFrames = [];

% P60_GatherSatsEphemeris
    P60_GatherSatsEphemeris = [];
    
% P70_GetRXPoses
    % Шаг в периодах CA-кода между соседними вычислениями координат. Всего
    % в подкадре 6000 периодов CA-кода, поэтому, например, CAStep = 1000
    % приведёт к вычислению 6 координат за один подкадр.
        P70_GetRXPoses.CAStep = 600;

    % Вариант вычисления координат.
    % isCommonRxTime = 1 - координаты спутников вычисляются в одинаковый
    %   момент  времени приёмника, соответствующий разным меткам
    %   времени GPS
    % isCommonRxTime = 0 - координаты спутников вычисляются в разные
    %   моменты времени приёмника, соответствующие одинаковой метке
    %   времени GPS
        P70_GetRXPoses.isCommonRxTime = 1;

    % Порядковые номера спутников, учитываемых при вычислении координат:
    % 'all' - все спутники;
    % 'firstX' - первые Х спутников, например 'first5';
    % [1, 2, 5, 7] - конкретные номера.
        P70_GetRXPoses.SatNums2Pos = 'first6';

% P71_GetOneRXPos
    % Максимальное число итераций
        P71_GetOneRXPos.MaxNumIters = 100;
    % Максимальное изменение координат пользователя между соседними
    % итерациями (м). Если фактическое изменение меньше, то цикл
    % останавливается
        P71_GetOneRXPos.MaxDelta = 0.1;

% P72_GetSatPos
    P72_GetSatPos = [];

% P73_RenewSatPos
    P73_RenewSatPos = [];

% P74_Cartesian2Spherical
    P74_Cartesian2Spherical.AlgType = 0;
        % 0 - по стандарту РФ
        % 1 - по книге

    P74_Cartesian2Spherical.EllipseType = 0;
        % 0 - WGS84
        % 1 - ПЗ-90
        % 2 - Красовский - 1942

% P75_CalculateSatElAz
    P75_CalculateSatElAz = [];

% P76_ExportResults
    % Нужно ли сохранять метки позиции приёмника
        P76_ExportResults.isSaveUserPoses = 1;
    % Нужно ли сохранять метки позиции спутников
        P76_ExportResults.isSaveSatsPoses = 0;
    % Нужно ли вычислять СКО координат приёмника
        P76_ExportResults.isCalcCoordinatesVariance = 1;
    % Нужно ли нумеровать метки позиций приёмника
        P76_ExportResults.isNumerateLabels = 1;
    % Имя файла для сохранения результатов
        P76_ExportResults.FileName = 'Res.kml';

% Сохраним все параметры в структуру
    Params = struct( ...
        'Main', Main, ...
        'P10_NonCohSearchSats', P10_NonCohSearchSats, ...
        'P10_CohSearchSats', P10_CohSearchSats, ...
        'P20_NonCohTrackSatsAndBitSync', P20_NonCohTrackSatsAndBitSync, ...
        'P20_CohTrackSatsAndBitSync', P20_CohTrackSatsAndBitSync, ...
        'P30_NonCohDemodSatsSigs', P30_NonCohDemodSatsSigs, ...
        'P30_CohDemodSatsSigs', P30_CohDemodSatsSigs, ...
        'P40_GetSubFrames', P40_GetSubFrames, ...
        'P50_ParseSubFrames', P50_ParseSubFrames, ...
        'P60_GatherSatsEphemeris', P60_GatherSatsEphemeris, ...
        'P70_GetRXPoses', P70_GetRXPoses, ...
        'P71_GetOneRXPos', P71_GetOneRXPos, ...
        'P72_GetSatPos', P72_GetSatPos, ...
        'P73_RenewSatPos', P73_RenewSatPos, ...
        'P74_Cartesian2Spherical', P74_Cartesian2Spherical, ...
        'P75_CalculateSatElAz', P75_CalculateSatElAz, ...
        'P76_ExportResults', P76_ExportResults ...
        );