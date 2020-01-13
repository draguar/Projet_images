function [lowest_error, best_params] = find_pointset_transformation(ref_coords, shifted_coords, t_min, t_max, t_step, r_min, r_max, r_step)
    %this function finds the best transformation between 2 point
    %coordinates ensembles.
    %Translation and rotation transformations. Error is computed as
    %sum of squared eulerian distances between ensembles
    
    lowest_error = Inf;
    
    for  t_x = t_min:t_step:t_max
        for t_y = t_min:t_step:t_max
            
            translated_coords = shifted_coords + [t_x;t_y];
            
            for r = r_min:r_step:r_max
                theta = deg2rad(r);
                rotation = [cos(theta), -sin(theta); sin(theta), cos(theta)];
                transformed_coords = rotation* translated_coords;
                
                error = sum(sum((transformed_coords - ref_coords).^2));
                if error < lowest_error
                    lowest_error = error;
                    best_params = [t_x, t_y, r];
                end
            end
        end
    end