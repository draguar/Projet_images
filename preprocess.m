function processed_volume = preprocess(nifti_file)
    %preprocess the nifti file: apply an Otsu thresholding, then keep the
    %largest blob to create a mask on the original image. Each image of the
    %nifti volume will be applied its own mask.
    %The returned value is a 3D matrix, containing 15 grayscale images.
    %The input nifti_file is the filename for the nifti to preprocess.
    
    %load nifti file
    nii = load_nii(nifti_file);
    volume = nii.img;
    dims = size(volume);
    processed_volume = zeros(dims);
    for img_idx = 1:dims(3)
        %apply otsu thresholding
        otsu = imbinarize(volume(:,:,img_idx),multithresh(volume(:,:,img_idx)));  
        %find biggest blob
        mask = zeros(dims(1:2));
        best_blob_size = 0;
        %check each pixel
        for row = 1:dims(1)
            for col = 1:dims(2)
                if otsu(row, col)
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