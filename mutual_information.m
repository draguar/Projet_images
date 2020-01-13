function [error, resized_volume] = mutual_information(volume_ref, volume_shift)
    % Compute the error between volume_ref and volume_shift using mutual
    % information similarity.
    % Return volume_shift resized to match volume_ref dimensions.
    
   
    shape_ref = size(volume_ref);
    shape_shift = size(volume_shift);    
    
    resized_volume = zeros(shape_ref);
    resized_volume(1:shape_shift(1), 1:shape_shift(2),:) = volume_shift;
    
    hist_ref = histogram(volume_ref, 255);
    counts_ref = hist_ref.Values;
    hist_shift = histogram(resized_volume, 255);
    counts_shift = hist_shift.Values;
    conjoint_hist = histogram2(volume_ref, resized_volume, 255);
    conjoint_counts = conjoint_hist.Values;
      
    pipj = 1 + counts_ref' * counts_shift;
    log_val = log((1 + conjoint_counts) ./ pipj);
    error = - sum(sum(conjoint_counts.*log_val));