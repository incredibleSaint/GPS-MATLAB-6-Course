function P76_ExportResults(RXPoses, Params)
%
% Функция экспорта координат в файл *.kml

%% УСТАНОВКА ПАРАМЕТРОВ
    % Нужно ли сохранять метки позиции приёмника
        isSaveUserPoses = Params.P76_ExportResults.isSaveUserPoses;
    % Нужно ли сохранять метки позиции спутников
        isSaveSatsPoses = Params.P76_ExportResults.isSaveSatsPoses;
    % Нужно ли вычислять СКО координат приёмника
        isCalcCoordinatesVariance = Params.P76_ExportResults.isCalcCoordinatesVariance;
    % Нужно ли нумеровать метки позиций приёмника
        isNumerateLabels = Params.P76_ExportResults.isNumerateLabels;

    % Имя файла для сохранения результатов
        FileName = [Params.Main.SaveDirName, '\', ...
            Params.P76_ExportResults.FileName];