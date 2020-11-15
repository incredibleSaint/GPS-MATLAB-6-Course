function Res = P50_ParseSubFrames(inRes, Params) %#ok<INUSD>
%
% Функция демодуляции сигналов спутников
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
    SatsData = struct( ...
        'isSat2Use', zeros(1, Res.Search.NumSats), ...
        'TLM', {cell(Res.Search.NumSats, 1)}, ...
        'HOW', {cell(Res.Search.NumSats, 1)}, ...
        'SF1', {cell(Res.Search.NumSats, 1)}, ...
        'SF2', {cell(Res.Search.NumSats, 1)}, ...
        'SF3', {cell(Res.Search.NumSats, 1)}, ...
        'SF4', {cell(Res.Search.NumSats, 1)}, ...
        'SF5', {cell(Res.Search.NumSats, 1)} ...
    );
    % Элементами всех cell-массивов (TLM, HOW, SF1, SF2, SF3, SF4, SF5)
    % являются структуры-массивы (1хN) с результатами парсинга, где N -
    % количество обработанных для спутника подкадров. Если какое то поле не
    % расшифровано из-за того, что не сошлось CRC, то его значение должно
    % быть установлено в nan. isSat2Use - массив флагов, указывающих,
    % было ли расшифровано хотя бы одно поле HOW.TOW_Count_Message, т.е.
    % имеет ли смысл в дальнейшем изучать содержимое подкадров (конечно,
    % isSat2Use = 0, если у этого спутника isSubFrameSync = 0).

%% УСТАНОВКА ПАРАМЕТРОВ
isFrSynkOk = Res.SubFrames.isSubFrameSync;
TLMMessLen = 14;
subWordsNum = 10;
%% РАСЧЁТ ПАРАМЕТРОВ

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ЦИКЛ ПО НАЙДЕННЫМ СПУТНИКАМ С УСПЕШНОЙ
% ПОДКАДРОВОЙ СИНХРОНИЗАЦИЕЙ
cell(Res.Search.NumSats, 1);

        
for k = 1 : Res.Search.NumSats
    if isFrSynkOk(k) == 1
        satWords = Res.SubFrames.Words{k};
        sizeCell = size(satWords);
        subfrNum = sizeCell(1);
%         pre      = zeros(1, subfrNum);
%         TLMMess  = zeros(subfrNum, TLMMessLen);
%         intFlag  = zeros(1, subfrNum);
        % Initialization: 
        % !!!!! доделать инициализацию SF1, SF2, SF3:
        TLMStruct = struct(...
            'Preamble',              {[]}, ...
            'TLM_Message',           {[]}, ...
            'Integrity_Status_Flag', {[]});

        HOWStruct = struct(...
            'TOW_Count', {[]},...% {zeros(1, subfrNum)}, ...
            'Alert_Flag',{[]},...% {zeros(1, subfrNum)}, ...
            'AntiSpoof_Flag',{[]},...% {zeros(1, subfrNum)}, ...
            'Subframe_ID', {[]});  %       {zeros(1, subfrNum)});
        TLMStructArr = repmat(TLMStruct, 1, subfrNum);
        HOWStructArr = repmat(HOWStruct, 1, subfrNum);
        for m = 1 : subfrNum
            TLMStructArr(m) = ParseTLM(satWords{m, 1});
            HOWStructArr(m) = ParseHOW(satWords{m, 2});

            [bits, isCRC] = Words2BitFrame(satWords(m, 3 : subWordsNum));
            if(isCRC == ones(1, 10)) % только если во всех словах подкадра
                                     % сошлись CRC, то тогда парсим его
                SatsData.isSat2Use(k) = 1;
                if HOWStructArr(m).Subframe_ID == 1 
                    SF1(m) = ParseSF1(bits);
                elseif HOWStructArr(m).Subframe_ID == 2
                    SF2(m) = ParseSF2(bits);
                elseif HOWStructArr(m).Subframe_ID == 3
                    SF3(m) = ParseSF3(bits);
                end
            else 
                fprintf("CRC сошлось не во всех словах подкадра %d", m);
            end

        end

        SatsData.TLM{k} = TLMStructArr;
        SatsData.HOW{k} = HOWStructArr;
        SatsData.SF1{k} = SF1;
        SatsData.SF2{k} = SF2;
        SatsData.SF3{k} = SF3;
    end
%
% Парсинг слова TLM
end
Res.SatsData = SatsData;
end

function [bits, isCRC] = Words2BitFrame(words3to10)
% function [bits] = Words2BitFrame(words3to10)

