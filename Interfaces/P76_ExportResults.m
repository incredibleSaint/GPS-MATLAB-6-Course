function P76_ExportResults(RXPoses, Params)
%
% ������� �������� ��������� � ���� *.kml

%% ��������� ����������
    % ����� �� ��������� ����� ������� ��������
        isSaveUserPoses = Params.P76_ExportResults.isSaveUserPoses;
    % ����� �� ��������� ����� ������� ���������
        isSaveSatsPoses = Params.P76_ExportResults.isSaveSatsPoses;
    % ����� �� ��������� ��� ��������� ��������
        isCalcCoordinatesVariance = Params.P76_ExportResults.isCalcCoordinatesVariance;
    % ����� �� ���������� ����� ������� ��������
        isNumerateLabels = Params.P76_ExportResults.isNumerateLabels;

    % ��� ����� ��� ���������� �����������
        FileName = [Params.Main.SaveDirName, '\', ...
            Params.P76_ExportResults.FileName];