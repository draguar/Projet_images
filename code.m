close all
clc; clear all
volume_ref = preprocess('FLAIR.nii',1);
volume_shift = preprocess('DIFFUSION.nii',2);
centro_ref = compute_centroids(volume_ref);
centro_shift = compute_centroids(volume_shift);


translation = mean(centro_ref - centro_shift, 1);
translated_volume = imtranslate(volume_shift,translation,'FillValues',0);

% A GARDER POUR LE RAPPORT
[error, resized_volume] = compute_error(volume_ref, volume_shift);
error
figure(3)
plot_rgb(volume_ref, resized_volume, false);

[error, resized_translated_volume] = compute_error(volume_ref, translated_volume);
error
figure(4)
plot_rgb(volume_ref, resized_translated_volume, false);

%% Question 2.3

%defining values
t_min = -5;
t_max = 5;
t_step = 1;
r_step = 50;
nslices = size(volume_ref, 3);
best_shifted_images = zeros(size(volume_ref));

%figure(5)

for i = 1:nslices
    ref = volume_ref(:,:,i);
    shifted_image = resized_translated_volume(:,:,i);
    [lowest_error, t_x, t_y, r] = find_best_transformation(ref, shifted_image, t_min, t_max, t_step, r_step);
    best_shifted_image = imrotate(imtranslate(shifted_image,[t_x, t_y],'FillValues',0), r, 'crop')
    subplot(3,5,i)
    %plot ref and best_shifted_image using rgb technique
end

