function [IDget, IDnumMatch, MaxID, IDnumBye] = ...
    OverlapDye(IDget, IDgive, KeepNewNum, MaxID, varargin)
% this function is used to find the overlap between SIC1 and SIC2, and dye
% IDgive ID to the IDget ID, which is overlaped.
%
% input:
%   IDget and IDget are same size matrix of natural numbers. We recommend
%       that you use bmlabel() to get them fome bw matrix. 0 means not
%       polynya
%   KeepNewNum is a switch let the new-appearing open water get a ID.
%       Defult 0
%   MaxID is recommanded to be used to let ID not being reused, when you
%       turn on the KeepNewNum. It should record the max ID you have used.
%       This function will output it too. If you don't input if the max ID
%       of IDgive will be the defult value.
%
% output:
%   IDget is a matrix with the same size of input matrix. it only have
%       numbers in the SIC2
%   MaxID is a number record the Max ID you have used.
%   IDnumMatch/Bye is the giving and getting ID of matched (X-Y) and byed
%       (0-Y or X-0). the first column is giving, and the secong one is
%       getting
%
% example:
% SIC1 = zeros(10);
% SIC2 = SIC1;
% SIC1(3 : 4, 5 : 6) = 1;
% SIC1(3 : 7, 2 : 3) = 2;
% SIC2(3 : 5, 5) = 3;
% SIC0 = OverlapDye(SIC1, SIC2)

global IDCpacity
if nargin == 2
    KeepNewNum = 0;
end

% IDget/give represent the map (Corresponding Relation) of SIC1 to SIC2
% that the num in the IDgibe should less that (IDCpacity - 1)
IDTotal = IDget .* IDCpacity + IDgive; % IDTotal is a matric including ID 
                                       % give and get
IDTotal = sparse(IDTotal(:));
IDTotal2 = nonzeros(IDTotal);
IDTotal2(IDTotal2 < IDCpacity | mod(IDTotal2, IDCpacity) == 0) = [];
IDTotalGet = floor(IDTotal2 / IDCpacity);
IDTotalGive = mod(IDTotal2, IDCpacity);

% there is many repetitive maps in the IDTotal. We find the unique maps and
% the location of maps.
[IDnumTotal, ~, ic] = unique(IDTotal); % IDnumTotal is a vector store total
                                       % ID sequences including IDget&give
                                       % intersect without repeating
% the maps inludes 4 conditions: X-Y, 0-Y, X-0, 0-0. The X-Y means overlap.
% the number > IDCpacity is Give and number < IDCpacity is Get. For
% example, when IDnumTotal = 110012, IDCpacity = 10000, the IDGet is 11,
% and IDGive is 12.
IDnumByeLogicla = IDnumTotal < IDCpacity | mod(IDnumTotal, IDCpacity) == 0;
IDnumMatch = IDnumTotal(~IDnumByeLogicla); % IDnumMatch means NOT
                                           % 0-Y or X-0 or 0-0 part
IDnumMatchGet = floor(IDnumMatch / IDCpacity); % IDnumMarchGet means only  
                                               % IDGet in IDnumMatch
IDnumMatchGive = mod(IDnumMatch, IDCpacity);
IDnumTotalGet = floor(IDnumTotal / IDCpacity); % IDnumTotalGet means IDGet 
                                               % in IDnumTotal
                                               
% if ~isempty(varargin) && isequal(varargin{1}, 'OverlapThreshold')
%     IDMatchCount = accumarray(ic,1);
%     IDMatchCount = IDMatchCount(~IDnumByeLogicla);
%     [IDTotalGetunique, ~, icIDTotalGet] = unique(IDTotalGet);
%     IDGetCount = accumarray(icIDTotalGet,1);
%     IDGetCount = IDGetCount(IDTotalGetunique);
%     [IDTotalGiveunique, ~, icIDTotalGive] = unique(IDTotalGive);
%     IDGiveCount = accumarray(icIDTotalGive,1);
%     IDGiveCount = IDGiveCount(IDTotalGiveunique);
%     IDMatchDel = [];
%     for i = 1 : length(IDnumMatch)
%         if IDMatchCount(i) < IDGetCount(IDnumMatchGet(i)) * varargin{2} && ...
%                 IDMatchCount(i) < IDGiveCount(IDnumMatchGive(i)) * varargin{2}
%             IDMatchDel = [IDMatchDel, i];
%         end
%     end
%     IDnumMatch(IDMatchDel) = [];
%     IDnumMatchGet(IDMatchDel) = [];
%     IDnumMatchGive(IDMatchDel) = [];
% end

if max(IDnumMatchGive) >= IDCpacity - 100
    error('Too small IDCpacity')
