function [error, resized_volume] = mutual_information(volume_ref, volume_shift)
    % Compute the error between volume_ref and volume_shift using mutual
    % information similarity.
    % Return volume_shift resized to match volume_ref dimensions.
    
   
    shape_ref = size(volume_ref);
    shape_shift = size(volume_shift);    
    % Resize volume
    resized_volume = zeros(shape_ref);
    resized_volume(1:shape_shift(1), 1:shape_shift(2),:) = volume_shift;
    
    % Bins for histograms
    edges = (0:255)/255;
    % Compute marginal and joint distributions
    hist_ref = histcounts(volume_ref, edges);
    hist_shift = histcounts(resized_volume, edges);
    conjoint_hist = histcounts2(volume_ref, resized_volume, edges, edges);
    % Compute similarity metrics
    pipj = 1 + hist_ref' * hist_shift; % 1 added to avoid division by 0
    log_val = log((1 + conjoint_hist) ./ pipj); % 1 added to avoid log(0)
    error = - sum(sum(conjoint_hist.*log_val));