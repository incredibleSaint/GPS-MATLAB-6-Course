numOfCAInBit = 20;
NBits4Sync = 50;
numOfCA = NBits4Sync * numOfCAInBit;
bitSync = zeros(Res.Search.NumSats, numOfCAInBit);
for k = 1 : Res.Search.NumSats
    corr = Res.Track.CorVals{k, 1};
    phaseDiff = corr(2 : numOfCA + 1) .* conj(corr(1 : numOfCA));
    bitSync(k, :) = abs(sum(reshape(phaseDiff, numOfCAInBit,NBits4Sync), 2));
    figure; plot(bitSync(k, :)) 
%     Track.SamplesShifts{k, 1} = samplesShifts;
%     Track.CorVals{k, 1}       = corr;
end