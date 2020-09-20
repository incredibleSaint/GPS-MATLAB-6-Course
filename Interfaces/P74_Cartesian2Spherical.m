function [Lat, Lon, Alt] = P74_Cartesian2Spherical(xyz, Params)
% Функция выполняет преобразование координат из прямоугольной системы
% координат в сферическую систему координат
%
% Входные параметры
%   x, y, z - координаты в прямоугольной системе координат в метрах.
%
% Выходные параметры
%   Latitude, Longitude, Altitude - широта и долгота в радианах, высота в
%     метрах.

    AlgType = Params.P74_Cartesian2Spherical.AlgType;
        % 0 - по стандарту РФ
        % 1 - по книге
        
    EllipseType = Params.P74_Cartesian2Spherical.EllipseType;
        % 0 - WGS84
        % 1 - ПЗ-90
        % 2 - Красовский - 1942
        
    % ellipticity
        switch EllipseType
            case 0
                ell = 1/298.257223563; % WGS84
            case 1
                ell = 1/298.257839303; % ПЗ-90
            case 2
                ell = 1/298.3; % Красовский - 1942
        end
        
    % semi-major axe of the earth
        switch EllipseType
            case 0
                a = 6378137; % WGS84
            case 1
                a = 6378136; % ПЗ-90
            case 2
                a = 6378245; % Красовский - 1942
        end