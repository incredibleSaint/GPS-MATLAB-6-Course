function Res = P10_CohSearchSats(inRes, Params)
%
% Функция когерентного поиска спутников в файле-записи
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
    Search = struct( ...
        'NumSats',       [], ... % Скаляр, количество найденных спутников
        'SatNums',       [], ... % массив 1хNumSats с номерами найденных
            ... % спутников
        'SamplesShifts', [], ... % массив 1хNumSats, каждый элемент -
            ... % количество отсчётов, которые нужно пропустить в файле-
            ... % записи до начала первого периода CA-кода соответствующего
            ... % спутника
        'FreqShifts',    [], ... % массив 1хNumSats со значениями частотных
            ... % сдвигов найденных спутников в Гц
        'CorVals',       [], ... % массив 1хNumSats вещественных значений
            ... % пиков корреляционных функций нормированных на среднее
            ... % значение, по которым были найдены спутники
        'AllCorVals',    zeros(1, 32) ... % массив максимальных значений
            ... % всех корреляционных функций
    );

%% УСТАНОВКА ПАРАМЕТРОВ
    % Количество периодов, учитываемых при обнаружении.
    % Для когерентного обнаружения 1 <= NumCA2Search <= 10
        NumCA2Search = Params.P10_CohSearchSats.NumCA2Search;

    % Массив центральных частот анализируемых диапазонов, Гц
        CentralFreqs = Params.P10_CohSearchSats.CentralFreqs;

    % Порог обнаружения
        SearchThreshold = Params.P10_CohSearchSats.SearchThreshold;

%% СОХРАНЕНИЕ ПАРАМЕТРОВ
    Search.NumCA2Search    = NumCA2Search;
    Search.CentralFreqs    = CentralFreqs;
    Search.SearchThreshold = SearchThreshold;

%% РАСЧЁТ ПАРАМЕТРОВ
    % Количество рассматрвиаемых частотных диапазонов
        NumCFreqs = length(CentralFreqs);

    % Длина CA-кода с учётом частоты дискретизации
        CALen = 1023 * Res.File.R;

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ
NumOfShiftedSamples = 0;
NumOfNeededSamples = NumCA2Search * CALen + CALen - 1;
sig1 = ReadSignalFromFile(inRes.File, ...
    NumOfShiftedSamples, NumOfNeededSamples);
NumOfShiftedSamples = NumCA2Search * CALen;
sig2 = ReadSignalFromFile(inRes.File, ...
    NumOfShiftedSamples, NumOfNeededSamples);

Search.NumSats = 0;
for k = 1 : 32
    CA = GenCACode(k);
    CA = repelem(CA, Res.File.R);
    CA = 2 * CA - 1;
    dt = 1 / inRes.File.Fs0;
    convSum1 = zeros(length(CentralFreqs), CALen);
    convSum2 = zeros(length(CentralFreqs), CALen);

    for m = 1 : length(CentralFreqs)
        sig1Shift = sig1 .* exp(-1j * 2 * pi * CentralFreqs(m) * ...
                    dt * (0 : length(sig1) - 1));
        sig2Shift = sig2 .* exp(-1j * 2 * pi * CentralFreqs(m) * ...
                    dt * (0 : length(sig1) - 1));
        convRes1 = conv(sig1Shift, fliplr(conj(CA)), 'valid');
        convRes2 = conv(sig2Shift, fliplr(conj(CA)), 'valid');
        convSum1(m, :) = abs(sum(reshape(convRes1, CALen, NumCA2Search).'));
        convSum2(m, :) = abs(sum(reshape(convRes2, CALen, NumCA2Search).'));
    end
    quality1 = max(max(convSum1)) / mean(mean(convSum1));
    quality2 = max(max(convSum2)) / mean(mean(convSum2));
    
    if quality1 >= quality2
        bodyOfUncertainty = convSum1;
        quality = quality1;
    else 
        bodyOfUncertainty = convSum2;
        quality = quality2;
    end
    [peakTime, indPeakTime] = max(max(bodyOfUncertainty));
    freqMaxCol = max(bodyOfUncertainty, [], 2);
    [peakFreq, indPeakFreq] = max(freqMaxCol);
    fprintf("Спутник №");
    fprintf(num2str(k));
    if quality >= SearchThreshold
        fprintf(" найден\n");
        Search.NumSats = Search.NumSats + 1;
        Search.SatNums = [Search.SatNums k];
        indPeakTime = indPeakTime - 1;
        Search.SamplesShifts = [Search.SamplesShifts indPeakTime];
        Search.FreqShifts = [Search.FreqShifts CentralFreqs(indPeakFreq)];
        Search.CorVals = [Search.CorVals quality];
    else 
        fprintf(" не найден\n");
    end
    Search.AllCorVals(k) = quality;
    
    figure;
    surf(abs(convSum1));
    figure;
    surf(abs(convSum2));
end
[Search.CorVals, indDesc] = sort(Search.CorVals, 'descend');
Search.SatNums = Search.SatNums(indDesc);
Search.SamplesShifts = Search.SamplesShifts(indDesc);
Search.FreqShifts = Search.FreqShifts(indDesc);

Res.Search = Search;
end
