close all
clc; clear all

%% SECTION 1
% preprocess volumes : remove noise around brain shape and normalize values
volume_ref = preprocess('FLAIR.nii',1);
volume_shift = preprocess('DIFFUSION.nii',2);
% Find mass center of brain shapes
centro_ref = compute_centroids(volume_ref);
centro_shift = compute_centroids(volume_shift);

[original_error, resized_volume] = compute_error(volume_ref, volume_shift);
figure('name','Original volumes');
plot_rgb(volume_ref, resized_volume, false);

% Basic translation: align centroids
translation = mean(centro_ref - centro_shift, 1);
translated_volume = imtranslate(volume_shift,translation,'FillValues',0);

[centroid_error, resized_translated_volume] = compute_error(volume_ref, translated_volume);
figure('name','Centroid-based translation');
plot_rgb(volume_ref, resized_translated_volume, false);

%% SECTION 2

% Range of explored transformations

t_min = -10;
t_max = 10;
t_step = 1;
r_min = -30; %degrees
r_max = 30;
r_step = 3;
%{
% Explore the transformations range around previous centroid-based first
% approximation. Keep the one yielding the lowest error.
[lowest_error, best_transform_volume, best_resized_volume, best_params] = find_best_transformation(volume_ref, translated_volume, t_min, t_max, t_step, r_min, r_max, r_step);
figure('name','Exploration-based best translation and rotation');
plot_rgb(volume_ref, best_resized_volume, false)
%}
%% SECTION 3

stretch_max = 1.5;
stretch_step = 0.05;

% Interface for entering points of interest
points_of_interest = GUI(volume_ref, resized_translated_volume);

% Fetch the entered points
ref_point = [];
shift_points = [];
for slice = 1:size(points_of_interest.vol1,1)
    ref_point = [ref_point;points_of_interest.vol1{slice}];
    shift_points = [shift_points;points_of_interest.vol2{slice}];
end
% Adapt coordinates to have origin on the bottom left
ref_point = [ref_point(:,1)-size(volume_ref,2)/2, size(volume_ref,1)/2-ref_point(:,2)];
shift_points = [shift_points(:,1)-size(resized_translated_volume,2)/2, size(resized_translated_volume,1)/2-shift_points(:,2)];

% Explore transformations range to find the lowest sum of points distances
[distance, pointset_params] = find_pointset_transformation(ref_point', shift_points', t_min, t_max, t_step, r_min, r_max, r_step, stretch_max, stretch_step);

% Apply transformations
rotated_pointset = imrotate(resized_translated_volume, pointset_params(3), 'crop');
translated_pointset = imtranslate(rotated_pointset,[pointset_params(1), pointset_params(2)],'FillValues',0);
stretched_pointset=imresize(translated_pointset, [pointset_params(5)*size(resized_translated_volume,1) pointset_params(4)*size(resized_translated_volume,2)]);
% recenter after stretching
transformed_poinset = imtranslate(stretched_pointset,[(1-pointset_params(4))*size(resized_translated_volume,2)/2,(1-pointset_params(5))*size(resized_translated_volume,1)/2],'FillValues',0);

[pointset_error, resized_pointset] = compute_error(volume_ref, transformed_poinset);
figure('name','Point-set-based best translation and rotation');
plot_rgb(volume_ref, resized_pointset, false)


%% Section 4
%{
optimizer = registration.optimizer.RegularStepGradientDescent;
metric = registration.metric.MattesMutualInformation;

non_rigid_volume = zeros(240,240,15);
% Apply non-rigid transformation to each slice
for i = 1:15
    non_rigid_volume(:,:,i) = imregister(volume_shift(:,:,i), volume_ref(:,:,i),'affine', optimizer,metric);
end
figure('name', 'Non-rigid transformation')
plot_rgb(volume_ref, non_rigid_volume, false)
[non_rigid_error, non_rigid_volume] = compute_error(volume_ref, non_rigid_volume);

%% Tests with squares
%{
A = 255-rgb2gray(imread('carre1.png'));
B = 255-rgb2gray(imread('carre2.png'));
figure('name', 'Test squares')
imshowpair(A, B);
%{
% test section 4
C = imregister(B, A, 'affine', optimizer, metric);
figure('name', 'Test non-rigid transformation')
imshowpair(A,C)
%}
% test section 3 

poi = GUI(A, B);
% Fetch the entered points
A_point = [poi.vol1{1}];
B_points = [poi.vol2{1}];
% Adapt coordinates to have origin on center
A_point = [A_point(:,1)-size(A,2)/2, size(A,1)/2-A_point(:,2)];
B_points= [B_points(:,1)-size(B,2)/2, size(B,1)/2-B_points(:,2)];
% Explore transformations range to find the lowest sum of points distances
[d, ps_params] = find_pointset_transformation(A_point', B_points', -30, 30, 1, -30, 30, 1, 2,0.1);
% Apply transformations
D = imrotate(B, ps_params(3), 'crop');
D = imtranslate(D,[ps_params(1), ps_params(2)],'FillValues',0);
D=imresize(D, [ps_params(5)*size(A,1) ps_params(4)*size(A,2)]);
D = imtranslate(D,[(1-ps_params(4))*size(A,2)/2,(1-ps_params(5))*size(A,1)/2],'FillValues',0);


[ps_error, D] = compute_error(A, D);
figure('name','Test point-setregistration');
imshowpair(A, D)
%}
%% Section 5
% Section 2 with mutual information similarity metrics

[mutual_error, mutual_transform_volume, mutual_resized_volume, mutual_params] = find_best_transformation(volume_ref, translated_volume, t_min, t_max, t_step, r_min, r_max, r_step, @mutual_information);
figure('name','Mutual information based best translation and rotation');
plot_rgb(volume_ref, mutual_resized_volume, false)

%%
%}
