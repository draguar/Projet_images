function plot_rgb(volume_r, volume_g, close_all)
    % Plot two volumes on a same image: in RGB, one will be used for R
    % values and the other one for G values.
    
    if nargin < 3
        close_all = true;
    end
    if close_all
        close all
    end
    
    nb_subplots = size(volume_r, 3);
    nb_by_axis = ceil(sqrt(nb_subplots));
    shape_r = size(volume_r);
    shape_g = size(volume_g);
    shape = max([shape_r; shape_g]);
    
    
    for img_idx = 1:nb_subplots
        subplot(nb_by_axis,nb_by_axis,img_idx)
        image_rgb = zeros([shape(1:2),3]);
        image_rgb(1:shape_r(1), 1:shape_r(2),1) = volume_r(:,:,img_idx);
        image_rgb(1:shape_g(1), 1:shape_g(2),2) = volume_g(:,:,img_idx);
        imshow(image_rgb);
    end