clc;
clear;
close all;

%% ЗАГРУЗКА ПАРАМЕТРОВ
    % Ищем в директории файлы, имя которых начинается на Setup и которые
    % имеют расширение m. Если такой файл один, то выполняем его
        % Определим содержимое рабочей директории
            Listing = dir;
        % Подготовка к циклу
            isFind = false;
            NumFinds = 0;
        % Цикл по количеству элементов, содержащихся в директории
            for k = 1:length(Listing)
                % Рассматриваем только файлы, причём имя файла должно
                % начинаться на Setup и иметь расширение 'm'
                if ~Listing(k).isdir
                if length(Listing(k).name) >= length('Setup.m')
                if strcmp(Listing(k).name(1:length('Setup')), ...
                        'Setup') && strcmp(Listing(k).name( ...
                        end-1:end), '.m')
                    SetupFileName = Listing(k).name(1:end-2);
                    isFind = true;
                    NumFinds = NumFinds + 1;
                end
                end
                end
            end

        % Завершение работы в случае отрицательного результата поиска
            if ~isFind
                error('Не удалось найти файл с параметрами!');
            end
            if NumFinds > 1
                error('Найдено больше одного файла с параметрами!');
            end

        % Создадим указатель на нужную функцию
            Fun = str2func(SetupFileName);
        % Выполним функцию и перезапишем Res
            Params = Fun();

