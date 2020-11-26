function UPos = P71_GetOneRXPos(Es, inGPSTimes, inTimeShifts, ...
    SampleNums, Params)
%
% ������� ������� ������ ������ ��������� ��������
%
% ������� ����������
%   Es - cell-������ � ����������� ���������;
%   inGPSTimes - ������� �������, � ������� ���� �������� ������� ��
%       ���������;
%   inTimeShifts - ������� �������� �������� ��������������� ��������
%       ��������� �� ����� ���������� ������������ ��������
%       ���������������;
%   SampleNums - ������ ��������, � ������� ������ ������� ��������� �
%       ������� ������� inGPSTimes.
%
% �������� ����������
%   UPos - ���������-��������� � ������:
%       x, y, z - ���������� � ������������� ���
%       T0 - ����� ������������ ������ �� �������
%       tGPSs, SampleNums - �������� ������� GPS ��� �������� �������� 
%       Lat, Lon, Alt - ������, �������, ������
%       SatsPoses - ���������� ���������, ������� �� ���������
%           x, y, z - ���������� � ������������� ���;
%           xs_k, ys_k, i_k - ���������� ����� ���������������� ��;
%           Lat, Lon, Alt - ������, �������, ������;
%           El, Az - ���� ��������� � ������;
%       NumIters, MaxNumIters - ����������� � ������������ ����� ��������;
%       Delta, MaxDelta - ����������� � ������������ �������� ������
%           ��������� ��������� ������������ ����� ��������� ����������
%           (�);
%       inGPSTimes, GPSTimes, inTimeShifts, TimeShifts - ����������
%           ���������� � ����������������� ����������.

%% ��������� ����������
    % ������������ ����� ��������
        MaxNumIters = Params.P71_GetOneRXPos.MaxNumIters;
    % ������������ ��������� ��������� ������������ ����� ���������
    % ���������� (�). ���� ����������� ��������� ������, �� ����
    % ���������������
        MaxDelta = Params.P71_GetOneRXPos.MaxDelta;

%% ��������� ��������
    % �������� �����, �/�
        c = 299792458;
    % ������ �����, �
        R = 6356863;
    % ������� (m)
    dvMax = 0.01;
    % ����. ����� �������� �������
    CntMax = 100;
...
startInTProp = 0.068;
% inTProp = ones(1, Params.CurSatNums2Pos(end));
% inTProp = startInTProp * inTProp;
CurSatNums2Pos = Params.CurSatNums2Pos;
% inTimeShifts = [0    0.0044    0.0060    0.0039];
for k = 1 : length(Params.CurSatNums2Pos)
    Esat = Es{1, k};
    [SatPos(:, k), GPSTime(k), TProp(k)] = P72_GetSatPos(...
                                  Esat, inGPSTimes(k), inTimeShifts(k) ...
                                  , Params);
%                                                 startInTProp, Params);
end

TPropStart = TProp - startInTProp;
%-------- Initialisation ----------
xU(1) = 0;%2.758e6;%;0;
yU(1) = 0;%1.61e6;%;0;
zU(1) = 0;%5.49e6;%;0;
T0 = startInTProp;
dv = dvMax * 2;%startInTProp * c;
cnt = 1;
cT0 = c * T0;
cT  = c * TPropStart;

sizeSatPos = size(SatPos);
satsNum = sizeSatPos(2);
A = zeros(satsNum, 4);
%----------------------------------
while(dvMax < dv && CntMax > cnt)
    % ���������� ���������������:
    cTij = sqrt((SatPos(1, :) - xU(cnt)) .^ 2 + ...
           (SatPos(2, :) - yU(cnt)) .^ 2 + (SatPos(3, :) - zU(cnt)) .^ 2) ...
                                                                    - cT0;
%     Tij = cTij / c;
    Bj = cT - cTij;
    
    A(:, 1) = -(SatPos(1, :)' - xU(cnt)) ./ (cTij + cT0)'; 
    A(:, 2) = -(SatPos(2, :)' - yU(cnt)) ./ (cTij + cT0)'; 
    A(:, 3) = -(SatPos(3, :)' - zU(cnt)) ./ (cTij + cT0)';
    A(:, 4) = -1;
%     A = [aX.' aY.' aZ.' -1 * ones(1, length(Tij))'];
%   dClockErr = c * TProp;
%     dr = dClockErr - psRngComputed;
%     cT0 = c * T0(cnt);
    
%     B = c * (T0 - TProp);


%     alpX = (SatPos(1, :) - xU(cnt)) ./ (psRngComputed - dClockErr);
%     alpY = (SatPos(2, :) - yU(cnt)) ./ (psRngComputed - dClockErr);
%     alpZ = (SatPos(3, :) - zU(cnt)) ./ (psRngComputed - dClockErr);
    
%     A = [alpX' alpY' alpZ' ones(1, length(dr))'];
    
%     dNow = (inv(A * A.') * A)' * dr';
%     dNow = (inv(A.' * A) * A.') * dr';
    if satsNum == 4
        invA = inv(A);
    else
        invA = pinv(A);
    end
    dNow = invA * Bj.';
    dv = sqrt(sum(dNow .^ 2, 1));
    xU(cnt + 1) = xU(cnt) + dNow(1);
    yU(cnt + 1) = yU(cnt) + dNow(2);
    zU(cnt + 1) = zU(cnt) + dNow(3);
    cT0 = cT0 + dNow(4);
    for k = 1 : length(Params.CurSatNums2Pos)
        TPropNew = (cT0 + c * TPropStart(CurSatNums2Pos(k))) / c;
        OutSatPos = P73_RenewSatPos(SatPos(:, k), ...
                        TPropNew, Params);
        SatPos(:, k) = OutSatPos;
    end
    cnt = cnt + 1;
end

UPos.x = xU(end);
UPos.y = yU(end);
UPos.z = zU(end);
[Lat, Lon, Alt] = P74_Cartesian2Spherical([xU(end) yU(end) zU(end)], Params);
UPos.Lat = Lat;
UPos.Lon = Lon; 
UPos.Alt = Alt;
UPos.T0 = cT0 / c;
UPos.SampleNums = SampleNums;
UPos.SatPos = SatPos;
UPos.NumIters = cnt;
UPos.inTimeShifts = inTimeShifts;
UPos.inGPSTimes = inGPSTimes;
%       SatsPoses - ���������� ���������, ������� �� ���������
%           x, y, z - ���������� � ������������� ���;
%           xs_k, ys_k, i_k - ���������� ����� ���������������� ��;
%           Lat, Lon, Alt - ������, �������, ������;
%           El, Az - ���� ��������� � ������;
%       NumIters, MaxNumIters - ����������� � ������������ ����� ��������;
%       Delta, MaxDelta - ����������� � ������������ �������� ������
%           ��������� ��������� ������������ ����� ��������� ����������
%           (�);
%       inGPSTimes, GPSTimes, inTimeShifts, TimeShifts


% =========================================================
