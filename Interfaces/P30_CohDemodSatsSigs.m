function Res = P30_CohDemodSatsSigs(inRes, Params)
%
% ������� ����������� ����������� �������� ���������
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
    Demod = struct( ...
        'Bits', {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������� cell-������� Bits - ������ 4�N �������� 0/1, ���
    %   N - ���������� ���������������� ���.

%% ��������� ����������
CAShifts = Res.BitSync.CAShifts;
CorVals  = Res.Track.CorVals;
%% ���ר� ����������
    % ���������� �������� CA-����, ������������ �� ���� ���
        CAPerBit = 20;

%% �������� ����� ������� - ���� �� ��������� ���������
fprintf("������ ������������� ����������� �������� \n");

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
fprintf("���������� ����������� \n");