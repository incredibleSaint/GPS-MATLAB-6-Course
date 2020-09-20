function Res = P50_ParseSubFrames(inRes, Params) %#ok<INUSD>
%
% ������� ����������� �������� ���������
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
    % ���������� ���� cell-�������� (TLM, HOW, SF1, SF2, SF3, SF4, SF5)
    % �������� ���������-������� (1�N) � ������������ ��������, ��� N -
    % ���������� ������������ ��� �������� ���������. ���� ����� �� ���� ��
    % ������������ ��-�� ����, ��� �� ������� CRC, �� ��� �������� ������
    % ���� ����������� � nan. isSat2Use - ������ ������, �����������,
    % ���� �� ������������ ���� �� ���� ���� HOW.TOW_Count_Message, �.�.
    % ����� �� ����� � ���������� ������� ���������� ��������� (�������,
    % isSat2Use = 0, ���� � ����� �������� isSubFrameSync = 0).

%% ��������� ����������

%% ���ר� ����������

%% �������� ����� ������� - ���� �� ��������� ��������� � ��������
% ����������� ��������������

end

function [Bits, isCRC] = Words2BitFrame(Words)
% �� (1�8) cell-������� Words �������� ����, �.�. ������� ������� ���� CRC
% � ������� ������ ��� �����. ��� ������ ��� ������� ���� �� ������������.
% ����� �������� ������ ������, ����������� �� ��, ������� CRC � ����������
% ����� ��� ���

end

function Data = ParseSF1(Words)
%
% ������� �������� �1

end

function Data = ParseSF2(Words)
%
% ������� �������� �2

end

function Data = ParseSF3(Words)
%
% ������� �������� �3

end

function Data = ParseSF4(Words)
%
% ������� �������� �4 - ���������� ������ ��� (SV_Page_ID = 56)

end

function Data = ParseSF5(Words)
%
% ������� �������� �5

% ������� �� ����������

end

function Data = ParseTLM(Word)
%
% ������� ����� TLM

end

function Data = ParseHOW(Word)
%
% ������� ����� HOW

end
                
function Out = comp2de(In)
%
% ������� �������� ��������� ��������������� ���� � ���������� �����

end