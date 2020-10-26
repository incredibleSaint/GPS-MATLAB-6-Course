function Res = P40_GetSubFrames(inRes, Params)
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
    SubFrames = struct( ...
        'isSubFrameSync', zeros(Res.Search.NumSats, 1), ... 
        'BitSeqNum',      zeros(Res.Search.NumSats, 1), ...
        'BitShift',       zeros(Res.Search.NumSats, 1), ...
        'Words',          {cell(Res.Search.NumSats, 1)} ...
    );
    % Каждый элемент массива isSubFrameSync - флаг успешности подкадровой
    %   синхронизации.
    % Каждый элемент массива BitSeqNum - номер битового потока, в котором
    %   удалось выполнить синхронизацию с началом подкадра.
    % Каждый элемент массива BitShift - количество бит, которые надо
    %   пропустить от начала битового потока до начала первого подкадра.
    % Каждая ячейка cell-массива Words - cell-массив (Nx10), где N -
    %   количество обработанных подкадров, каждая ячейка - массив 1х24 бит
    %   декодированного слова, если CRC сошлось, и пустой массив, если CRC
    %   не сошлось.

%% УСТАНОВКА ПАРАМЕТРОВ

%% РАСЧЁТ ПАРАМЕТРОВ

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ЦИКЛ ПО НАЙДЕННЫМ СПУТНИКАМ
wordLen = 30;
subfrLen = 10 * wordLen;
preamble = '10001011' - '0';
        
numBitsForConv = subfrLen + length(preamble) -1; % find preamble

for k = 1 : Res.Search.NumSats
    bitsArr = Res.Demod.Bits{k};
    for m = 1 : 2
        bits = bitsArr(m, :);
        
        %----------------------
        preamble = [0 1 1 1 0 1 0 0];
        preamble = 2 * preamble - 1;
        bits = 2 * bits - 1;
        %-----------------------
        wordNum = floor(length(bits) / wordLen) - 1;
        length(bits);

        convol = abs(conv(bits(1 :  numBitsForConv), fliplr(conj(preamble)),...
                                                                    'valid'));
%         convol = convol(1 : length(convol) - rem(length(convol), 30));
        xCorr = abs(xcorr(bits(1 : numBitsForConv), preamble));
%         accXCorr = sum(reshape(convol, wordLen, 147).');
        figure; plot(convol);
    end
%     figure;
%     plot(xCorr);
%     figure;
%     plot((convol));
end
end
function Words = CheckFrames(Bits)
%
% Из битового потока выделяются все возможные кадры, в каждом кадре
% проверяется CRC каждого слова, если CRC сошлось, то сохраняется
% декодированное слово, в противном случае сохраняется пустой массив

end

function [isOk, BitSeqNum, BitShift] = SubFrameSync(Bits, isDraw, ...
    SaveDirName, SatNum)
%
% Функция подкадровой синхронизации
%
% isOk      - флаг, указывающий, найдена синхронизация или нет, причём она
%   должна быть найдена только один раз!
% BitSeqNum - номер битовой последовательности, для которой найдена
%   синхронизация. т.е. последовательности, с которой надо дальше работать.
% BitShift  - количество бит, которые нужно пропустить в битовой
%   последовательности до начала подкадра.

end

function [isOk, DWord] = CheckCRC(EWord)
% Функиця осуществляет проверку CRC для одного слова навигационного
% сообщения

% На входе:
%   EWord - слово (строка) с двумя битами предыдущего слова в начале, т.е.
%     всего 32 бита.

% На выходе: 
%   isOk - 1, если CRC сходится, 0 в противном случае.
%   DWord - декодированное слово (строка), т.е. всего 24 бита.

end