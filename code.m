close all
volume_ref = preprocess('FLAIR.nii');
volume_shift = preprocess('DIFFUSION.nii');
% figure(1)
% plot_volume(volume_ref, false);
% figure(2)
% plot_volume(volume_shift, false);

masks_ref = volume_ref > 0;
masks_shift = volume_shift > 0;

figure(1)
plot_volume(masks_ref, true);
figure(2);
plot_volume(masks_ref, false);

for i = 
s = regionprops(best_contigue_ref,'centroid');
centroids = cat(1,s.Centroid);
