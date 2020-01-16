function [lowest_error, best_transform_volume, best_resized_volume, best_params] = find_best_transformation(ref, shifted_image, t_min, t_max, t_step, r_min, r_max, r_step, error_fun)
    % Find the best transformation between 2 volumes using the
    %translation and rotation transformations. Similarity is checked with
    %compute_error function. Returns t_x, t_y and r, parameters which give
    %the lowest error
    
    if nargin < 9 % in case we want another similarity metrix like mutualb information
        error_fun = @compute_error;
    end
    
    lowest_error = Inf; % Initialisation
    
    % Eplore transformations range
    for  t_x = t_min:t_step:t_max
        for t_y = t_min:t_step:t_max
            translated_volume = imtranslate(shifted_image,[t_x, t_y],'FillValues',0);
            for r = r_min:r_step:r_max
                transformed_volume = imrotate(translated_volume, r, 'crop');
                % Compute error
                [error, resized_volume] = error_fun(ref, transformed_volume);
                % Save parameters if it yields the lowest error
                if error < lowest_error
                    lowest_error = error;
                    best_transform_volume = transformed_volume;
                    best_resized_volume = resized_volume;
                    best_params = [t_x, t_y, r];
                end
            end
        end
    end