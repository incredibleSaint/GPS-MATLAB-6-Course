function OutSatPos = P73_RenewSatPos(SatPos, TProp, Params) %#ok<INUSD>
%
% �������� ��������� �������� �� ������ �������� ������� ���������������
% �������
%
% ������� ����������
%   SatPos - ������ ��������� �������� (8�1) �� P72_GetSatPos;
%   TProp - ����� ��������������� �������.
%
% �������� ����������
%   OutSatPos - ������ (3x1) ����������������� ��������� ��������.

% WGS 84 value of the earth's rotation rate (rad/sec)
    % dOmega_e = 7.2921151467e-5;