function batch_segmentation_spm12(image_pool, t, options)
% ************************************************************************
% Batch image segmentation with SPM12 toolbox. The function is mainly
% designed to use it in parallel with several virtual MATLAB workers.
%
% image_pool--> Matlab struct containing the relevant information to
%               segment:
%               
%               struct{scan_index}.image_folder = 'folder where input images live'                                                
%               struct{scan_index}.scan_name =    'patient folder'
%               struct{scan_index}.image_identifier = 'image identifier'
% 
% t         --> number of threat (just to print and loosely control the 
%               processing flow
%
% options -->  some SPM12 options to set:
%  
%              SPM_PATH = 'folder where SPM12 lives'
%              SPM_SAVE_TRANSFORMATIONS = 'if 1, SPM12 will store the internal
%                                       registration transformations (useful to use 
%                                       the internal priors)
%              BUILD_DISCRETE = 'if 1, an additional scan with the 3 main 
%                              tissues is also stored. 
%              PACKRESULTS = 'if 1, results are packed in a SPM12 folder in the location
%                             than the input image.
%
%
% WARNING: The function loads and saves compressed NIFTI files. 
% 
% Sergi Valverde
% July 2015
% ************************************************************************
    
    num_scans  = size(image_pool,2);
    BUILD_DISCRETE = options.BUILD_DISCRETE;
    PACK_RESULTS = options.PACKRESULTS;
    
    for s=1:num_scans
        
        current_image = image_pool{s};
        % image information
        input_folder = current_image.image_folder;
        scan_number = current_image.scan_name;
        identifier = current_image.image_identifier;
        seg_path = [input_folder,'/',scan_number];
        
        % 1. so far, SPM12 requires the input image as a nifti extension
        % without compression
        gunzip([seg_path,'/',identifier,'.nii.gz']);
        
        % 2. callback to individual spm12 tissue segmentation script
        image_seg = [seg_path,'/',identifier];
        T = evalc('call_batch(image_seg, options)');
        gzip([seg_path,'/',identifier,'.nii']);
        
        % 3. binarize the tissue masks
        % build a binary segmentation
       
        if BUILD_DISCRETE
            csf_in = load_untouch_nii([seg_path,'/c3',identifier,'.nii']);
            gm_in = load_untouch_nii([seg_path,'/c1',identifier,'.nii']);
            wm_in = load_untouch_nii([seg_path,'/c2',identifier,'.nii']);
            sz = size(csf_in.img);

            seg = zeros(3,size(csf_in.img(:)',2));
            seg(1,:) = csf_in.img(:)';
            seg(2,:) = gm_in.img(:)';
            seg(3,:) = wm_in.img(:)';

            [max_voxel, ~] = max(seg);

            % labeling
            label_vol = (seg(1,:) == max_voxel) + ((seg(2,:) == max_voxel)*2) + ((seg(3,:) == max_voxel)*3);
            label_vol = (label_vol <= 3).*label_vol;
            label_vol = reshape(label_vol, sz);
            csf_in.img = single(label_vol);
            csf_in.hdr.dime.scl_slope = 1;
            save_compressed_nii(csf_in,[seg_path,'/',scan_number,'_SPM12']);
        end
        
        % 4. compress prob masks
        gzip([seg_path,'/c1',identifier,'.nii']);
        gzip([seg_path,'/c2',identifier,'.nii']);
        gzip([seg_path,'/c3',identifier,'.nii']);
        delete([seg_path,'/c1',identifier,'.nii']);
        delete([seg_path,'/c2',identifier,'.nii']);
        delete([seg_path,'/c3',identifier,'.nii']);
        
        % move results to a new directory
        if PACK_RESULTS
           mkdir([seg_path,'/SPM12']);
           movefile([seg_path,'/c1',identifier,'.nii.gz'], [seg_path,'/SPM12/']);
           movefile([seg_path,'/c2',identifier,'.nii.gz'], [seg_path,'/SPM12/']);
           movefile([seg_path,'/c3',identifier,'.nii.gz'], [seg_path,'/SPM12/']);
           movefile([seg_path,'/',scan_number,'_SPM12.nii.gz'], [seg_path,'/SPM12/']);
           if options.SPM_SAVE_TRANSFORMATIONS
               movefile([seg_path,'/y_',identifier,'.nii'], [seg_path,'/SPM12/']);
               movefile([seg_path,'/iy_',identifier,'.nii'], [seg_path,'/SPM12/']);
           end
        end
           
        disp(['THREAD ',num2str(t),') ',scan_number, '--> done (',num2str(s),'/',num2str(num_scans),')']);
    
    end
    
end