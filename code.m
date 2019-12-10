close all
volume_ref = preprocess('FLAIR.nii',1);
volume_shift = preprocess('DIFFUSION.nii',2);
figure(1)
plot_volume(volume_ref, false);
figure(2)
plot_volume(volume_shift, false);
