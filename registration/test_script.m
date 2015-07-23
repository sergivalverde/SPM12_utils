% ************************************************************************
% MATLAB SCRIPT TO PERFORM the inverse registration of SPM tissue priors
% into each of the VH 3T patients.
% Sergi Valverde
% July 2015
% ************************************************************************
clear all;
% IMAGE FOLDER
image_folder = '/home/s/w/SLS/images/VH3T_processed/FLAIR';    


% apply the inverse deformations from SPM12 segmentation to the TPM priors
dir_names = dir(image_folder);
for s=3:size(dir_names,1)
    current_image = dir_names(s).name;
    % spm12 priors are pulled-back to native space, and stored in the same
    % image transformation folder. The transformations are based on the
    % T1-w segmentation (brain_n3) image. 
    inverse_transf = fullfile(image_folder, current_image,'SPM12',['iy_', current_image,'_brain_n3.nii']);
    
    % make a new folder and move the registered priors there.
    mkdir([image_folder,'/',current_image,'/spm_priors']);
    output_dir = [image_folder,'/',current_image,'/spm_priors'];
    t = evalc('spm12_priors_to_native_space(inverse_transf, output_dir)');
    
    % update names
    movefile([image_folder,'/',current_image,'/spm_priors/wTPM_00001.nii'], [image_folder,'/',current_image,'/spm_priors/gm_prior.nii']);
    movefile([image_folder,'/',current_image,'/spm_priors/wTPM_00002.nii'], [image_folder,'/',current_image,'/spm_priors/wm_prior.nii']);
    movefile([image_folder,'/',current_image,'/spm_priors/wTPM_00003.nii'], [image_folder,'/',current_image,'/spm_priors/csf_prior.nii']);
    movefile([image_folder,'/',current_image,'/spm_priors/wTPM_00004.nii'    ], [image_folder,'/',current_image,'/spm_priors/scalp_prior.nii']);
    movefile([image_folder,'/',current_image,'/spm_priors/wTPM_00005.nii'], [image_folder,'/',current_image,'/spm_priors/brainmask_prior.nii']);
    movefile([image_folder,'/',current_image,'/spm_priors/wlabels_Neuromorphometrics.nii'], [image_folder,'/',current_image,'/spm_priors/structures_prior.nii']);
 
    disp(['Image ',current_image, '--> done']);        
end