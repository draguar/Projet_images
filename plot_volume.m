function plot_volume(volume, close_all)
    %Plot a volume: a subplot by image in the volume
    
    if nargin < 2
        close_all = true;
    end
    if close_all
        close all
    end
    nb_subplots = size(volume, 3);
    nb_by_axis = ceil(sqrt(nb_subplots));
    for img_idx = 1:nb_subplots
        subplot(nb_by_axis,nb_by_axis,img_idx)
        imshow(volume(:,:,img_idx), []);
    end