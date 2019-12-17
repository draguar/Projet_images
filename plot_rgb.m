function plot_rgb(volume_r, volume_g, close_all)
    % Plot two volumes on a same image: in RGB, one will be used for R
    % values and the other one for G values.
    % The volume must have the same dimensions.
    
    if nargin < 3
        close_all = true;
    end
    if close_all
        close all
    end
    
    nb_subplots = size(volume_r, 3);
    nb_by_axis = ceil(sqrt(nb_subplots));   
    volume_rgb = zeros([size(volume_r),3]);
    volume_rgb(:,:,:,1) = volume_r;
    volume_rgb(:,:,:,2) = volume_g;
    
    
    for img_idx = 1:nb_subplots
        subplot(nb_by_axis,nb_by_axis,img_idx)
        image_rgb = volume_rgb(:,:,img_idx,:);
        imshow(reshape(image_rgb, [size(volume_r,1), size(volume_r,2), 3]));
    end