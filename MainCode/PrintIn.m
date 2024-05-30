function PrintIn(In)
In.TimeTotal = [datestr(In.TimeTotal(1), 29), ' to ', ...
    datestr(In.TimeTotal(end), 29)];
InSave = In.Save;
InSICFile = In.SICFile;
In = rmfield(In, 'Save');
In = rmfield(In, 'SICFile');
if isequal(class(In.TimeGap), 'datetime')
    In.TimeGap = datestr(In.TimeGap, 'yyyy-mm-dd');
end
if isequal(class(In.StartTime), 'datetime')
    In.StartTime = datestr(In.StartTime, 'yyyy-mm-dd');
end

if In.FastIceFlag
    FastIceFlag = true;
    global FastIce
    FastIceDisp = FastIce;
    FastIceDisp.TimeCover = datestr(FastIceDisp.TimeCover, 'yyyy-mm-dd');
    FastIceDisp.TimeCover = [FastIceDisp.TimeCover(1, :), ' to ', ...
        FastIceDisp.TimeCover(2, :)];
    In = rmfield(In, 'FastIceFlag');
else
    FastIceFlag= false;
end

if In.TempeJudgeFlag
    TempeJudgeFlag = true;
    global T2m_FileDir     T2m_Files1     T2m_TimeForm     T2m_Files2   T2m_Name
    global T_Ocean        T_DiffThreshold
    TempeJudge.T2m_FileDir = T2m_FileDir;
    TempeJudge.T2m_Files1 = T2m_Files1;
    TempeJudge.T2m_TimeForm = T2m_TimeForm;
    TempeJudge.T2m_Files2 = T2m_Files2;
    TempeJudge.T2m_Name = T2m_Name;
    TempeJudge.T_Ocean = T_Ocean;
    TempeJudge.T_DiffThreshold = T_DiffThreshold;
    In = rmfield(In, 'TempeJudgeFlag');
else
    TempeJudgeFlag = false;
end

%% disp

disp('Input parameters:')
disp(In);

if FastIceFlag
    disp('Mode of Land fast-ice mask: ON')
    disp(FastIceDisp)
else
    disp(['Mode of Land fast-ice mask: OFF', ...
        newline])
end

if TempeJudgeFlag
    disp('Mode of Air-ocean temperature difference judge: ON')
    disp(TempeJudge)
else
    disp(['Mode of Air-ocean temperature difference judge: OFF', ...
        newline])
end

disp('Input Files:')
disp(InSICFile);

disp('Output Files:')
disp(InSave);

%% write

if exist(InSave.Path, 'dir') == 0
    mkdir(InSave.Path);
end

fid = fopen([InSave.Path, '\Inputs.txt'], 'w');

fwrite(fid, ['Daily Edge of Each Polynya in Antarctic (DEEP-AA) v0.7.4', newline], 'char');
fwrite(fid, [newline, repmat('-', 1, 50), newline], 'char');
fwrite(fid, [newline, 'Creating Time: ', datestr(now), newline], 'char');
fwrite(fid, [newline, 'MATLAB version: ', version, newline], 'char');
fwrite(fid, [newline, repmat('-', 1, 50), newline], 'char');

fwrite(fid, [newline, 'Input parameters:', newline], 'char');
fwrite(fid, struct2str(In), 'char');

if FastIceFlag
    fwrite(fid, [newline, 'Mode of Land fast-ice mask: ON', newline], 'char');
    fwrite(fid, struct2str(FastIceDisp), 'char');
else
    fwrite(fid, [newline, 'Mode of Land fast-ice mask: OFF', ...
        newline], 'char');
end

if TempeJudgeFlag
    fwrite(fid, ...
        [newline, 'Mode of Air-ocean temperature difference judge: ON', newline], ...
        'char');
    fwrite(fid, struct2str(TempeJudge), 'char');
else
    fwrite(fid, [newline, 'Mode of Air-ocean temperature difference judge: OFF', ...
        newline], 'char');
end

fwrite(fid, [newline, 'Input Files:', newline], 'char');
fwrite(fid, struct2str(InSICFile), 'char');

fwrite(fid, [newline, 'Output Files:', newline], 'char');
fwrite(fid, struct2str(InSave), 'char');

fwrite(fid, [newline, repmat('-', 1, 50), newline], 'char');
fwrite(fid, [newline, 'End'], 'char');

fclose(fid);

end