function [lowest_error, t_x, t_y, r] = find_best_transformation(ref, shifted_image, t_min, t_max, t_step, r_step)
    %this function finds the best transformation between 2 images using the
    %translation and rotation transformations. Similarity is checked with
    %compute_error function. Returns t_x, t_y and r, parameters which give
    %image with the lowest error
    
    errors_list = [];
    
    for  x = t_min:t_step:t_max
        for y = t_min:t_step:t_max
            
            translated_volume = imtranslate(shifted_image,[x, y],'FillValues',0);
            
            for r = 0:r_step:360
                
                transformed_volume = imrotate(translated_volume, r, 'crop');
                [error, resized_volume] = compute_error(ref, transformed_volume);
                errors_list = [errors_list; error, x, y, r];
                
            end
        end
    end
    
    [value, index] = min(errors_list(:,1));
    lowest_error = value;
    t_x = errors_list(index, 2);
    t_y = errors_list(index, 3);
    r = errors_list(index, 4);
    
end