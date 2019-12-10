close all
clc; clear all
volume_ref = preprocess('FLAIR.nii',1);
volume_shift = preprocess('DIFFUSION.nii',2);
% figure(1)
% plot_volume(volume_ref, false);
% figure(2)
% plot_volume(volume_shift, false);

masks_ref = volume_ref > 0;
masks_shift = volume_shift > 0;

centroids = zeros(15,2)
for i = 1:15
    [y, x] = ndgrid(1:size(masks_ref(:,:,i), 1), 1:size(masks_ref(:,:,i), 2));
    centro_x = mean([x(masks_ref(:,:,i))]);
    centro_y = mean([y(masks_ref(:,:,i))]);
    centroids(i,:) = [centro_x, centro_y];
end

figure(1)
plot_volume(masks_ref(:,:,12), false);
hold on;
plot(centroids(12,1), centroids(12,2), 'b*')
hold off;