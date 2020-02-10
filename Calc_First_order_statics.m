function [stat, status, msg] = Calc_First_order_statics(img_data, mask, bins)
% By Bumwoo Park
% Update: 2018-01-23
% E-mail: julius0628@gmail.com
% Plz, Do not modify codes and distribute codes without my permission.

stat = [];
status = 1;
msg = '';

% 0. initial checks
if sum(size(img_data) ~= size(mask))
    status = -1;
    msg = 'image and mask have different matrix size';
    return;
end

% 1. Extract data in Mask
data_cur = double(img_data(mask));
Counts = size(data_cur, 1);
Max = max(data_cur);
Min = min(data_cur);
Range = Max - Min;

[nelements,centers] = hist(data_cur, bins);
prob = nelements / Counts;
prob = prob(prob>eps); % exclude zero

% 2. 
stat.Mean = mean(data_cur);
stat.Var = var(data_cur);
stat.Skewness = skewness(data_cur);
stat.Kurtosis = kurtosis(data_cur);
stat.Median = median(data_cur);
stat.Min = min(data_cur);
%10th percentile
stat.Mad = mad(data_cur);
%90th percentile
stat.Max = max(data_cur);
%Interquartile range
stat.Range = Range;
%Mean absolute deviation
%Root mean absolute deviation
%Median absolute deviattion
stat.CoV = std(data_cur)/mean(data_cur);
%Cquartile coefficient of dispersion
stat.Energy = meansqr(data_cur);
stat.Rms = rms(data_cur);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stat.Range_cover = Range / (max(img_data(:)) - min(img_data(:)) + eps);
stat.Entropy = -sum(prob .* log(prob + eps) ./ log(2));
stat.Counts = size(data_cur, 1);
stat.Sum = sum(data_cur);
stat.Uniformity = sum(prob.*prob);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end