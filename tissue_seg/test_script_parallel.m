% ************************************************************************
% MATLAB SCRIPT TO PERFORM T1-w image segmentation on the VH 3T patient
% images. This script is configured to process the scans in parallel using 
% a roughly non-elegant way :(
%
% The script "spm12_individual_segmentation" performs an individual
% segmentation tissue segmentation where the following options have to set:
%  
% SPM_PATH = 'folder where SPM12 lives'
% SPM_SAVE_TRANSFORMATIONS = 'if 1, SPM12 will store the internal
%                             registration transformations (useful to use 
%                             the internal priors)
% BUILD_DISCRETE = 'if 1, an additional scan with the 3 main tissues is
%                   also stored. 
% PACKRESULTS = 'if 1, results are packed in a SPM12 folder in the location
%                than the input image.
%
% Sergi Valverde
% July 2015
% ************************************************************************

clear all;

%% options

% IMAGE FOLDER
image_folder = '/home/s/w/SLS/images/VH3T_processed/PD';

% SPM12 configuration
options.SPM_PATH = '/home/s/dev/MATLAB/libs/spm12/';
options.SPM_SAVE_TRANSFORMATIONS = 1;
options.BUILD_DISCRETE = 1;
options.PACKRESULTS=1;

% PARALEL PROCESSING (number of virtual worker to use)
par_processes = 4;


%%  scan images all possible configs and split in different chunks.
s = 1;
dir_names = dir(image_folder);

for s=3:size(dir_names,1)
   image_properties.image_folder = image_folder;
   image_properties.scan_name = dir_names(s).name;
   image_properties.image_identifier = [dir_names(s).name,'_brain_n3'];
   data{s-2}= image_properties;
end

clear scans_by_thread;
num_scans_by_thread = round(size(data,2) / par_processes);
ff =1;

for i=1:(par_processes-1)
    scans_by_thread{i,:} = data(ff:ff+(num_scans_by_thread-1));
    ff = ff + num_scans_by_thread;
end
scans_by_thread{i+1,:} = data(ff:size(data,2));




%% setup the parallel pool: just start it and configure it to accept a
% particular number of cores

p = par_processes;
c = parcluster(); 
c.NumWorkers = p;
if isempty(gcp), parpool; end

% add scans to each of the virtual workers
parfor (i=1:p,p)
    batch_segmentation_spm12(scans_by_thread{i,:},i, options);
end 