% Из (1х8) cell-массива Words составим кадр, т.е. добавим нулевые биты CRC
% и нулевые первые два слова. Это удобно для анализа кода по спецификации.
% Также составим массив флагов, указывающих на то, сошлось CRC в конкретном
% слове или нет
subfrLen = 300;
wordsNum = 10;
bits = zeros(1, subfrLen);
isCRC = zeros(1, wordsNum);
isCRC(1 : 2) = 1;
for k = 1 : 8
    wordSize = size(words3to10{1, k});
    if wordSize(1) ~= 0
        bits((k + 1) * 30 + (1 : 24)) = words3to10{1, k}; 
        isCRC(k + 2) = 1;
    end
    
end
end

function Data = ParseSF1(words)

% Парсинг подкадра №1
Data = struct;
Data.weekNumber = bi2de(words(61 : 70), 'left-msb');
Data.CAorPCodeOn = bi2de(words(71 : 72), 'left-msb');
Data.UraIndex = words(73 : 76);
Data.svHealth = words(77 : 82);
Data.IODC = bi2de([words(83 : 84) words(211 : 218)], 'left-msb');
Data.L2PDataFlag = words(91);

Data.Tgd = 2 ^ -31 * twoSComplement(words(197 : 204));

Data.t_oc = 2 ^   4 * bi2de(words(219 : 234), 'left-msb');
Data.a_f2 = 2 ^ -55 * twoSComplement(words(241 : 248));
Data.a_f1 = 2 ^ -43 * twoSComplement(words(249 : 264));
Data.a_f0 = 2 ^ -31 * twoSComplement(words(271 : 292));

end

function Data = ParseSF2(words)
%
% Парсинг подкадра №2
Data.IODE  = bi2de(words(61 : 68), 'left-msb');
Data.C_rs  = 2 ^ -5 * twoSComplement(words(69 : 84));
Data.dn    = 2 ^ -43 * twoSComplement(words(91 : 106));
Data.M_0   = 2 ^ -31 * twoSComplement([words(107 : 114) words(121 : 144)]);
Data.C_uc  = 2 ^ -29 * twoSComplement(words(151 : 166));
Data.ecc   = 2 ^ -33 * bi2de([words(167 : 174) words(181 : 204)], ...
                                                               'left-msb');
Data.C_us  = 2 ^ -29 * twoSComplement(words(211 : 226));
Data.sqrtA = 2 ^ -19 * bi2de([words(227 : 234) words(241 : 264)], ...
                                                               'left-msb');
Data.t_oe  = 2 ^ 4   * bi2de(words(271 : 286), 'left-msb');
Data.FitIntervalFlag = words(287);

AODO  = bi2de(words(288 : 292), 'left-msb');
Data.AODO = AODO;
if AODO == 31
    Data.AODO = 27900;
end
end

function Data = ParseSF3(words)
%
% Парсинг подкадра №3
Data.C_ic = 2 ^ -29 * twoSComplement(words(61 : 76));
Data.OMEGA_0 = 2 ^ -31 * twoSComplement([words(77 : 84) words(91 : 114)]);
Data.C_is = 2 ^ -29 * twoSComplement(words(121 : 136));
Data.i_0  = 2 ^ -31 * twoSComplement([words(137 : 144) words(151 : 174)]);
Data.C_rc = 2 ^ -5 * twoSComplement(words(181 : 196));
Data.w = 2 ^ -31 * twoSComplement([words(197 : 204) words(211 : 234)]);
Data.OMEGA_dot = 2 ^ -43 * twoSComplement(words(241 : 264));
Data.IODE = bi2de(words(271 : 278), 'left-msb');
Data.IDOT = 2 ^-43 * twoSComplement(words(279 : 292));
end

function Data = ParseSF4(Words)
%
% Парсинг подкадра №4 - реализован только для (SV_Page_ID = 56)

end

function Data = ParseSF5(Words)
%
% Парсинг подкадра №5

% Парсинг не реализован

end

function Data = ParseTLM(word)
%
% Парсинг слова TLM
Data.Preamble = comp2de(word(1 : 8));
Data.TLM_Message = comp2de(word(9 : 22));
Data.Integrity_Status_Flag = word(23);
end

function Data = ParseHOW(word)
%
% Парсинг слова HOW
Data = struct;
Data.TOW_Count = comp2de(word(1 : 17));
Data.Alert_Flag = word(18);
Data.AntiSpoof_Flag = word(19);
Data.Subframe_ID = comp2de(word(20 : 22));
end
                
function out = comp2de(in)
% in - array which consists 0, 1
% out - decimal number
% Функция перевода двоичного дополнительного кода в десятичное число
out = 0;
cnt = 0;
for k = length(in) : -1 : 1
    out = out + in(k) * 2 ^ cnt;
    cnt = cnt + 1;
end
end

function out = twoSComplement(in)
if in(1) == 0
    out = bi2de(in, 'left-msb');
else
    % обратный код (one's complement):
    oneSCompl = ~in;
    out = -(bi2de(oneSCompl, 'left-msb') + 1);
end

end