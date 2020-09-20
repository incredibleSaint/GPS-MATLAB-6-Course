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

%% РАСЧЁТ ПАРАМЕТРОВ

%% ОСНОВНАЯ ЧАСТЬ ФУНКЦИИ - ЦИКЛ ПО НАЙДЕННЫМ СПУТНИКАМ С УСПЕШНОЙ
% ПОДКАДРОВОЙ СИНХРОНИЗАЦИЕЙ

end

function [Bits, isCRC] = Words2BitFrame(Words)
% Из (1х8) cell-массива Words составим кадр, т.е. добавим нулевые биты CRC
% и нулевые первые два слова. Это удобно для анализа кода по спецификации.
% Также составим массив флагов, указывающих на то, сошлось CRC в конкретном
% слове или нет

end

function Data = ParseSF1(Words)
%
% Парсинг подкадра №1

end

function Data = ParseSF2(Words)
%
% Парсинг подкадра №2

end

function Data = ParseSF3(Words)
%
% Парсинг подкадра №3

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

function Data = ParseTLM(Word)
%
% Парсинг слова TLM

end

function Data = ParseHOW(Word)
%
% Парсинг слова HOW

end
                
function Out = comp2de(In)
%
% Функция перевода двоичного дополнительного кода в десятичное число

end