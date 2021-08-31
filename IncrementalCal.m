function DataAll = IncrementalCal(DataAll, TimeAdvance, MyFun, RawData, varargin)
% Incremental calculation. With this function, we can calculate the
% Incremental data only, which will save too much source. you can input a
% matrix and some needed imformation, and we will give you a same-size
% matrix with new data but old data is replaced
%
% input:
%   DataAll in the input is data that you want to refresh some of it. It
%       must be a 3-D matrix and the 3rd dim should be time dim.
%   TimeAdvance is how much (hoe long time) data we should calculate now.
%   MyFun is a function you use it to calculate. input it by an @ before
%       the function name
%   RawData data used to refresh DataAll by @MyFun, it will be input in
%       @Myfun
%   You can also input some constant for @Myfun
%
% output:
%   DataAll have the same size as the DataAll you input, but some data have
%   been refreshed, and it will be sort as time (3rd dim)
%
% example:
% % create a scrip and copy thest code
% DataAll = 1 : 5;
% DataAll = reshape(DataAll, 1, 1, 5);
% TimeAdvance = 2;
% RawData = [3 : 7; 3 : 7];
% DataAll = IncrementalCal(DataAll, TimeAdvance, @MyFun, RawData);
% function a = MyFun(b, j)
%     a = sum(b(:, end - j));
% end

% TimeAdvance should less than the length of time dim of DataAll
if TimeAdvance > size(DataAll, 3)
    TimeAdvance = size(DataAll, 3);
end
% delete the old data and give new data some place
DataAll = DataAll(:, :, TimeAdvance + 1 : end);
% calculate
for j = 1 : TimeAdvance
    DataAll(:, :, j) = MyFun(RawData, j, varargin{:});
end
end