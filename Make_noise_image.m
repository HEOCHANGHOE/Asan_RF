
[FileName,PathName] = uigetfile('*.nii','Select the Mask file');

[mask, mask_size, mask_res, status, msg] = Get_nii([PathName FileName]);
if status ~= 1
    disp(['File: ' roi_list.name ' has a problem.']);
    disp(msg);
    continue;
end
mask = logical(mask);
num_noise_pt = sum(mask(:));
[r, c] = find(mask~=0);

rng('shuffle'); %rng(0, 'twister');
std_level = 6.0;

for itr_std = [1 3]
    
    if itr_std ==1
        raw_noise = round(2.4 * randn(num_noise_pt, 1));   
    elseif itr_std ==3
        raw_noise = round(6 * randn(num_noise_pt, 1)); 
    end
            
    noise_img = zeros(size(mask));
    for itr = 1 : length(r)
        noise_img(r(itr), c(itr)) = raw_noise(itr);
    end
    
    [pathstr,name,ext] = fileparts([PathName FileName]);
    nii = make_nii(noise_img, mask_res(2:4), [], [64]);
    save_nii(nii, [pathstr filesep name '_std_' num2str(itr_std) ext], []);
        
end