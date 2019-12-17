function centroids = compute_centroids(volume)
    % Compute the centroid of a given volume
    % The return value is a n x 2 matrix, with a row for each slice in the
    % volume. Each row contains the centroid coordinates

    n_slices = size(volume, 3);
    shape = [size(volume, 1), size(volume, 2)];
    centroids = zeros(n_slices,2);
    binarized_volume = volume > 0;
    for i = 1:n_slices
        [y, x] = ndgrid(1:shape(1), 1:shape(2));
        centro_x = mean(x(binarized_volume(:,:,i)));
        centro_y = mean(y(binarized_volume(:,:,i)));
        centroids(i,:) = [centro_x, centro_y];
    end