function Res = P30_NonCohDemodSatsSigs(inRes, Params)
%
% Функция некогерентной демодуляции сигналов спутников
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
    Demod = struct( ...
        'Bits', {cell(Res.Search.NumSats, 1)} ...
    );
    % Каждый элемент cell-массива Bits - массив 4хN значений 0/1, где
    %   N - количество демодулированных бит.

%% УСТАНОВКА ПАРАМЕТРОВ
CAShifts = Res.BitSync.CAShifts;
CorVals  = Res.Track.CorVals;
%% РАСЧЁТ ПАРАМЕТРОВ
    % Количество периодов CA-кода, приходящихся на один бит
        CAPerBit = 20;

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ЦИКЛ ПО НАЙДЕННЫМ СПУТНИКАМ
fprintf("Начало некогерентной демодуляции сигналов \n");

for k = 1 : Res.Search.NumSats
    CorValsSync = CorVals{k};
    lenCor = length(CorValsSync);
    bitNum = floor((lenCor - (CAShifts(k) - 1)) / CAPerBit); 
    
    CorValsUsed = CorValsSync(CAShifts(k) : CAShifts(k) + ...
                                                    bitNum * CAPerBit - 1);
    
    CorValsArr  = reshape(CorValsUsed, CAPerBit, bitNum);
    dCorr = zeros(1, bitNum -1);
    for n = 2 : bitNum
        dCorr(n - 1) = sum(CorValsArr(:, n) .* conj(CorValsArr(:, n - 1)));
    end
    ddCorr = dCorr(2 : end) .* conj(dCorr(1 : end - 1));
    ddB = real(ddCorr) < 0;
    
    bitsVar1 = zeros(1, bitNum);
    bitsVar2 = zeros(1, bitNum);
    bitsVar2(2) = 1;
    for n = 3 : bitNum
        bitsVar1(n) = mod(ddB(n - 2) + bitsVar1(n - 2), 2);
        bitsVar2(n) = mod(ddB(n - 2) + bitsVar2(n - 2), 2);

    end
    figure;
    subplot(4, 1, 1);
    plot(angle(dCorr) / pi, '.-');
    grid on;
    title('angle(dCorr) / pi');
    
    subplot(4, 1, 2);
    plot(angle(ddCorr) / pi,  '.-');
    grid on;
    title('angle(d(dCorr)) / pi');
    
    subplot(4, 1, 3);
    plot(bitsVar1, '.-');
    grid on;
    title('bitsVar1');
    
    subplot(4, 1, 4);
    plot(bitsVar2, '.-');
    grid on;
    title('bitsVar2');
    Demod.Bits{k} = [bitsVar1 ; bitsVar2];
end
Res.Demod.Bits = Demod.Bits;
fprintf("Завершение демодуляции \n");