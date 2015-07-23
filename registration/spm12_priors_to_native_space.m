function spm12_priors_to_native_space(transformation_nii, output_dir)
% ------------------------------------------------------------------------
%  spm12_priors_to_native_space(transformation_nii, output_dir)
%  
%  Register the TPM tissue priors used in SPM12 for tissue segmentation 
%  back to the original image space.
%
%
%  -transformation_nii  --> Nifti image containing the transformation
%                           (forward y_*.nii, or inverse iy_*.nii).
%  -output_dir          --> output directory to store the registered priors
%
%
%  July 2015 Sergi Valverde  
%  sergi.valverde@udg.edu
% ------------------------------------------------------------------------


% configuration
matlabbatch{1}.spm.util.defs.comp{1}.def = {transformation_nii};
matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = {'TPM_spm12/TPM_00001.nii'
          'TPM_spm12/TPM_00002.nii'   
          'TPM_spm12/TPM_00003.nii'   
          'TPM_spm12/TPM_00004.nii'                    
          'TPM_spm12/TPM_00005.nii'                    
          'TPM_spm12/TPM_00006.nii'
          'TPM_spm12/labels_Neuromorphometrics.nii'};
matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {output_dir};
matlabbatch{1}.spm.util.defs.out{1}.pull.interp = 4;
matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];

% run batch
spm('defaults','pet');
%spm_clf;
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);

end


