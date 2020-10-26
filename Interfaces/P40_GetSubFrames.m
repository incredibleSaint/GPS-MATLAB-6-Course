function Res = P40_GetSubFrames(inRes, Params)
%
% ������� �������������� �������� ��������� � ������� �������������
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
    SubFrames = struct( ...
        'isSubFrameSync', zeros(Res.Search.NumSats, 1), ... 
        'BitSeqNum',      zeros(Res.Search.NumSats, 1), ...
        'BitShift',       zeros(Res.Search.NumSats, 1), ...
        'Words',          {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������� ������� isSubFrameSync - ���� ���������� �����������
    %   �������������.
    % ������ ������� ������� BitSeqNum - ����� �������� ������, � �������
    %   ������� ��������� ������������� � ������� ��������.
    % ������ ������� ������� BitShift - ���������� ���, ������� ����
    %   ���������� �� ������ �������� ������ �� ������ ������� ��������.
    % ������ ������ cell-������� Words - cell-������ (Nx10), ��� N -
    %   ���������� ������������ ���������, ������ ������ - ������ 1�24 ���
    %   ��������������� �����, ���� CRC �������, � ������ ������, ���� CRC
    %   �� �������.

%% ��������� ����������

%% ���ר� ����������

%% �������� ����� ������� - ���� �� ��������� ���������
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
% �� �������� ������ ���������� ��� ��������� �����, � ������ �����
% ����������� CRC ������� �����, ���� CRC �������, �� �����������
% �������������� �����, � ��������� ������ ����������� ������ ������

end

function [isOk, BitSeqNum, BitShift] = SubFrameSync(Bits, isDraw, ...
    SaveDirName, SatNum)
%
% ������� ����������� �������������
%
% isOk      - ����, �����������, ������� ������������� ��� ���, ������ ���
%   ������ ���� ������� ������ ���� ���!
% BitSeqNum - ����� ������� ������������������, ��� ������� �������
%   �������������. �.�. ������������������, � ������� ���� ������ ��������.
% BitShift  - ���������� ���, ������� ����� ���������� � �������
%   ������������������ �� ������ ��������.

end

function [isOk, DWord] = CheckCRC(EWord)
% ������� ������������ �������� CRC ��� ������ ����� ��������������
% ���������

% �� �����:
%   EWord - ����� (������) � ����� ������ ����������� ����� � ������, �.�.
%     ����� 32 ����.

% �� ������: 
%   isOk - 1, ���� CRC ��������, 0 � ��������� ������.
%   DWord - �������������� ����� (������), �.�. ����� 24 ����.

end