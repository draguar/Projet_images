function [error, resized_volume] = compute_error(volume_ref, volume_shift)
    % Compute the error between volumme_ref and volume_shift. 
    % Return volume_shift resized to match volume_ref dimensions.
    
    
    shape_ref = size(volume_ref);
    shape_shift = size(volume_shift);    
    
    resized_volume = zeros(shape_ref);
    resized_volume(1:shape_shift(1), 1:shape_shift(2),:) = volume_shift;
    error = sum(sum(sum((volume_ref-resized_volume).^2)));