clc;
clear;
close all;

%% �������� ����������
    % ���� � ���������� �����, ��� ������� ���������� �� Setup � �������
    % ����� ���������� m. ���� ����� ���� ����, �� ��������� ���
        % ��������� ���������� ������� ����������
            Listing = dir;
        % ���������� � �����
             isFind = false;
            NumFinds = 0;
        % ���� �� ���������� ���������, ������������ � ����������
            for k = 1:length(Listing)
                % ������������� ������ �����, ������ ��� ����� ������
                % ���������� �� Setup � ����� ���������� 'm'
                if ~Listing(k).isdir
                if length(Listing(k).name) >= length('Setup.m')
                if strcmp(Listing(k).name(1:length('Setup')), ...
                        'Setup') && strcmp(Listing(k).name( ...
                        end-1:end), '.m')
                    SetupFileName = Listing(k).name(1:end-2);
                    isFind = true;
                    NumFinds = NumFinds + 1;
                end
                end 
                end
            end

        % ���������� ������ � ������ �������������� ���������� ������
            if ~isFind
                error('�� ������� ����� ���� � �����������!');
            end
            if NumFinds > 1
                error('������� ������ ������ ����� � �����������!');
            end

        % �������� ��������� �� ������ �������
            Fun = str2func(SetupFileName);
        % �������� ������� � ����������� Res
            Params = Fun();

