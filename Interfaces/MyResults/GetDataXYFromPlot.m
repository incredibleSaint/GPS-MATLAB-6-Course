% How to get data from figure:
figNum       = 2; % current number of figure which is processed
% numOfSubplot = 1; % uncomment if there is subplot (and string 8)
numOfLine    = 1;
%--------------------------------
f = figure(figNum);
child = get(f, 'child')
plot1 = child;%child(numOfSubplot)
data = get(plot1, 'child')
lines = data{2}
valData = lines(numOfLine)
yData = valData.YData
% valData.XData = [valData.XData(1) 1 valData.XData(2 : end)];
% valData.YData = [valData.YData(1) fAlProbNonCoh(2) valData.YData(2 : end)]
