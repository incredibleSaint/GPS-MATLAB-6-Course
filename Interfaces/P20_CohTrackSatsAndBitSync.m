  function Res = P20_CohTrackSatsAndBitSync(inRes, Params)
%
% Функция когерентного трекинга спутников и битовой синхронизации
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
        'SamplesShifts',     {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',           {cell(Res.Search.NumSats, 1)}, ...
        'HardSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'FineSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'EPLCorVals',        {cell(Res.Search.NumSats, 1)}, ...
        'DLL',               {cell(Res.Search.NumSats, 1)}, ...
        'FPLL',              {cell(Res.Search.NumSats, 1)} ...
    );
    % Каждая ячейка cell-массивов SamplesShifts, CorVals, HardSamplesShifts
    %   FineSamplesShifts является массивом 1xN, где N - количество
    %   периодов CA-кода соответствующего спутника, найденных в файле-
    %   записи (N может быть разным для разных спутников).
    % Каждый элемент массива SamplesShifts{k} - дробное количество
    %   отсчётов, которые надо пропустить в файле-записи до начала
    %   соответствующего периода CA-кода.
    % Каждый элемент массива CorVals{k} - комплексное значение корреляции
    %   части сигнала, содержащей соответствующий период CA-кода, с опорным
    %   сигналом.
    % Каждый элемент массивов HardSamplesShifts{k}, FineSamplesShifts{k} -
    %   соответственно дробная и целая части значений SamplesShifts{k}.
    % Каждая ячейка cell-массива EPLCorVals является массивом 3xN значений
    %   Early, Promt и Late корреляций. При этом: SamplesShifts{k} =
    %   EPLCorVals{k}(2, :).
    % DLL, FPLL - лог сопровождения фазы кода и частоты-фазы сигнала.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % Каждый элемент массива CAShifts - количество периодов CA-кода,
    %   которые надо пропустить до начала бита.
    % Каждая строка массива Cors - корреляции, по позиции минимума которых
    %   определяется битовая синхронизация.

%% УСТАНОВКА ПАРАМЕТРОВ
    % Порядок фильтров
        DLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.DLL.FilterOrder;
        FPLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterOrder;
        
    % И DLL и FPLL имеют несколько режимов работы для каждого из них нужно
    % определить
        % Полосы фильтров
            DLL.FilterBands  = Params.P20_CohTrackSatsAndBitSync.DLL.FilterBands;
            FPLL.FilterBands = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterBands;
            
        % Количество периодов накопления для фильтрации
            DLL.NumsIntCA  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsIntCA;
            FPLL.NumsIntCA = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsIntCA;

	% Определим количество периодов CA-кода, учитываемых для проверки
	% необходимости перехода между состояниями DLL и FPLL. Проверка
	% работает по принципу integrate and dump
        DLL.NumsCA2CheckState  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsCA2CheckState;
        FPLL.NumsCA2CheckState = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsCA2CheckState;
        
    % Граничные значения для перехода между состояниями
    % Если значение > HiTr, то переходим в следующее (более робастное)
    %   состояние
    % Если значение < LoTr, то переходим в предыдущее (более
    %   чувствительное)состояние
        DLL.HiTr = Params.P20_CohTrackSatsAndBitSync.DLL.HiTr;
        DLL.LoTr = Params.P20_CohTrackSatsAndBitSync.DLL.LoTr;
        
        FPLL.HiTr = Params.P20_CohTrackSatsAndBitSync.FPLL.HiTr;
        FPLL.LoTr = Params.P20_CohTrackSatsAndBitSync.FPLL.LoTr;

    % Период, с которым производится отображение числа обработанных
    % CA-кодов
        NumCA2Disp = Params.P20_CohTrackSatsAndBitSync.NumCA2Disp;

    % Максимальное число обрабатываемых CA-кодов (inf - до конца файла!)
        MaxNumCA2Process = Params.P20_CohTrackSatsAndBitSync.MaxNumCA2Process;

    % Количество бит, используемых для битовой синхронизации
        NBits4Sync = Params.P20_CohTrackSatsAndBitSync.NBits4Sync;

%% СОХРАНЕНИЕ ПАРАМЕТРОВ
    % Track.FPLL = FPLL; % не нужно, так как всё равно будет сделано в
    % Track.DLL = DLL;   % конце
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% РАСЧЁТ ПАРАМЕТРОВ
    % Длина CA-кода с учётом частоты дискретизации
        CALen = 1023 * Res.File.R;

    % Количество периодов CA-кода, приходящихся на один бит
        CAPerBit = 20;

    % Длительность CA-кода, мс
        TCA = 10^-3;

        
