function OverviewOverlap = SaveOverviewMap(IDs, PolynyaLoc, ...
    In_LandMask, In_SeriesLengthThresYear, In_RebirthOverlapThresYear, In_Save)
PolynyaLoc_robust = cell(length(IDs), 1);
PolynyaLocCount = cell(length(IDs), 1);

for i = 1 : length(IDs)
    In_SeriesLengthThresYear_temp = In_SeriesLengthThresYear;
    if IDs(i) == 0
        continue
    elseif mod(IDs(i), 2) == 1
        In_SeriesLengthThresYear_temp = In_SeriesLengthThresYear / 2;
    end
    [PolynyaLoc_robust{i}, ~, PolynyaLocic] = unique(PolynyaLoc{i, 1});
    PolynyaLocCount{i} = accumarray(PolynyaLocic, 1);
    PolynyaLoc_robust{i} = PolynyaLoc_robust{i}...
        (PolynyaLocCount{i} > length(PolynyaLoc{i, 2}) .* In_SeriesLengthThresYear_temp);
end

IDs2 = mat2cell(IDs, ones(size(IDs)));
[IDs2, ~, OverviewMap] = ...
    Rebirth([size(In_LandMask, 1), size(In_LandMask, 2)], PolynyaLoc_robust, ...
    IDs2, In_RebirthOverlapThresYear);

for i = 1 : length(IDs2)
    if isempty(IDs2{i})
        continue
    end
    OverviewMap(OverviewMap == i) = IDs2{i}(1);
end
OverviewMap(logical(In_LandMask)) = NaN;

save(fullfile(In_Save.Path, 'OverviewMap.mat'), 'OverviewMap')

ii = 1;
for i = 1 : length(IDs2)
    if length(IDs2{i}) > 1
        for j = 2 : length(IDs2{i})
            OverviewOverlap.Get(ii) = IDs2{i}(1);
            OverviewOverlap.Give(ii) = IDs2{i}(j);
            ii = ii + 1;
        end
    end
end

end