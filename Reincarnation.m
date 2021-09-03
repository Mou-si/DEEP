function [ReincarnationBook, DeathBook] = ...
    Reincarnation(IDnumBye, DeathBook, IDNow, IDOld)
IDnumBirth = IDnumBye.Birth;
IDnumDeath = IDnumBye.Death;

%% Add Reincarnation
if ~isempty(IDnumBirth)
    IDBirth = IntersectPosition(IDNow, IDnumBirth);
    [~, ReincarnationBook] = OverlapDye(IDBirth, DeathBook);
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