%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ТРЕКИНГ И БИТОВАЯ СИНХРОНИЗАЦИЯ
% EPL - early prompt late
FiltBandw = 2;
for k = 1 : Res.Search.NumSats
    % Init:
    DLL.NCO = 0;
    DLL.NCOCorr = 0;
    EPL = [];
    hardShifts = [];
    fineShifts = [];
    samplesShift = [];

    hardShiftStart = Res.Search.SamplesShifts(k) + 1;
    
    hardShiftCurr = hardShiftStart;
    softShiftCurr = 0;
    
    counter = 0;
    cntNewHard = 0;
    
    CA = GenCACode(Res.Search.SatNums(k));
    CA = repelem(CA, Res.File.R);
    CA = 2 * CA - 1;
    dt = 1 / inRes.File.Fs0;
    
    % Init 2nd order filter
    w0 = FiltBandw / 0.53;
    coeff = [w0 ^ 2   1.414 * w0];
    filtVel = 0;
    filtAcc = 0;
    
    %-------------------------------------------------
    NumOfShiftedSamples = hardShiftStart - 1; % Because 1) we need EPL and 2) NumOfShiftedSamples is how many samples to SKIP in file
    NumOfNeededSamples = 1;
    [~, File] = ReadSignalFromFile(inRes.File, ...
                                  NumOfShiftedSamples, NumOfNeededSamples);
    fileLen = File.SamplesLen;
    NumOfNeededSamples = CALen + 2;% need EPL
    
    while hardShiftCurr + CALen + 1 < fileLen % "+1" - because we need EPL
%     while counter < 10e3
        counter = counter + 1;
        hardShifts(counter) = hardShiftCurr;
        fineShifts(counter) = DLL.NCO;
        
        NumOfShiftedSamples = hardShiftCurr - 2;
        sig = ReadSignalFromFile(inRes.File, ...
                                  NumOfShiftedSamples, NumOfNeededSamples);
%         corr = conv(sig, fliplr(conj(CA
        sigCorrFreq = sig .* exp(1j * 2 * pi * (-Res.Search.FreqShifts(k)) ...
                                          * dt * (1 : NumOfNeededSamples));
        EPL(1, counter) = sigCorrFreq(1 : end - 2) * CA.'; % early
        EPL(2, counter) = sigCorrFreq(2 : end - 1) * CA.'; % prompt
        EPL(3, counter) = sigCorrFreq(3 : end - 0) * CA.'; % late
        
        
        DLL.NCO = DLL.NCO + DLL.NCOCorr;
        
        samplesShift(counter) = hardShiftCurr + DLL.NCO;
        
        if DLL.NCO > 0.5
            DLL.NCO = DLL.NCO - 1;
            hardShiftCurr = hardShiftCurr + 1;
            cntNewHard(end) = counter;
        elseif DLL.NCO < -0.5
            DLL.NCO = DLL.NCO + 1;
            hardShiftCurr = hardShiftCurr - 1;
            cntNewHard(end + 1) = counter;
        end
        
        
        E = abs(EPL(1, counter));
        L = abs(EPL(3, counter));
%         E = abs(sum(EPL(1, :)));
%         L = abs(sum(EPL(3,   :)));
        
        discrimOut = 0.5 * (E - L) / (E + L); % [discrimOut] = samples
        %--- 1 order filter ----
%         w0 = 4 * FiltBandw; % [w0] = Hz;
%         filtOut = discrimOut * w0; % [filtOut] = samples * Hz 
        %--- 2nd order ---------
        
        
        filtOut = discrimOut * coeff(1) * TCA * 0.5 + discrimOut * coeff(2) + ...
                                                                   filtVel;
        filtVel = filtVel + discrimOut * coeff(1) * TCA;                                                           
        %------------------------
        DLL.NCOCorr = -filtOut * TCA; % [DdLL.NCOCorr] = samples
        
        hardShiftCurr = hardShiftCurr + CALen;
    end
    
%     plot(abs(EPL(2, :)))
    figure;plot(abs(EPL(1,: )))
    figure;plot(abs(EPL(2,: )))
    figure;plot(abs(EPL(3,: )))
    
    Track.SamplesShifts{k} = samplesShift;
    Track.CorVals{k} = EPL(2, :);
    Track.HardSamplesShifts{k} = hardShifts;
    Track.FineSamplesShifts{k} = fineShifts;
    Track.EPLCorVals{k} = EPL;
    fprintf('%s     Coh Tracking of %d satellites from %d.\n', ...
                                    datestr(now), k, Res.Search.NumSats);
end
Res.Track = Track;



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

end