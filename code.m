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

nslices = size(volume_ref, 3);
best_shifted_images = zeros(size(volume_ref));

%figure(5)
new_values_list = [];
best_images = zeros(240,240,nslices);

for i = 1:nslices
    ref = volume_ref(:,:,i);
    shifted_image = resized_translated_volume(:,:,i);
    
    %calculating best translation, generating corresponding image,and
    %keeping all the results in a list
    [lowest_error, t_x, t_y, r] = find_best_transformation(ref, shifted_image, t_min, t_max, t_step, r_min, r_max, r_step);
    best_shifted_image = imrotate(imtranslate(shifted_image,[t_x, t_y],'FillValues',0), r, 'crop');
    new_values_list = [new_values_list; lowest_error, t_x, t_y, r];
    best_images(:,:,i) = best_shifted_image;
    %these list can be used to compare results with image before
    %transformation
    
    %subplot(3,5,i);
    %je vous laisse faire le plot flemme
    %plot ref and best_shifted_image using rgb technique
end

%%
plot_rgb(volume_ref, best_images, true)

new_values_list

%alors niveau erreur ça a l'air pas mal mais visuellement je trouve ça un
%peu claqué au sol ca matche vitef


%% SECTION 3

% Pour faire le trucs des points faut que je regarde dans mon projet de
% traitement d'images de l'an dernier on a fait exactement ça
