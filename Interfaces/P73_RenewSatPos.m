function OutSatPos = P73_RenewSatPos(SatPos, TProp, Params) %#ok<INUSD>
%
% ѕересчЄт координат спутника по новому значению времени распространени€
% сигнала
%
% ¬ходные переменные
%   SatPos - массив координат спутника (8х1) из P72_GetSatPos;
%   TProp - врем€ распространени€ сигнала.
%
% ¬ыходные переменные
%   OutSatPos - массив (3x1) скорректированных координат спутника.

% WGS 84 value of the earth's rotation rate (rad/sec)
    % dOmega_e = 7.2921151467e-5;