%% УСТАНОВКА ЧАСТО ИЗМЕНЯЕМЫХ ПАРАМЕТРОВ
    % Номер процедуры, с которой надо начать выполнение Main
        StartProcNum = Params.Main.StartProcNum;
            % 1 <= StartProcNum <= length(FuncNames)

    % Номер процедуры, на которой надо закончить выполнение Main
        StopProcNum = Params.Main.StopProcNum;
            % 1 <= StopProcNum <= length(FuncNames) и
            % StartProcNum <= StopProcNum

	% Выбор типа обработки - устанавливается для StartProcNum = 1, чтобы
	%   не быть случайно изменённым в дальнейшем
    % 'Coh'/'NonCoh' - когерентная обработка / некогерентная обработка
        if StartProcNum == 1
            ProcessType = Params.Main.ProcessType;
        end

    % Флаг необходимости прорисовки результатов
        isDraw = Params.Main.isDraw; % 0 - не рисовать; 1 - рисовать;
            % 2 - рисовать и сохранять; 3 - рисовать, сохранять и закрывать

    % Выбор имени файла-записи
        % Директория с файлами-записями
            SigDirName = Params.Main.SigDirName;
        % Имя файла-записи
            SigFileName = Params.Main.SigFileName;
        % Полное имя файла-записи
            SigFileName = [SigDirName, '\', SigFileName];

    % Имя файла для загрузки результатов
    % Если StartProcNum = 1, то не надо ничего загружать
        if StartProcNum > 1
            LoadFileName = Params.Main.LoadFileName;
        end

    % Имя файла для сохранения результатов
        SaveFileName = Params.Main.SaveFileName;

    % Директория для сохранения результатов
        SaveDirName = Params.Main.SaveDirName;

    % Полные имена файлов загрузки и сохранения
        if StartProcNum > 1
            LoadFileName = [SaveDirName, '\', LoadFileName];
        end
        SaveFileName = [SaveDirName, '\', SaveFileName];

%% УСТАНОВКА РЕДКО ИЗМЕНЯЕМЫХ ПАРАМЕТРОВ
    if StartProcNum == 1
        % Определим структуру файла-записи - описание полей см. в
        % ReadSignalFromFile
            File = struct( ...
                'Name',           SigFileName, ...
                'HeadLenInBytes', Params.Main.HeadLenInBytes, ...
                'NumOfChannels',  Params.Main.NumOfChannels, ...
                'ChanNum',        Params.Main.ChanNum, ...
                'DataType',       Params.Main.DataType, ...
                'Fs0',            Params.Main.Fs0, ...
                'dF',             Params.Main.dF, ...
                'FsDown',         Params.Main.FsDown, ...
                'FsUp',           Params.Main.FsUp ...
            );
    end

%% ПОДГОТОВИТЕЛЬНАЯ ЧАСТЬ
    % Имена функций, выполняющих обработку сигнала и/или полученных из
    % сигнала данных
        AllFuncNames = { ...
            { ... % Имена функций для когерентной обработки
                'P10_CohSearchSats', ...
                'P20_CohTrackSatsAndBitSync', ...
                'P30_CohDemodSatsSigs', ...
                'P40_GetSubFrames', ...
                'P50_ParseSubFrames', ...
                'P60_GatherSatsEphemeris', ...
                'P70_GetRXPoses', ...
            }, ...
            { ... % Имена функций для некогерентной обработки
                'P10_NonCohSearchSats', ...
                'P20_NonCohTrackSatsAndBitSync', ...
                'P30_NonCohDemodSatsSigs', ...
                'P40_GetSubFrames', ...
                'P50_ParseSubFrames', ...
                'P60_GatherSatsEphemeris', ...
                'P70_GetRXPoses', ...
            } ...
        };

    % Расчёт некоторых полей File
        if StartProcNum == 1
            % Определим длину файла-записи в отсчётах
                [~, File] = ReadSignalFromFile(File, 0, 0);

            % Определим коэффициент передискретизации по отношению к
            % символьной скорости GPS
                File.R = round(File.Fs / (1.023*10^6));
        end

    % Проверка наличия/создание директории с результатами
        if ~isdir(SaveDirName)
            mkdir(SaveDirName);
        end

    % Инициализируем или загрузим структуру-результат
        if StartProcNum == 1 % Инициализация
            Res = struct( ...
                'ProcessType',  ProcessType, ...
                'File',         File, ...
                'LoadFileName', 'none', ...
                'SaveFileName', SaveFileName, ...
                'Search',       [], ...
                'Track',        [], ...
                'BitSync',      [], ...
                'Demod',        [], ...
                'SubFrames',    [], ...
                'SatsData',     [], ...
                'Ephemeris',    [], ...
                'Positioning',  [] ...
            );
        else % Загрузка
            load(LoadFileName, 'Res');
            Res.LoadFileName = LoadFileName;
        end

    % Проверка совпадения имени файла, указанного в Main (выше) и
    % загруженного вместе с результатами
        if StartProcNum > 1
            if ~isequal(Res.File.Name, SigFileName)
                Btn = questdlg(['Указанное при запуске имя файла не ', ...
                    'совпадает с именем, сохранённым в загруженных ', ...
                    'результатах! Использовать новое имя можно ', ...
                    'только, если произошло переименование файла ', ...
                    'и/или перемещение его в другую директорию.'], ...
                    'Внимание!', 'Использовать сохранённое имя', ...
                    'Использовать новое имя', 'Отмена выполнения', ...
                    'Отмена выполнения');
                if isequal(Btn, 'Использовать сохранённое имя')
                    % ничего не надо делать!
                elseif isequal(Btn, 'Использовать новое имя')
                    Res.File.Name = SigFileName;
                elseif isequal(Btn, 'Отмена выполнения')
                    return
                end
            end
        end

    % Имена функций, выполняющих обработку сигнала и/или полученных из
    % сигнала данных
        if isequal(Res.ProcessType, 'Coh')
            FuncNames = AllFuncNames{1};
        else
            FuncNames = AllFuncNames{2};
        end
        
%% ПРОВЕРКИ ЗНАЧЕНИЙ ПАРАМЕТРОВ
    if ~((StartProcNum >= 1) && (StartProcNum <= length(FuncNames)))
        fprintf(['Должно выполняться двойное неравенство ', ...
            '1 <= StartProcNum <= length(FuncNames)!\nРабота Main ', ...
            'прекращена.\n'])
        return
    end

    if ~((StopProcNum >= 1) && (StopProcNum <= length(FuncNames)))
        fprintf(['Должно выполняться двойное неравенство ', ...
            '1 <= StopProcNum <= length(FuncNames)!\nРабота Main ', ...
            'прекращена.\n'])
        return
    end

    if ~(StartProcNum <= StopProcNum)
        fprintf(['Должно выполняться неравенство ', ...
            'StartProcNum <= StopProcNum!\nРабота Main прекращена.\n'])
        return
    end
    
    if ~(isequal(isDraw, 0) || isequal(isDraw, 1) || ...
            isequal(isDraw, 2) || isequal(isDraw, 3))
        fprintf(['Значение isDraw должно быть одним из ', ...
            '(0, 1, 2)!\nРабота Main прекращена.\n'])
        return
    end
    
    if ~(isequal(Res.ProcessType, 'Coh') || ...
            isequal(Res.ProcessType, 'NonCoh'))
        fprintf(['Значение ProcessType должно быть одним из ', ...
            '(Coh, NonCoh)!\nРабота Main прекращена.\n'])
        return
    end

%% ОСНОВНАЯ ЧАСТЬ
    % По очереди выполним все необходимые процедуры
        for k = StartProcNum : StopProcNum
            % Создадим указатель на нужную функцию
                Fun = str2func(FuncNames{k});
            % Выполним функцию и перезапишем Res
                Res = Fun(Res, Params);
            % Сохраним текущие результаты
            % В вычислительно сложных функциях (P10_, P20_) рекомендуется
            % делать дополнительные сохранения для отладки
                if k < 7
                    save(SaveFileName, 'Res', 'Params');
                end
        end