end
IDnum0 = zeros(size(IDnumTotalGet));
% the IDnumTotalGet == IDnumMatchGet(i) means that the part of IDget can
% overlap with the IDgive in the SIC2, and if it is not dyed (IDnum0 == 0),
% it should be dyed as ID_SIC2.

% the ID transformation is aimed at the long-lasting open water
if KeepNewNum
    if ~exist('MaxID', 'Var')
        % ATTENTION: here the defult value of MaxID is the max ID in
        % IDgive. If you forget input MaxID, the error will NOT display.
        MaxID = max(IDTotalGet);
    end
    % when a open water separate into more than one open water, each open
    % water will get distinct ID, the ID are appended after the last MaxID
    GiveID = unique(IDnumMatchGive);
    for i = 1 : length(GiveID)
        ApartMatchGet = IDnumMatchGet(IDnumMatchGive == GiveID(i));
        if length(ApartMatchGet) >= 2
            for k = 1 : length(ApartMatchGet)
                ApartLocation = find(IDnumTotalGet == ApartMatchGet(k) & IDnum0 == 0);
                if ~isempty(ApartLocation)
                MaxID = MaxID + 1;
                IDnum0(ApartLocation) = MaxID;
                end
            end
        end
    end
    % when open waters merge into one open water, that open water will get
    % a new ID appended after the last MaxID
    GetID = unique(IDnumMatchGet);
    for i = 1 : length(GetID)
        if length(find(IDnumMatchGet == GetID(i))) >= 2
            MergeLocation = find(IDnumTotalGet == GetID(i) & IDnum0 == 0);
            if ~isempty(MergeLocation)
                MaxID = MaxID + 1;
                IDnum0(MergeLocation) = MaxID;
            end
        end
    end
end

for i = 1 : length(IDnumMatch)
    TotalGetindex = IDTotalGet == IDnumMatchGet(i);
    TotalGiveSeries = IDTotalGive(TotalGetindex);
    TotalGiveSeries = TotalGiveSeries(TotalGiveSeries ~= 0);
    [TotalGiveID, ~, TotalGiveic] = unique(TotalGiveSeries);
    [~, TotalGiveindex] = max(accumarray(TotalGiveic, 1));
    IDnum0(IDnumTotalGet == IDnumMatchGet(i) & IDnum0 == 0) ...
        = TotalGiveID(TotalGiveindex(1)); % To overlap the open water to 
                                          % the maximum given open water
end

IDget2 = IDnum0(ic);
IDget2 = reshape(IDget2, size(IDgive));

% if KeepNewNum is on (1), the new open water will get a new ID; if not,
% the region appear in IDget but not in IDgive will be ignored
if KeepNewNum
    if isempty(varargin)
        IDget = IDget & ~IDget2;
        IDget = bwlabel(IDget);
        % MaxID is the maximal ID we have used. The new ID of new open water
        % should be larger than it to make sure that the new ID is not used,
        % and one ID represent one open water.
        IDget(IDget > 0) = IDget(IDget > 0) + MaxID;
        IDget = IDget + IDget2;
    elseif isequal(varargin{1}, 'NotConnect')
        IDget(IDget2 ~= 0) = 0;
        [IDget, ~, ic] = unique(IDget);
        IDget = [0, (1 : (length(IDget) - 1)) + MaxID];
        IDget = reshape(IDget(ic), size(IDget2)) + IDget2;
    end
    MaxIDnew = max(MaxID, max(IDget(:))); % refresh the MaxID
    if nargout == 4
        IDnumBye.Birth = ((MaxID + 1) : MaxIDnew)';
    end
    MaxID = MaxIDnew;
else
    IDget = IDget2;
end

if nargout >= 2
    clear IDnumMatch
    if nargout >= 3 % IDnumMatch is used in MergeAndApart function, 
                    % new ID after overlap is needed
        IDnumMatch.Get = IDnum0(~IDnumByeLogicla); 
    elseif nargout == 2 % IDnumMatch is used in Reincarnation function, 
                        % the input ID has been overlapd, it's no need to
                        % output the overlaped ID
        IDnumMatch.Get = nonzeros(IDnumMatchGet);
    end
    IDnumMatch.Give = nonzeros(IDnumMatchGive);
    % IDnumBye means 0-Y or X-0 part
    IDnumTotalGive = mod(IDnumTotal, IDCpacity); % IDnumTotalGive means
                                                 % IDGive in IDnumTotal
    IDnumTotalGive = unique(IDnumTotalGive);
    IDnumByeGive = setdiff(IDnumTotalGive, IDnumMatchGive);
    IDnumBye.Death = nonzeros(IDnumByeGive);
    % the first column is dead open water, the second one the the born one
end
end