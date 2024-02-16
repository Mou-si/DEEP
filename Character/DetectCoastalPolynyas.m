function CoastalPolynyas = DetectCoastalPolynyas(PolynyaLoc, varargin)
persistent LandMaskCoastal
if isempty(LandMaskCoastal)
    In_LandMask = varargin{1};
    In_Resolution = varargin{2};
    In_LandMask = logical(In_LandMask);
    SE = strel('disk', round(50 / In_Resolution));
    LandMaskopen = imdilate(In_LandMask, SE);
    LandMaskCoastal = xor(LandMaskopen, In_LandMask);
end
if min(size(PolynyaLoc)) > 1
    % if the input PolynyaLoc is a matrix, i.e., it is AllIndexYear
    % return the Coastal Polynyas' IDs.
    CoastalPolynyas = PolynyaLoc(LandMaskCoastal);
    CoastalPolynyas = unique(CoastalPolynyas);
    if CoastalPolynyas(1) == 0
        CoastalPolynyas(1) = [];
    end
else
    % if the input PolynyaLoc is a vector, i.e., it is TotalPhyIDnum in 
    % CrossYearSeriesCombine.m, return a flage for whether this polynya is 
    % costal.
    CoastalPolynyas = any(LandMaskCoastal(PolynyaLoc));
end
end