function PolynyasYear = GetPolynyasYear(IDSeriesYear)
for i = 1 : length(IDSeriesYear)
    if isempty(IDSeriesYear{i})
        continue
    end
    PolynyasYear(i) = sum(sum(~isnan(IDSeriesYear{i}), 2) > 0);
end
end