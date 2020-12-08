  function Res = P20_CohTrackSatsAndBitSync(inRes, Params)
%
% ������� ������������ �������� ��������� � ������� �������������
%
% ������� ����������
%   inRes - ��������� � ������������ ������, ����������� � Main;
%
% �������� ����������
%   Res - ���������, ������� ���������� �� inRes ����������� ������ ����,
%       �������� �������� ���� ���� � ����.

% �������������� �����������
    Res = inRes;

%% ������������� ����������
    Track = struct( ...
        'SamplesShifts',     {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',           {cell(Res.Search.NumSats, 1)}, ...
        'HardSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'FineSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'EPLCorVals',        {cell(Res.Search.NumSats, 1)}, ...
        'DLL',               {cell(Res.Search.NumSats, 1)}, ...
        'FPLL',              {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������ cell-�������� SamplesShifts, CorVals, HardSamplesShifts
    %   FineSamplesShifts �������� �������� 1xN, ��� N - ����������
    %   �������� CA-���� ���������������� ��������, ��������� � �����-
    %   ������ (N ����� ���� ������ ��� ������ ���������).
    % ������ ������� ������� SamplesShifts{k} - ������� ����������
    %   ��������, ������� ���� ���������� � �����-������ �� ������
    %   ���������������� ������� CA-����.
    % ������ ������� ������� CorVals{k} - ����������� �������� ����������
    %   ����� �������, ���������� ��������������� ������ CA-����, � �������
    %   ��������.
    % ������ ������� �������� HardSamplesShifts{k}, FineSamplesShifts{k} -
    %   �������������� ������� � ����� ����� �������� SamplesShifts{k}.
    % ������ ������ cell-������� EPLCorVals �������� �������� 3xN ��������
    %   Early, Promt � Late ����������. ��� ����: SamplesShifts{k} =
    %   EPLCorVals{k}(2, :).
    % DLL, FPLL - ��� ������������� ���� ���� � �������-���� �������.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % ������ ������� ������� CAShifts - ���������� �������� CA-����,
    %   ������� ���� ���������� �� ������ ����.
    % ������ ������ ������� Cors - ����������, �� ������� �������� �������
    %   ������������ ������� �������������.

%% ��������� ����������
    % ������� ��������
        DLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.DLL.FilterOrder;
        FPLL.FilterOrder = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterOrder;
        
    % � DLL � FPLL ����� ��������� ������� ������ ��� ������� �� ��� �����
    % ����������
        % ������ ��������
            DLL.FilterBands  = Params.P20_CohTrackSatsAndBitSync.DLL.FilterBands;
            FPLL.FilterBands = Params.P20_CohTrackSatsAndBitSync.FPLL.FilterBands;
            
        % ���������� �������� ���������� ��� ����������
            DLL.NumsIntCA  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsIntCA;
            FPLL.NumsIntCA = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsIntCA;

	% ��������� ���������� �������� CA-����, ����������� ��� ��������
	% ������������� �������� ����� ����������� DLL � FPLL. ��������
	% �������� �� �������� integrate and dump
        DLL.NumsCA2CheckState  = Params.P20_CohTrackSatsAndBitSync.DLL.NumsCA2CheckState;
        FPLL.NumsCA2CheckState = Params.P20_CohTrackSatsAndBitSync.FPLL.NumsCA2CheckState;
        
    % ��������� �������� ��� �������� ����� �����������
    % ���� �������� > HiTr, �� ��������� � ��������� (����� ���������)
    %   ���������
    % ���� �������� < LoTr, �� ��������� � ���������� (�����
    %   ��������������)���������
        DLL.HiTr = Params.P20_CohTrackSatsAndBitSync.DLL.HiTr;
        DLL.LoTr = Params.P20_CohTrackSatsAndBitSync.DLL.LoTr;
        
        FPLL.HiTr = Params.P20_CohTrackSatsAndBitSync.FPLL.HiTr;
        FPLL.LoTr = Params.P20_CohTrackSatsAndBitSync.FPLL.LoTr;

    % ������, � ������� ������������ ����������� ����� ������������
    % CA-�����
        NumCA2Disp = Params.P20_CohTrackSatsAndBitSync.NumCA2Disp;

    % ������������ ����� �������������� CA-����� (inf - �� ����� �����!)
        MaxNumCA2Process = Params.P20_CohTrackSatsAndBitSync.MaxNumCA2Process;

    % ���������� ���, ������������ ��� ������� �������������
        NBits4Sync = Params.P20_CohTrackSatsAndBitSync.NBits4Sync;

%% ���������� ����������
    % Track.FPLL = FPLL; % �� �����, ��� ��� �� ����� ����� ������� �
    % Track.DLL = DLL;   % �����
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% ���ר� ����������
    % ����� CA-���� � ������ ������� �������������
        CALen = 1023 * Res.File.R;

    % ���������� �������� CA-����, ������������ �� ���� ���
        CAPerBit = 20;

    % ������������ CA-����, ��
        TCA = 10^-3;

        
%% �������� ����� ������� - ������� � ������� �������������
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
fprintf('%s     ��������� ������� �������������.\n', datestr(now));

end