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
    NumOfShiftedSamples = 0;
    necessMin = (MaxNumCA2Process + HalfNumCA4Sync * 2 + 2) * CALen;

    if Res.File.SamplesLen > necessMin && MaxNumCA2Process ~= Inf
        NumOfNeededSamples = necessMin;
    else
        NumOfNeededSamples = Res.File.SamplesLen;
        MaxNumCA2Process   = floor(Res.File.SamplesLen / CALen - 2);
    end

    sig = ReadSignalFromFile(inRes.File, ...
                        NumOfShiftedSamples, NumOfNeededSamples);
                    
    eplNumber = 2 * HalfCorLen + 1;
    
    for k = 1 : Res.Search.NumSats
        % Строка состояния
        fprintf('%s     Трекинг спутника №%02d (%d из %d) ...\n', ...
            datestr(now), Res.Search.SatNums(k), k, ...
            Res.Search.NumSats);

        CA = GenCACode(Res.Search.SatNums(k));
        CA = repelem(CA, Res.File.R);
        CA = 2 * CA - 1;
        dt = 1 / inRes.File.Fs0;
        
        cnt = 0;     % Счетчик обработанных СА-кодов
                     % с момента последней синхронизации
        dShift = 0;  % Текущий сдвиг синхронизации относильно начального
        syncCnt = 0; % Счетчик синхронизаций
        
        syncCorr = zeros(floor(MaxNumCA2Process / NumCA2NextSync), ...
                                                                eplNumber);
        synchrCorrInd = zeros(1, MaxNumCA2Process);
        corr    = zeros(1, MaxNumCA2Process);
        corrAbs = zeros(1, MaxNumCA2Process);
        phaseCA = zeros(1, MaxNumCA2Process);
        samplesShifts = zeros(1, MaxNumCA2Process);
        
        for indCA = 1 : MaxNumCA2Process
            sigPart = ...
                    sig((Res.Search.SamplesShifts(k)     + ... % начальный сдвиг из P10_NonCohSearchSats.m
                                     (indCA -1) * CALen  + ... % индекс рассчитываемого CA-кода
                                             (1 : CALen) + ... % сам массив CA-кода
                                                    dShift )); % сдвиг синхронизации
            sigCorrFreq = sigPart .* exp(1j * 2 * pi * ...
               (-Res.Search.FreqShifts(k)) * dt * (1 : CALen));
            corr(indCA) = sigCorrFreq * CA.';
            phaseCA(indCA) = angle(corr(indCA)) / pi;
            corrAbs(indCA) = abs(corr(indCA));

            cnt = cnt + 1;
            if cnt == NumCA2NextSync % it's time for synchronization
                cnt = 0;
                syncCnt =  syncCnt + 1;
                
                for epl = 1 : eplNumber
                    for m = 1 : 2 * HalfNumCA4Sync % accumulation cycle
                       sigPart =  sig((Res.Search.SamplesShifts(k) + ... % начальный сдвиг из P10_NonCohSearchSats.m
                                               (indCA -1) * CALen  + ... % индекс рассчитываемого CA-кода
                                                   (m -1) * CALen) + ... % сдвиг при накоплении
                                                       (1 : CALen) + ... % сам массив CA-кода
                                                            dShift + ... % сдвиг синхронизации
                                                   epl - 1 - HalfCorLen);% рассматриваемые задержки/набеги синхронизации
                       sigCorrFreq = sigPart .* exp(1j * 2 * pi * ...
                           (-Res.Search.FreqShifts(k)) * dt * (1 : CALen));
                       syncCorr(syncCnt, epl) = syncCorr(syncCnt, epl) + ...
                                                   abs(sigCorrFreq * CA.');
                    end
                end
                                           
               [~, maxInd] = max(syncCorr(syncCnt, :));
               if maxInd ~= eplNumber - HalfCorLen % do a synchr shift
                   dShift = dShift + maxInd - (eplNumber - HalfCorLen);
               end
                           
            end
            synchrCorrInd(indCA) = dShift;
            samplesShifts(indCA) = Res.Search.SamplesShifts(k) + dShift + ...
                                                       (indCA - 1) * CALen;
        end
        %---- Save Results ----
        Track.SamplesShifts{k, 1} = samplesShifts;
        Track.CorVals{k, 1}       = corr;
        
        mult = corr(2 : end) .* conj(corr(1 : end - 1));
        figure; plot(angle(mult) / pi);
        title(['Разность фаз соседних корреляций для спутника №', ...
                                        num2str(Res.Search.SatNums(k))]);
        %---- Plot Results ----
        figure;
        subplot(3, 1, 1);
        plot(corrAbs, '.-');
        hold on;
        p = plot(corrAbs, '.', 'MarkerIndices', ...
                                    1 : NumCA2NextSync : length(phaseCA));
        p.MarkerSize = 15;
        p.MarkerEdgeColor = 'g';
        grid on;
        strBelow = ['Модуль корреляций с СA-кодами для спутника №', ...
                                          num2str(Res.Search.SatNums(k))];
        str = {'Некогерентный трекинг', strBelow};
        title(str);
        xlabel('Номер обработанного CA-кода');
        
        subplot(3, 1, 2);
        p = plot(phaseCA, '.');
        p.MarkerSize = 5;
        hold on; 
        p = plot(phaseCA, '.', 'MarkerIndices', ...
                                    1 : NumCA2NextSync : length(phaseCA));
        p.Color = [0 1 0];
        p.MarkerSize = 15;
        grid on;
        title(['Фаза корреляций с периодами СА-кода для спутника №', ...
                                          num2str(Res.Search.SatNums(k))]);
        xlabel('Номер обработанного CA-кода');
        ylabel('Фаза, \pi');                              
        
        subplot(3, 1, 3);
        plot(synchrCorrInd, 'Marker', '.');
        grid on;
        hold on;
        p = plot(synchrCorrInd, '.', 'MarkerIndices', ...
                                    1 : NumCA2NextSync : length(phaseCA));
        p.MarkerSize = 15;
        p.MarkerEdgeColor = 'g';
        title(['Кривая кумулятивного ухода синхронизации для спутника №', ...
                                          num2str(Res.Search.SatNums(k))]);
        xlabel('Номер обработанного CA-кода');
        ylabel('Сдвиг в отсчетах F_{s0}');
        % Строка состояния
            fprintf('%s         Завершено.\n', datestr(now));
    end
    % Добавим новое поле с результатами в Res
    Res.Track = Track;

    % Строка состояния 
        fprintf('%s     Завершено.\n', datestr(now));    

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - БИТОВАЯ СИНХРОНИЗАЦИЯ

numOfCAInBit = 20;
numOfCA = NBits4Sync * numOfCAInBit;
bitSync = zeros(Res.Search.NumSats, numOfCAInBit);
for k = 1 : Res.Search.NumSats
    corr = Track.CorVals{k, 1};
    phaseDiff = corr(2 : numOfCA + 1) .* conj(corr(1 : numOfCA));
    bitSync(k, :) = abs(sum(reshape(phaseDiff, numOfCAInBit, NBits4Sync), ...
                                                                       2));
    figure; plot(bitSync(k, :));
    [~, BitSync.CAShifts(k, 1)] = min(bitSync(k, :));
end
BitSync.Cors = bitSync;
Res.BitSync = BitSync;
fprintf('%s     Завершена битовая синхронизация.\n', datestr(now));  