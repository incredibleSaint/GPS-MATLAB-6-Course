clc;
clear all;
close all;

File.Name = 'X:\Методические материалы\СНС\MATLAB\Signals\28_01_2019__17_02_51_x02_1ch_16b_15pos_200000ms.dat';
File.HeadLenInBytes = 0;
File.NumOfChannels = 1;
File.ChanNum = 0;
File.DataType = 'int16';
File.Fs0 = 2*1.023*10^6;
File.dF = 0;
File.FsDown = 1;
File.FsUp = 1;

NumOfShiftedSamples = 0;
NumOfNeededSamples = 5*2*1023;
[Signal, ~] = ReadSignalFromFile(File, NumOfShiftedSamples, NumOfNeededSamples);
      