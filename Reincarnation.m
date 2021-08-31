function [ReincarnationBook, DeathBook] = Reincarnation(IDnumBye, DeathBook, IDNow, IDOld)
IDnumBirth = IDnumBye.Birth;
IDnumDeath = IDnumBye.Death;

%% Add Reincarnation
if ~isempty(IDnumBirth)
    IDBirth = zeros(size(IDNow));
    IDBirth = IntersectPosition(IDNow, IDnumBirth, IDBirth);
    [~, ReincarnationBook] = OverlapDye(IDBirth, DeathBook);
else
    ReincarnationBook = [];
end

%% Update Death Book
if ~isempty(IDnumDeath)
    DeathBook = IntersectPosition(IDOld, IDnumDeath, DeathBook);
end

%% subfunction
    function Target = IntersectPosition(MatrixA, VectorB, Target)
        if length(VectorB) > 3
            MatrixA = sparse(MatrixA);
        end
        for i = 1 : length(VectorB)
            Target(MatrixA == VectorB(i)) = VectorB(i);
        end
    end
end