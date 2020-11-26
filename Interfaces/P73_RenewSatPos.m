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
OMEGAdot_e = 7.2921151467e-5;

x_k = SatPos(4);
y_k = SatPos(5);
i_k = SatPos(6);
OMEGA_k_Ref = SatPos(7);

OMEGA_k = OMEGA_k_Ref - OMEGAdot_e * TProp;

satX = x_k * cos(OMEGA_k) - y_k * cos(i_k) * sin(OMEGA_k);
satY = x_k * sin(OMEGA_k) + y_k * cos(i_k) * cos(OMEGA_k);
satZ = y_k * sin(i_k);

OutSatPos = [satX; satY; satZ; x_k; y_k; i_k; OMEGA_k_Ref];

    