close all
clc; clear all

%% SECTION 1

%read images
%volume_ref will stay constant, we will try to improve volume_shift so that
%it fits volume_ref as well as possible.
volume_ref = preprocess('FLAIR.nii',1);
volume_shift = preprocess('DIFFUSION.nii',2);

%compute centroids
centro_ref = compute_centroids(volume_ref);
centro_shift = compute_centroids(volume_shift);

%calculate the average best translation
translation = mean(centro_ref - centro_shift, 1);
translated_volume = imtranslate(volume_shift,translation,'FillValues',0);

% A GARDER POUR LE RAPPORT
[error, resized_volume] = compute_error(volume_ref, volume_shift);
error
figure(3)
plot_rgb(volume_ref, resized_volume, false);
% The initial error between the 2 techniques is 21415.


[error, resized_translated_volume] = compute_error(volume_ref, translated_volume);
error
figure(4)
plot_rgb(volume_ref, resized_translated_volume, false);
%once we translate the second set of images to have it match the main one, the
%error decreases significantly and reaches 11750

%We also resized the translated volume to have it match the size of the
%reference one.


%% SECTION 2

%The objective here is to find the best translation and rotation

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

%After translation and rotation (-2 mixels on x axis, +3 pixels on y axis
%and -6 degrees of rotation), the error drops to 11261

%% SECTION 3

%The objective of this section is to use point set registration

%type in points from images and get coordinates
[x_ref, y_ref, x_newvol, y_newvol] = get_points_of_interest(volume_ref, resized_translated_volume);


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

[error, resized_translated_volume] = compute_error(volume_ref, newvol_transformed);
error

%When we use point set registration, we have errors ranging from 11000 to
%15000. This is not as good as the automated translation and rotation from
%section 2. This can be explained by many reasons; first, the matching of 2
%images is made on a single slice, and then reported to the rest of the
%volume. Human error can impact the results as well.

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

%This gives very good and closely matching results, with an error of 8279.

%% test avec des carrés

%reading squares with translation

A = 255-rgb2gray(imread('carre1.png'));
B = 255-rgb2gray(imread('carre2.png'));
imshowpair(A, B);

%% test section 4
C = imregister(B, A, 'affine', optimizer, metric);
imshowpair(A,C)
%the automated translation and rotation work fine

%% test section 4 

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