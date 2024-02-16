function CheckParameters(In)
SIC.Data = zeros(size(In.SICLat, 1), size(In.SICLat, 2), ...
    1, 1, 'single');
SIC.i = [];
[SIC, ~] = ReadAndCut(SIC, 1, In.StartTime, ...
        In.TimeGap, 0, In.SICFile, In.Lim, In.MapRange, false);
InputFilesSize = [[size(In.SICLon, 1); size(In.SICLat, 1); ...
    size(In.SICFile.LandMask, 1); ...
    size(SIC.Data, 1)], ...
    [size(In.SICLon, 2); size(In.SICLat, 2); ...
    size(In.SICFile.LandMask, 2); ...
    size(SIC.Data, 2)]];
if any(~[diff(InputFilesSize(:, 1)) == 0, diff(InputFilesSize(:, 2)) == 0])
    FilesName = ["Longitude"; "Latitude"; "Land mask"; "Input SIC/PSSM file"];
    InputFilesSizeTable = table(FilesName, InputFilesSize);
    warning('Sizes of input SIC/PSSM files are not consist.')
    disp(InputFilesSizeTable)
    pause(3)
end
end
