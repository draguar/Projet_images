function processed_volume = preprocess(nifti_file, n_classes)
    %preprocess the nifti file: apply an Otsu thresholding, then keep the
    %largest blob to create a mask on the original image. Each image of the
    %nifti volume will be applied its own mask.
    %The returned value is a 3D matrix, containing 15 grayscale images.
    %The input nifti_file is the filename for the nifti to preprocess.
    % n_classes allow to chose the number of thresholds (2 thresholds allow
    % the removal of dark areas as well as of very bright ones)
    
    %load nifti file
    nii = load_nii(nifti_file);
    volume = nii.img;
    %normalise values
    volume = volume / nii.hdr.dime.cal_max;
    dims = size(volume);
    processed_volume = zeros(dims);
    
    
    for img_idx = 1:dims(3)
        %apply otsu thresholding       
        auto_thresholds = multithresh(volume(:,:,img_idx),n_classes);
        % Augment the second threshold to be less stringent on what is "too
        % bright.
        if n_classes > 1
            auto_thresholds(2) = auto_thresholds(2) * 1.3;
        end
        otsu = imquantize(volume(:,:,img_idx), auto_thresholds);          
        %find biggest blob
        mask = zeros(dims(1:2));
        best_blob_size = 0;
        %check each pixel
        for row = 1:dims(1)
            for col = 1:dims(2)
                if otsu(row, col) == 2
                    %The pixel is part of a blob
                    blob = grayconnected(int8(otsu),row,col,0);
                    blob_size = sum(sum(blob));
                    if blob_size > best_blob_size
                        %Save the blob if it is the best one found so far
                        mask = blob;
                        best_blob_size = blob_size;
                    end
                    %Remove the blob to avoid checking it again later
                    otsu = otsu - blob;
                end
            end
        end
        %Apply the mask
        processed_volume(:,:,img_idx) = volume(:,:,img_idx).*mask;
    end