function [MergeIDnum, ApartIDnum] = MergeAndApart(IDnumMatch)
IDnumMatchGet = IDnumMatch.Get;
IDnumMatchGive = IDnumMatch.Give;

MergeQuan = 1;
PartGetID = unique(IDnumMatchGet);
for i = 1 : length(PartGetID)
    MergeIDindex = find(IDnumMatchGet == PartGetID(i));
    if length(MergeIDindex) >= 2
        MergeIDnum(MergeQuan).after = PartGetID(i);
        MergeIDnum(MergeQuan).before = IDnumMatchGive(MergeIDindex);
        MergeQuan = MergeQuan + 1;
    end
end

ApartQuan = 1; % Seperate open water quantity
PartGiveID = unique(IDnumMatchGive);
for i = 1 : length(PartGiveID)
    ApartIDindex = find(IDnumMatchGive == PartGiveID(i));
    if length(ApartIDindex) >= 2
        ApartIDnum(ApartQuan).before = PartGiveID(i);
        ApartIDnum(ApartQuan).after = IDnumMatchGet(ApartIDindex);
        ApartQuan = ApartQuan + 1;
    end
end

if ~exist('MergeIDnum', 'Var')
    MergeIDnum = struct([]);
end
if ~exist('ApartIDnum', 'Var')
    ApartIDnum = struct([]);
end
end