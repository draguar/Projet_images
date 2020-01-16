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
figure('name','Original volumes');
plot_rgb(volume_ref, resized_volume, false);

[error, resized_translated_volume] = compute_error(volume_ref, translated_volume);
figure('name','Centroid-based translation');
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
%{
%calculating best translation, generating corresponding image,and
%keeping all the results in a list
[lowest_error, best_transform_volume, best_resized_volume, best_params] = find_best_transformation(volume_ref, translated_volume, t_min, t_max, t_step, r_min, r_max, r_step);
figure('name','Exploration-based best translation and rotation');
plot_rgb(volume_ref, best_resized_volume, false)
%}
%% SECTION 3

stretch_max = 1.5;
stretch_step = 0.05;
%type in points from images and get coordinates
points_of_interest = GUI(volume_ref, translated_volume);
ref_point = [];
shift_points = [];
for slice = 1:size(points_of_interest.vol1,1)
    ref_point = [ref_point;points_of_interest.vol1{slice}];
    shift_points = [shift_points;points_of_interest.vol2{slice}];
end
ref_point(:,2) = size(volume_ref,2)-ref_point(:,2);
shift_points(:,2)= size(volume_ref,2)-shift_points(:,2);
ref_point'
shift_points'

[distance, pointset_params] = find_pointset_transformation(ref_point', shift_points', t_min, t_max, t_step, r_min, r_max, r_step, stretch_max, stretch_step);

% Apply transformation

%stretched_volume = imresize(translated_volume, [pointset_params(4)*size(translated_volume,1),pointset_params(5)*size(translated_volume,2) ]);
rotated_pointset = imrotate(translated_volume, pointset_params(3), 'crop');
translated_pointset = imtranslate(rotated_pointset,[pointset_params(1), -pointset_params(2)],'FillValues',0);

% Resize image
[pointset_error, resized_pointset] = compute_error(volume_ref, translated_pointset);
pointset_error
pointset_params

figure('name','Point-set-based best translation and rotation');
plot_rgb(volume_ref, resized_pointset, false)


%% Section 4
%{

% Read two images
optimizer = registration.optimizer.RegularStepGradientDescent;
metric = registration.metric.MattesMutualInformation;

non_rigid_volume = zeros(240,240,15);

for i = 1:15
    non_rigid_volume(:,:,i) = imregister(volume_shift(:,:,i), volume_ref(:,:,i),'affine', optimizer,metric);
end
figure('name', 'sect4')
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
%}

%% Section 5
%calculating best translation, generating corresponding image,and
%keeping all the results in a list
%{
[mutual_error, mutual_transform_volume, mutual_resized_volume, mutual_params] = find_best_transformation(volume_ref, translated_volume, t_min, t_max, t_step, r_min, r_max, r_step, @mutual_information);
figure('name','Mutual information based best translation and rotation');
plot_rgb(volume_ref, mutual_resized_volume, false)
%}

%%

