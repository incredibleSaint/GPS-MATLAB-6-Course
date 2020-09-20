function [Lat, Lon, Alt] = P74_Cartesian2Spherical(xyz, Params)
% ������� ��������� �������������� ��������� �� ������������� �������
% ��������� � ����������� ������� ���������
%
% ������� ���������
%   x, y, z - ���������� � ������������� ������� ��������� � ������.
%
% �������� ���������
%   Latitude, Longitude, Altitude - ������ � ������� � ��������, ������ �
%     ������.

    AlgType = Params.P74_Cartesian2Spherical.AlgType;
        % 0 - �� ��������� ��
        % 1 - �� �����
        
    EllipseType = Params.P74_Cartesian2Spherical.EllipseType;
        % 0 - WGS84
        % 1 - ��-90
        % 2 - ���������� - 1942
        
    % ellipticity
        switch EllipseType
            case 0
                ell = 1/298.257223563; % WGS84
            case 1
                ell = 1/298.257839303; % ��-90
            case 2
                ell = 1/298.3; % ���������� - 1942
        end
        
    % semi-major axe of the earth
        switch EllipseType
            case 0
                a = 6378137; % WGS84
            case 1
                a = 6378136; % ��-90
            case 2
                a = 6378245; % ���������� - 1942
        end