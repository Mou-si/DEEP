function [ReincarnationBook, DeathBook] = ...
    Reincarnation(IDnumBye, DeathBook, IDNow, IDOld)
% Connect died polynya and brith polynya which have similar position
%
% input:
%   IDnumBye can be got in OverlapDye in the part of Arrange Adjacent Time
%       Open Water Into Same Order
%   DeathBook is a matirx of map recording the Number of polynyas which
%       have dead.
%   IDNow and IDOld are the matirxs of map recording the lasting OpenWater
%       at today and yesterday.
%
% output:
%   ReincarnationBook is a struct including two same length vector: Give
%       and Get. The ReincarnationBook.Give is the dead polynya; the
%       ReincarnationBook.Get id the re-brith polynya.
%   DeathBook is the same as the input ones but adds polynya that died
%       today and deletes the rebrith one.

%%
IDnumBirth = IDnumBye.Birth;
IDnumDeath = IDnumBye.Death;

%% Add Reincarnation
if ~isempty(IDnumBirth)
    IDBirth = IntersectPosition(IDNow, IDnumBirth);
    [~, ReincarnationBook] = OverlapDye(IDBirth, DeathBook);
    % delete re-brith number
    for ii = 1 : length(ReincarnationBook.Give)
        DeathBook(DeathBook == ReincarnationBook.Give(ii)) = 0;
    end
else
    ReincarnationBook = [];
end

%% Update Death Book
if ~isempty(IDnumDeath)
    DeathBooktemp = IntersectPosition(IDOld, IDnumDeath);
    DeathBook(DeathBooktemp ~= 0) = DeathBooktemp(DeathBooktemp ~= 0);
end

%% subfunction
    function Target = IntersectPosition(MatrixA, VectorB)
        global ReincarnationTol
        Target = zeros(size(MatrixA));
        if length(VectorB) > 3
            MatrixA = sparse(MatrixA);
        end
        for i = 1 : length(VectorB)
            Target(MatrixA == VectorB(i)) = VectorB(i);
        end
        se = strel('disk', ReincarnationTol + 1);
        Target = imdilate(Target, se);
    end
end