close all
clc; clear all
volume_ref = preprocess('FLAIR.nii',1);
volume_shift = preprocess('DIFFUSION.nii',2);
centro_ref = compute_centroids(volume_ref);
centro_shift = compute_centroids(volume_shift);

figure(1)
plot_volume(volume_ref, false, centro_ref);

figure(2)
plot_volume(volume_shift, false, centro_shift);

translation = mean(centro_ref - centro_shift, 1);
translated_volume = imtranslate(volume_shift,translation,'FillValues',0);

% A GARDER POUR LE RAPPORT
figure(3)
plot_rgb(volume_ref, volume_shift, false);
figure(4)
plot_rgb(volume_ref, translated_volume, false);