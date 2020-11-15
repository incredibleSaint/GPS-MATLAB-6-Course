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
% SaveDirName = 
%% РАСЧЁТ ПАРАМЕТРОВ

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ЦИКЛ ПО НАЙДЕННЫМ СПУТНИКАМ

isOk = zeros(1, Res.Search.NumSats);
BitSeqNum = zeros(1, Res.Search.NumSats);
BitShift  = zeros(1, Res.Search.NumSats);
for k = 1 : Res.Search.NumSats
    demBits = Res.Demod.Bits{k};

    [isOk(k), BitSeqNum(k), BitShift(k)] = SubFrameSync(demBits, Params.Main.isDraw);
%                                                        SaveDirName, SatNum)
    if isOk(k)
        words = CheckFrames(demBits(BitSeqNum(k), :), BitShift(k));
    end
    SubFrames.Words{k, 1} = words;
    
end
SubFrames.isSubFrameSync = isOk;
SubFrames.BitSeqNum = BitSeqNum;
SubFrames.BitShift = BitShift;
Res.SubFrames = SubFrames;
end
function words = CheckFrames(rawBits, BitShift)
%
% Из битового потока выделяются все возможные кадры, в каждом кадре
% проверяется CRC каждого слова, если CRC сошлось, то сохраняется
% декодированное слово, в противном случае сохраняется пустой массив
subWordsNum = 10;
wordLen = 30;
subfrLen = 300;
subfrNum = floor((length(rawBits) - BitShift+1) / subfrLen);
bits = rawBits(BitShift + (-2 : subfrNum * subfrLen - 1));
% bitsMatr = reshape(bits, subfrLen, subfrNum)';
words = cell(subfrNum, subWordsNum);
for k = 1 : subfrNum
    for w = 1 : subWordsNum
        wordForCheck = bits((k -1) * subfrLen + ...
                            (w -1) * wordLen + ...
                            (1 : 32));
        [isOk, DWord] = CheckCRC(wordForCheck);
        if isOk
            words{k, w} = DWord;
        else
            words{k, w} = [];
        end
    end
end
end

function [isOk, BitSeqNum, BitShift] = SubFrameSync(bitsDem, isDraw)
%     SaveDirName, SatNum)
%
% Функция подкадровой синхронизации
%
% isOk      - флаг, указывающий, найдена синхронизация или нет, причём она
%   должна быть найдена только один раз!
% BitSeqNum - номер битовой последовательности, для которой найдена
%   синхронизация. т.е. последовательности, с которой надо дальше работать.
% BitShift  - количество бит, которые нужно пропустить в битовой
%   последовательности до начала подкадра.
isOk = 0;
BitSeqNum = 0;
BitShift  = 0;
sizeBits = size(bitsDem);
% Number of bits in the worst case:
bitsNumForFindTlmHow = 2 + ... % D*_29, D*_30  (bitsNumForFindTlmHow = 361)
                       7 + ... % if we late with preambule only for one bit
                       292 +...% bits number for start of next preambule
                       60;     % preambule, TLM, HOW for checking 
if(sizeBits(2) < bitsNumForFindTlmHow)
    fprintf("There is not enough bits for subframe sync!\n");
    return;
end

wordLen = 30;
subfrLen = 10 * wordLen;
preamble = '10001011' - '0';
preamble = 2 * preamble - 1;
preamLen = length(preamble);

numBitsForConv = subfrLen + preamLen -1; % find preamble

for m = 1 : sizeBits(1)
    bits = bitsDem(m, :);

    bits = 2 * bits - 1;
    %-----------------------
    wordNum = floor(length(bits) / wordLen) - 1;
    length(bits);

    convol = abs(conv(bits(1 + 2 : numBitsForConv + 2), ... % '+ 2' - because if preambule in bits(1 : 8), 
                                     fliplr(conj(preamble)), 'valid'));% then we need previous 2 bits (D*_29, D*_30, to eliminate ambiguity),
                                                                       % which we don't have at all (bits(-1), bits(0))
    if isDraw
        figure; plot(convol);
    end
    indPos = find(convol == preamLen);
    for k = 1 : length(indPos)
        wordForCheck = bitsDem(m, indPos(k) + 2 - 2 + (0 : 31)); % '+2' - because for conv it was bits(1 + 2 : ...); '-2' - we need previous 2 bits (D*_29, D*_30, to eliminate ambiguity)
       [isOkPreTLM, DWord] = CheckCRC(wordForCheck);
       
       if isOkPreTLM
           wordForCheck = bitsDem(m, indPos(k) + 2 - 2 + (32 : 63) - 2);% addition '-2' - we need previous 2 bits (D*_29, D*_30, to eliminate ambiguity) of word PreTLM
           [isOkHOW, DWord] = CheckCRC(wordForCheck);
           
           if isOkHOW
               isOk = 1;
               BitSeqNum = m;
               BitShift  = indPos(k) + 2;
               return;
           end
       end
       
    end
end

end

function [isOk, DWord] = CheckCRC(eWord)
% Функция осуществляет проверку CRC для одного слова навигационного
% сообщения

% На входе:
%   EWord - слово (строка) с двумя битами предыдущего слова в начале, т.е.
%     всего 32 бита.

% На выходе: 
%   isOk - 1, если CRC сходится, 0 в противном случае.
%   DWord - декодированное слово (строка), т.е. всего 24 бита.
if (eWord(2) == 1) % D*_30
    eWord(3 : 26) = ~eWord(3 : 26);
end
dBits = eWord(3 : 26);
D25 = rem(eWord(1) + dBits(1) + dBits(2) + dBits(3) + dBits(5) + dBits(6) ...
               + dBits(10) + dBits(11) + dBits(12) + dBits(13) + dBits(14)... 
               + dBits(17) + dBits(18) + dBits(20) + dBits(23), 2);

D26 = rem(eWord(2) + dBits(2) + dBits(3) + dBits(4) + dBits(6) + dBits(7) ...
               + dBits(11) + dBits(12) + dBits(13) + dBits(14) + dBits(15)...
               + dBits(18) + dBits(19) + dBits(21) + dBits(24), 2);

D27 = rem(eWord(1) + dBits(1) + dBits(3) + dBits(4) + dBits(5) + dBits(7) ...
               + dBits(8) + dBits(12) + dBits(13) + dBits(14) + dBits(15) ...
               + dBits(16) + dBits(19) + dBits(20) + dBits(22), 2);

D28 = rem(eWord(2) + dBits(2) + dBits(4) + dBits(5) + dBits(6) + dBits(8) ...
               + dBits(9) + dBits(13) + dBits(14) + dBits(15) + dBits(16) ...
               + dBits(17) + dBits(20) + dBits(21) + dBits(23), 2);

D29 = rem(eWord(2) + dBits(1) + dBits(3) + dBits(5) + dBits(6) + dBits(7) ...
               + dBits(9) + dBits(10) + dBits(14) + dBits(15) + dBits(16) ...
           + dBits(17) + dBits(18) + dBits(21) + dBits(22) + dBits(24), 2);

D30 = rem(eWord(1) + dBits(3) + dBits(5) + dBits(6) + dBits(8) + dBits(9) ...
               + dBits(10) + dBits(11) + dBits(13) + dBits(15) + dBits(19)...
               + dBits(22) + dBits(23) + dBits(24), 2);

Dparity = [D25 D26 D27 D28 D29 D30];
isOk = 0;
if (Dparity == eWord(27 : 32)) % CRC is right
    isOk = 1;
end
DWord = dBits;
end