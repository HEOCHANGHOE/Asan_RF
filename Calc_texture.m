function [texture, status, msg, Mat] = Calc_texture(img_data, mask, bins, max_dist, mask_threshold, mask_res, disp_prog, type, alpha)
%function [texture, status, msg] = Calc_texture(img_data, mask, bins, max_dist, mask_threshold, mask_res, disp_prog, type, alpha)
% By Bumwoo Park
% Update: 2018-01-23
% E-mail: julius0628@gmail.com
% Plz, Do not modify codes and distribute codes without my permission.

status = 1;
msg = '';

%% For None-wavelet filter
cur_wavelet_txt = 'NONE';
% 1. Calc First-order statics
if disp_prog
   disp('For None-wavelet........'); 
   disp('Calculating First-order statics....');
end
[stat_FO, status, msg] = Calc_First_order_statics(img_data, mask, bins);

% 3. Calc Run-Length features
if disp_prog
   disp('Calculating Run-Length Features....');
end
[stat_RL, status, msg, Mat_RL] = Calc_RL(img_data, mask, bins, type, alpha);

% 4. Calc GLCM features by distance
for dist = 1 : max_dist
    if disp_prog
        disp(['Calculating GLCM Features (distance = ' num2str(dist) ')....']);
    end
    [stat_GLCM{dist}, status, msg, Mat_GLCM] = Calc_GLCM(img_data, mask, bins, dist, type, alpha);
end

texture.(cur_wavelet_txt).FO = stat_FO;
texture.(cur_wavelet_txt).GLCM = stat_GLCM;
texture.(cur_wavelet_txt).RL = stat_RL;
Mat.RL = Mat_RL;
Mat.GLCM = Mat_GLCM;
end