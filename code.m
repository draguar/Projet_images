close all
volume_ref = preprocess('FLAIR.nii');
volume_shift = preprocess('DIFFUSION.nii');
figure(1)
plot_volume(volume_ref, false);
figure(2)
plot_volume(volume_shift, false);
