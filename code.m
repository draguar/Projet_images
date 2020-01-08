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
%type in points from images and get coordinates
[x_ref, y_ref, x_newvol, y_newvol] = get_points_of_interest(volume_ref, resized_volume);


% align these points
ref_ = zeros(size(x_ref, 1), 2);
for i = 1:size(x_ref)
    ref_(i,1) = x_ref(i);
    ref_(i,2) = y_ref(i);
end

newvol_ = zeros(size(x_newvol, 1), 2)
for i = 1:size(x_newvol);
    newvol_(i,1) = x_newvol(i);
    newvol_(i,2) = y_newvol(i);
end

tform = fitgeotrans(newvol_, ref_, 'NonreflectiveSimilarity')
for i = 1:15
    newvol_transformed(:,:,i) = imwarp(best_resized_volume(:,:,i), tform, 'OutputView', imref2d(size(volume_ref(:,:,i))));
end
    
plot_rgb(volume_ref, newvol_transformed, false)

%% Section 4

% Read two images
optimizer = registration.optimizer.RegularStepGradientDescent;
metric = registration.metric.MattesMutualInformation;

non_rigid_volume = zeros(240,240,15);

for i = 1:15
    non_rigid_volume(:,:,i) = imregister(volume_shift(:,:,i), volume_ref(:,:,i),'affine', optimizer,metric);
end

plot_rgb(volume_ref, non_rigid_volume)
[error, osef] = compute_error(volume_ref, non_rigid_volume);
error
% reduction de l'erreur importante

%% test avec des carrés

A = 255-rgb2gray(imread('carre1.png'));
B = 255-rgb2gray(imread('carre2.png'));
imshowpair(A, B);

%%
%test section 4
C = imregister(B, A, 'affine', optimizer, metric);
imshowpair(A,C) % validé

%% test section 3 

%type in points from images and get coordinates
[x_ref, y_ref, x_newvol, y_newvol] = get_points_of_interest_test_carre(A, B);


% align these points
ref_ = zeros(size(x_ref, 1), 2);
for i = 1:size(x_ref)
    ref_(i,1) = x_ref(i);
    ref_(i,2) = y_ref(i);
end

newvol_ = zeros(size(x_newvol, 1), 2)
for i = 1:size(x_newvol);
    newvol_(i,1) = x_newvol(i);
    newvol_(i,2) = y_newvol(i);
end
%%
tform = fitgeotrans(newvol_, ref_, 'NonreflectiveSimilarity')
D = imwarp(B, tform, 'OutputView', imref2d(size(A)));
%%
imshowpair(A, D) %% --> validé
%% Section 5
image1 = round(255*mat2gray(volume_ref(:,:,6)));
image2 = round(255*mat2gray(resized_volume(:,:,6)));

sum_ = 0;

for i = 1:255
    for j = 1:255
        p_ij = 0;
        p_i = 0;
        p_j = 0;
        for a = 1:size(image1, 1)
            for b = 1:size(image1, 2)
                if image1(a, b) == i
                    p_i = p_i +1;
                end
                if image2(a, b) == j
                    p_j = p_j +1;
                end
                if image1(a, b) == i && image2(a,b) == j
                    p_ij = p_ij + 1;
                end
            end
        end
    sum_ = sum_ + (p_ij * log(p_ij / (p_i * p_j)));
    end
    disp (i)
end

%%
imshowpair(image1, image2)