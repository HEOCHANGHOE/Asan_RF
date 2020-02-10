clear; clc;

addpath([pwd filesep 'NIfTI_20140122']);
addpath([pwd filesep 'function']);

%% 1. Set Initial parameters
bins = [32 64 128];
max_dist = 1;
mask_threshold = 0.5;   
disp_prog = true;
type = [1 2]; % 1=Min-Max, 2=Mean+-alpha*Std
alpha = [2.0 3.0];
Conver_Z_score = true;
a=0;
b=0;
c=0;
%% 2. Loop for each folder
% 1. Load Image data
[FileName,PathName] = uigetfile('*.nii','Select the image file');
[img_data, img_size, img_res, status, msg] = Get_nii([PathName FileName]);
if status ~= 1
    disp(['File: ' img_list.name ' has a problem.']);
    disp(msg);    
end
img_data = double(img_data);
dim_num = ndims(img_data);
% 2. Load Mask data
[FileName,PathName] = uigetfile('*.nii','Select the image file');
[mask, mask_size, mask_res, status, msg] = Get_nii([PathName FileName]);
if status ~= 1
    disp(['File: ' roi_list.name ' has a problem.']);
    disp(msg);    
end

mask = logical(mask);
texture = {};
Matrix = {};
Matrix_RL = {};
size_col=size(img_data);


% 3. Calc Texture features
if dim_num == 2
    itr_dim = 4;
else 
    itr_dim = 13;
end


for itr_bins = bins
    exp_GLCM=zeros(itr_bins,itr_bins);
    exp_GLRLM=zeros(size_col(:,1),itr_bins);
    for itr_type = type
        if itr_type == 2
            a=a+1;
            for itr_alpha = alpha   
                b=b+1;
                [texture{length(texture)+1}, status, msg, Matrix{length(Matrix)+1}] = Calc_texture(img_data, mask, itr_bins, max_dist, mask_threshold, mask_res, disp_prog, itr_type, itr_alpha);                
                for itr_matrix=1:itr_dim              
                   GLCM_matrix=Matrix{a,b}.GLCM(:,:,itr_matrix)/sum(sum(Matrix{a,b}.GLCM(:,:,itr_matrix)));
                   GLRLM_matrix=cell2mat(Matrix{a,b}.RL(:,itr_matrix))/sum(sum(cell2mat(Matrix{a,b}.RL(:,itr_matrix))));
                   exp_GLCM=exp_GLCM+GLCM_matrix;
                   exp_GLRLM=exp_GLRLM+GLRLM_matrix;
                end
                result_GLCM=['result_GLCM',num2str(b),'=exp_GLCM/itr_dim;'];
                result_GLRLM=['result_GLRLM',num2str(b),'=exp_GLRLM/itr_dim;'];
                eval(result_GLCM)
                eval(result_GLRLM)
                exp_GLCM=zeros(itr_bins,itr_bins);
                exp_GLRLM=zeros(size_col(:,1),itr_bins);
            end
        else
            a=a+1;
            b=b+1;
            [texture{length(texture)+1}, status, msg, Matrix{length(Matrix)+1}] = Calc_texture(img_data, mask, itr_bins, max_dist, mask_threshold, mask_res, disp_prog, itr_type, alpha);
            %[texture{length(texture)+1}, status, msg] = Calc_texture(img_data, mask, itr_bins, max_dist, mask_threshold, mask_res, disp_prog, itr_type, alpha);
           for itr_matrix=1:itr_dim              
               GLCM_matrix=Matrix{a,b}.GLCM(:,:,itr_matrix)/sum(sum(Matrix{a,b}.GLCM(:,:,itr_matrix)));
               GLRLM_matrix=cell2mat(Matrix{a,b}.RL(:,itr_matrix))/sum(sum(cell2mat(Matrix{a,b}.RL(:,itr_matrix))));
               exp_GLCM=exp_GLCM+GLCM_matrix;
               exp_GLRLM=exp_GLRLM+GLRLM_matrix;
           end
           result_GLCM=['result_GLCM',num2str(b),'=exp_GLCM/itr_dim;'];
           result_GLRLM=['result_GLRLM',num2str(b),'=exp_GLRLM/itr_dim;'];
           eval(result_GLCM)
           eval(result_GLRLM)
           exp_GLCM=zeros(itr_bins,itr_bins);
           exp_GLRLM=zeros(size_col(:,1),itr_bins);
           
        end
        a=0;
    end    
end

%%
%% 3. Save Total Results
% 1) Gather all patients data
for itr = 1 : length(texture)
    % Loop for patients
    data_patient = [];
    texture_cur = texture{itr};
    filter_name = fieldnames(texture_cur);
    for itr_filter = 1 : length(filter_name)
        % Loop for Wavelet-filters...
        result = texture_cur.(filter_name{itr_filter});
        
        % 1) Add First-order and Shape
        data_filter = [struct2cell(result.FO)];
        % 2) Add GLCM
        for itr_dist = 1 : max_dist
            data_filter = [data_filter; struct2cell(result.GLCM{itr_dist})];
        end
        % 2) Add RL
        data_filter = [data_filter; struct2cell(result.RL)];
        data_patient = [data_patient; cell2mat(data_filter)];
    end
    
    if itr == 1
        total_data = zeros(size(data_patient, 1), length(texture));        
    end
    total_data(:, itr) = data_patient;
    final = total_data.';
end
