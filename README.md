# SPM12 Utils

Some utilities for the Matlab SPM12 toolbox.

## Tissue segmentation

The function `batch_segmentation_spm12.m` is designed to perform tissue segmentation of several images in batch mode. Usually, this process is done in parallel, using the _Parallel Computing Toolbox_.  The function expects an indexed struct with the following information:

`struct{scan_index}.image_folder = 'folder where input images live'
  struct{scan_index}.scan_name =    'patient folder'
  struct{scan_index}.image_identifier = 'image identifier'
`
Also, several options have to set beforehand:

` options.SPM_PATH = 'folder where SPM12 lives
  options.SPM_SAVE_TRANSFORMATIONS = 'if 1, SPM12 will store the internal registration transformations (useful to use the internal priors)
  options.BUILD_DISCRETE = 'if 1, an additional scan with the discretized 3 main tissues is also stored.
  options.PACKRESULTS = 'if 1, results are packed in a SPM12 folder in the location than the input image.
`

## Registration 

The function `spm12_priors_to_native_space` is designed to pull-back the tissue prior atlases used for tissue segmentation into the native patient space. The priors are included with the function.