%% ��������� ����� ���������� ����������
    % ����� ���������, � ������� ���� ������ ���������� Main
        StartProcNum = Params.Main.StartProcNum;
            % 1 <= StartProcNum <= length(FuncNames)

    % ����� ���������, �� ������� ���� ��������� ���������� Main
        StopProcNum = Params.Main.StopProcNum;
            % 1 <= StopProcNum <= length(FuncNames) �
            % StartProcNum <= StopProcNum

	% ����� ���� ��������� - ��������������� ��� StartProcNum = 1, �����
	%   �� ���� �������� ��������� � ����������
    % 'Coh'/'NonCoh' - ����������� ��������� / ������������� ���������
        if StartProcNum == 1
            ProcessType = Params.Main.ProcessType;
        end

    % ���� ������������� ���������� �����������
        isDraw = Params.Main.isDraw; % 0 - �� ��������; 1 - ��������;
            % 2 - �������� � ���������; 3 - ��������, ��������� � ���������

    % ����� ����� �����-������
        % ���������� � �������-��������
            SigDirName = Params.Main.SigDirName;
        % ��� �����-������
            SigFileName = Params.Main.SigFileName;
        % ������ ��� �����-������
            SigFileName = [SigDirName, '\', SigFileName];

    % ��� ����� ��� �������� �����������
    % ���� StartProcNum = 1, �� �� ���� ������ ���������
        if StartProcNum > 1
            LoadFileName = Params.Main.LoadFileName;
        end

    % ��� ����� ��� ���������� �����������
        SaveFileName = Params.Main.SaveFileName;

    % ���������� ��� ���������� �����������
        SaveDirName = Params.Main.SaveDirName;

    % ������ ����� ������ �������� � ����������
        if StartProcNum > 1
            LoadFileName = [SaveDirName, '\', LoadFileName];
        end
        SaveFileName = [SaveDirName, '\', SaveFileName];

%% ��������� ����� ���������� ����������
    if StartProcNum == 1
        % ��������� ��������� �����-������ - �������� ����� ��. �
        % ReadSignalFromFile
            File = struct( ...
                'Name',           SigFileName, ...
                'HeadLenInBytes', Params.Main.HeadLenInBytes, ...
                'NumOfChannels',  Params.Main.NumOfChannels, ...
                'ChanNum',        Params.Main.ChanNum, ...
                'DataType',       Params.Main.DataType, ...
                'Fs0',            Params.Main.Fs0, ...
                'dF',             Params.Main.dF, ...
                'FsDown',         Params.Main.FsDown, ...
                'FsUp',           Params.Main.FsUp ...
            );
    end

%% ���������������� �����
    % ����� �������, ����������� ��������� ������� �/��� ���������� ��
    % ������� ������
        AllFuncNames = { ...
            { ... % ����� ������� ��� ����������� ���������
                 'P10_CohSearchSats', ...
                'P20_CohTrackSatsAndBitSync', ...
                'P30_CohDemodSatsSigs', ...
                'P40_GetSubFrames', ...
                'P50_ParseSubFrames', ...
                'P60_GatherSatsEphemeris', ...
                'P70_GetRXPoses', ...
            }, ...
            { ... % ����� ������� ��� ������������� ���������
                'P10_NonCohSearchSats', ...
                'P20_NonCohTrackSatsAndBitSync', ...
                'P30_NonCohDemodSatsSigs', ...
                'P40_GetSubFrames', ...
                'P50_ParseSubFrames', ...
                'P60_GatherSatsEphemeris', ...
                'P70_GetRXPoses', ...
            } ...
        };

    % ������ ��������� ����� File
        if StartProcNum == 1
            % ��������� ����� �����-������ � ��������
                [~, File] = ReadSignalFromFile(File, 0, 0);

            % ��������� ����������� ����������������� �� ��������� �
            % ���������� �������� GPS
                File.R = round(File.Fs / (1.023*10^6));
        end

    % �������� �������/�������� ���������� � ������������
        if ~isdir(SaveDirName)
            mkdir(SaveDirName);
        end

    % �������������� ��� �������� ���������-���������
        if StartProcNum == 1 % �������������
            Res = struct( ...
                'ProcessType',  ProcessType, ...
                'File',         File, ...
                'LoadFileName', 'none', ...
                'SaveFileName', SaveFileName, ...
                'Search',       [], ...
                'Track',        [], ...
                'BitSync',      [], ...
                'Demod',        [], ...
                'SubFrames',    [], ...
                'SatsData',     [], ...
                'Ephemeris',    [], ...
                'Positioning',  [] ...
            );
        else % ��������
            load(LoadFileName, 'Res');
            Res.LoadFileName = LoadFileName;
        end

    % �������� ���������� ����� �����, ���������� � Main (����) �
    % ������������ ������ � ������������
        if StartProcNum > 1
            if ~isequal(Res.File.Name, SigFileName)
                Btn = questdlg(['��������� ��� ������� ��� ����� �� ', ...
                    '��������� � ������, ���������� � ����������� ', ...
                    '�����������! ������������ ����� ��� ����� ', ...
                    '������, ���� ��������� �������������� ����� ', ...
                    '�/��� ����������� ��� � ������ ����������.'], ...
                    '��������!', '������������ ���������� ���', ...
                    '������������ ����� ���', '������ ����������', ...
                    '������ ����������');
                if isequal(Btn, '������������ ���������� ���')
                    % ������ �� ���� ������!
                elseif isequal(Btn, '������������ ����� ���')
                    Res.File.Name = SigFileName;
                elseif isequal(Btn, '������ ����������')
                    return
                end
            end
        end

    % ����� �������, ����������� ��������� ������� �/��� ���������� ��
    % ������� ������
        if isequal(Res.ProcessType, 'Coh')
            FuncNames = AllFuncNames{1};
        else
            FuncNames = AllFuncNames{2};
        end
        
%% �������� �������� ����������
    if ~((StartProcNum >= 1) && (StartProcNum <= length(FuncNames)))
        fprintf(['������ ����������� ������� ����������� ', ...
            '1 <= StartProcNum <= length(FuncNames)!\n������ Main ', ...
            '����������.\n'])
        return
    end

    if ~((StopProcNum >= 1) && (StopProcNum <= length(FuncNames)))
        fprintf(['������ ����������� ������� ����������� ', ...
            '1 <= StopProcNum <= length(FuncNames)!\n������ Main ', ...
            '����������.\n'])
        return
    end

    if ~(StartProcNum <= StopProcNum)
        fprintf(['������ ����������� ����������� ', ...
            'StartProcNum <= StopProcNum!\n������ Main ����������.\n'])
        return
    end
    
    if ~(isequal(isDraw, 0) || isequal(isDraw, 1) || ...
            isequal(isDraw, 2) || isequal(isDraw, 3))
        fprintf(['�������� isDraw ������ ���� ����� �� ', ...
            '(0, 1, 2)!\n������ Main ����������.\n'])
        return
    end
    
    if ~(isequal(Res.ProcessType, 'Coh') || ...
            isequal(Res.ProcessType, 'NonCoh'))
        fprintf(['�������� ProcessType ������ ���� ����� �� ', ...
            '(Coh, NonCoh)!\n������ Main ����������.\n'])
        return
    end

%% �������� �����
    % �� ������� �������� ��� ����������� ���������
        for k = StartProcNum : StopProcNum
            % �������� ��������� �� ������ �������
                Fun = str2func(FuncNames{k});
            % �������� ������� � ����������� Res
                Res = Fun(Res, Params);
            % �������� ������� ����������
            % � ������������� ������� �������� (P10_, P20_) �������������
            % ������ �������������� ���������� ��� �������
                if k < 7
                    save(SaveFileName, 'Res', 'Params');
                end
        end