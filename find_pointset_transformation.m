function [lowest_error, best_params] = find_pointset_transformation(ref_coords, shifted_coords, t_min, t_max, t_step, r_min, r_max, r_step, stretch_max, stretch_step)
    %this function finds the best transformation between 2 point
    %coordinates ensembles.
    %Translation and rotation transformations are used. 
    %Error is computed as sum of squared eulerian distances between ensembles
    
    lowest_error = Inf; % Initialisation
    stretch_x = 0;
    stretch_y = 0;
    %Eplore transformations range
    

          

    for r = r_min:r_step:r_max
        % Rotation
        theta = deg2rad(r); % converts to radians
        rotation = [cos(theta), -sin(theta); sin(theta), cos(theta)]; %rotation matrix
        rotated_coord = rotation * shifted_coords; % compute coordinates after rotation
        % Translation
        for  t_x = t_min:t_step:t_max
            for t_y = t_min:t_step:t_max
                translated_coords = rotated_coord + [t_x;t_y];
                
                for stretch_x = 1:stretch_step:stretch_max
                stretching_x = [stretch_x,0;0,1];
                stretched_x = stretching_x * translated_coords;

                for stretch_y = 1:stretch_step:stretch_max
                    stretching_y = [1,0;0,stretch_y];
                    stretched_y = stretching_y * stretched_x;
                        % Compute error
                        error = sum(sum((stretched_y - ref_coords).^2));                    
                        % Save parameters if it yields the lowest error
                        if error < lowest_error
                            lowest_error = error;
                            best_params = [t_x,-t_y, r, stretch_x, stretch_y];
                        end
                    end
                end
                
            end
        end
                   
            end
