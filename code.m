close all
idx_coupe = 1;
volume_ref = load_nii('FLAIR.nii');
volume_shift = load_nii('DIFFUSION.nii');
coupe7_ref = volume_ref.img(:,:,idx_coupe);
coupe7_shift = volume_shift.img(:,:,idx_coupe);
imax_ref = volume_ref.hdr.dime.cal_max;
imax_shift = volume_shift.hdr.dime.cal_max;


COUNTS = 100;
figure(1)
subplot(2,1,1)
imshow(coupe7_ref, [0 imax_ref])
subplot(2,1,2)
imshow(coupe7_shift, [0 imax_shift])
figure(2)
subplot(2,1,1)
histogram(coupe7_ref,'NumBins', COUNTS)
subplot(2,1,2)
histogram(coupe7_shift,'NumBins', COUNTS)

%coupe7_ref = coupe7_ref.*single(coupe7_ref>500);
%coupe7_shift = coupe7_shift.*single(coupe7_shift>500);
thresh_ref = imbinarize(coupe7_ref,multithresh(coupe7_ref));
thresh_shift = imbinarize(coupe7_shift,multithresh(coupe7_shift));


figure(3)
subplot(2,1,1)
imshow(thresh_ref)

subplot(2,1,2)
imshow(thresh_shift)

%find biggest blob
best_contigue_ref = zeros(size(thresh_ref));
best_sum_ref = 0;
for row = 1:size(thresh_ref,1)
    for col = 1:size(thresh_ref,2)
        if thresh_ref(row, col)
            contigue_ref = grayconnected(int8(thresh_ref),row,col, 0);
            sum_ref = sum(sum(contigue_ref));
            thresh_ref = thresh_ref - contigue_ref;
            if sum_ref > best_sum_ref
                best_contigue_ref = contigue_ref;
                best_sum_ref = sum_ref;
            end
        end
    end
end

best_contigue_shift = zeros(size(thresh_shift));
best_sum_shift = 0;
for row = 1:size(thresh_shift,1)
    for col = 1:size(thresh_shift,2)
        if thresh_shift(row, col)
            contigue_shift = grayconnected(int8(thresh_shift),row,col, 0);
            sum_shift = sum(sum(contigue_shift));
            thresh_shift = thresh_shift - contigue_shift;
            if sum_shift > best_sum_shift
                best_contigue_shift = contigue_shift;
                best_sum_shift = sum_shift;
            end
        end
    end
end


figure(4)
subplot(2,1,1)
imshow(best_contigue_ref)

subplot(2,1,2)
imshow(best_contigue_shift)

