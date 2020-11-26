function [SatPos, GPSTime, TProp] = P72_GetSatPos(Data, inGPSTime, ...
    inTProp, Params) %#ok<INUSD>
%
% Фунция производит вычисление координат спутника в момент времени
% inGPSTime и учитывает время распространения сигнала inTProp при переводе
% координат в систему ECEF
%
% Входные переменные
%   Data - структура, содержащая, как минимум, параметры подкадров 1, 2 и
%     3;
%   inGPSTime - время испускания сигнала;
%   inTProp - время распространения сигнала.
%
% Выходные переменные
%   SatPos - массив (8х1) координат и параметров спутника для пересчёта
%       координат:
%         [x; y; z; ... % координаты в прямоугольной системе координат
%         xs_k; ys_k; i_k; ... % исходные координаты спутника
%         Omega_k; % исходное значение Omega_k
%         ZaZa]; % параметр для пересчёта Omega_k в Omega_k_TProp
%   GPSTime - скорректированное время испускания сигнала;
%   TProp - скорректированное время распространения сигнала.
if nargin == 2
   inTProp = 0;
   Params = 0;
elseif nargin == 3
   Params = 0;
end

%--- Time Correction ----- 
tc = inGPSTime - Data.t_oc;
delta_t_sv = Data.a_f0 + Data.a_f1 * tc + Data.a_f2 * tc ^ 2 - Data.T_GD;%* 1e-9;

GPSTime = inGPSTime - delta_t_sv;

% GPSTime(Transmit)           Receiving time 
% ---|----------------------------|-----------------------
%     \__________TProp___________/
TProp = 68e-3 + inTProp + delta_t_sv;

%--- end Time Correction -----------------------


u = 3.986005e14;
OMEGAdot_e = 7.2921151467e-5;
pi = 3.1415926535898;
C = 2.99792458e8;

t = GPSTime;

A = Data.sqrtA ^ 2; 
n_0 = sqrt(u / A ^ 3);
F = -2 * sqrt(u) / C ^ 2;

t_oc = Data.t_oe;%t_oc~t_oe(because of there is no t_oc in .rnx files v3.xx)
% delta_t_sv = s1.a_0 + s1.a_1*(t-t_oc)+s1.a_2*(t-t_oc)^2 - s1.T_GD1*1e-9 ;

% t = t - delta_t_sv;
t_k = t - Data.t_oe;
n = n_0 + Data.Delta_n * pi;
M_k = Data.M_0 * pi + n * t_k;

epsilon = 1e-12;
% E_k   = rem(SolvKeplerEq(M_k, Data.ecc, epsilon), 2 * pi);
E_k = SolvKeplerEq(M_k, Data.ecc, epsilon);
v_k  = atan2(sqrt(1 - Data.ecc ^ 2) * sin(E_k), cos(E_k) - Data.ecc);

% phi = rem(v_k + Data.omega, 2 * pi);
phi = v_k + Data.omega * pi;

delta_u_k = Data.C_us * sin(2 * phi) + Data.C_uc * cos(2 * phi);
delta_r_k = Data.C_rs * sin(2 * phi) + Data.C_rc * cos(2 * phi);         
delta_i_k = Data.C_is * sin(2 * phi) + Data.C_ic * cos(2 * phi);

u_k = phi + delta_u_k;
r_k = A * (1 - Data.ecc * cos(E_k)) + delta_r_k;
i_k = Data.i_0 * pi + pi * Data.IDOT * t_k + delta_i_k;

x_k = r_k * cos(u_k);
y_k = r_k * sin(u_k);

OMEGA_k_Ref = Data.Omega_0 * pi +(Data.DOmega * pi - OMEGAdot_e) * t_k - ...
                                                   OMEGAdot_e  * Data.t_oe;
OMEGA_k = OMEGA_k_Ref - OMEGAdot_e * TProp;

satX = x_k * cos(OMEGA_k) - y_k * cos(i_k) * sin(OMEGA_k);
satY = x_k * sin(OMEGA_k) + y_k * cos(i_k) * cos(OMEGA_k);
satZ = y_k * sin(i_k);

SatPos = [satX; satY; satZ; x_k; y_k; i_k; OMEGA_k_Ref]';

