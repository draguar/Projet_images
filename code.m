close all
clc; clear all

%% SECTION 1
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

%% SECTION 2

%on pourra discuter des bonnes valeurs pour tous ces paramètres

%defining values
t_min = -10;
t_max = 10;
t_step = 1;
r_min = -30;
r_max = 30;
r_step = 3;

%calculating best translation, generating corresponding image,and
%keeping all the results in a list
[lowest_error, best_transform_volume, best_resized_volume, best_params] = find_best_transformation(volume_ref, translated_volume, t_min, t_max, t_step, r_min, r_max, r_step);
lowest_error
figure(5)
plot_rgb(volume_ref, best_resized_volume, false)
%% SECTION 3

% Pour faire le trucs des points faut que je regarde dans mon projet de
% traitement d'images de l'an dernier on a fait exactement ça
