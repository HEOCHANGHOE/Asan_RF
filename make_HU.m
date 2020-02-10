clc;
clear;

[FileName,PathName] = uigetfile('*.nii','Select the Mask file');

[img_data, mask_size, mask_res, status, msg] = Get_nii([PathName FileName]);
if status ~= 1
    disp(['File: ' roi_list.name ' has a problem.']);
    disp(msg);
    continue;
end

Bone =img_data;
air = img_data;


[pathstr,name,ext] = fileparts([PathName FileName]);
nii = make_nii(Bone, mask_size, mask_res(2:4), 64);
save_nii(nii, [pathstr filesep name '_bone'  ext], []);


[pathstr,name,ext] = fileparts([PathName FileName]);
nii_2 = make_nii(air, mask_size, mask_res(2:4), 64);
save_nii(nii_2, [pathstr filesep name '_air'  ext], []);