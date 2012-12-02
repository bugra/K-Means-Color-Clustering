clear all; close all; clc;
image_data_path = [pwd filesep 'data'];
addpath(image_data_path);
raw_image_names = dir(fullfile(image_data_path, '/*.raw'));
max_iterations = 200;
output_txt_str = 'output.txt';
result_path = [pwd filesep 'result'];
dash_str = '--------------------------------------\n';
number_of_k_values = 9;
mean_square_error_matrix = zeros(size(raw_image_names,1), number_of_k_values);
mean_square_error_str = 'mse_matrix.mat';
for nn = 1:size(raw_image_names,1)
    tic;
    if strcmpi(raw_image_names(nn).name, 'rock-stream.raw')
        raw_image_size = [333 250];
    elseif strcmpi(raw_image_names(nn).name, 'tiger1.raw')
        raw_image_size = [461 690];
    end
    
    raw_image_name = [image_data_path filesep raw_image_names(nn).name];
    r = raw_image_size(1); c = raw_image_size(2);
    color_image = read_color_raw(raw_image_name, raw_image_size);
    
    % Image Name is written on output.txt
    image_str = sprintf('For image %s:\n', raw_image_names(nn).name);
    fileID = fopen(output_txt_str,'a');
    fprintf(fileID,'%s %s',image_str);
    fclose(fileID);
    
    for k = 2:10
        
        % Initialization suggested in the assignment
        means = zeros(k, 3);
        for jj = 1:k
            means(jj,:) = (256 / floor(k+1)) * jj;
        end
        
        % array that will store the nearest neighbor for every
        % pixel in the image
        nearest_mean = zeros(r,c);
        
        % Run k-means
        for itr = 1:max_iterations
            
            % Stores the means to be calculated in this iteration
            new_means = zeros(size(means));
            
            % num_assigned(n) stores the number of pixels clustered
            % around the nth mean
            num_assigned = zeros(k, 1);
            
            % For every pixel in the image, calculate the nearest mean. Then
            % Update the means.
            for i = 1:r
                for j = 1:c
                    % Calculate the nearest mean for the pixels in the image
                    red = color_image(i,j,1);
                    green = color_image(i,j,2);
                    blue = color_image(i,j,3);
                    
                    diff = ones(k,1)*[red, green, blue] - means;
                    distance = sum(diff.^2, 2);
                    [val ind] = min(distance);
                    nearest_mean(i,j) = ind;
                    
                    % Add this pixel to the rgb values of its nearest mean
                    new_means(ind, 1) = new_means(ind, 1) + red;
                    new_means(ind, 2) = new_means(ind, 2) + green;
                    new_means(ind, 3) = new_means(ind, 3) + blue;
                    num_assigned(ind) = num_assigned(ind) + 1;
                end
            end
            
            % Calculate new means
            for i = 1:k
                % Only update the mean if there are pixels assigned to it
                if (num_assigned(i) > 0)
                    new_means(i,:) = new_means(i,:) ./ num_assigned(i);
                end
            end
            
            % Convergence test. Display by how much the means values are changing
            d = sum(sqrt(sum((new_means - means).^2, 2)));
            if d == 0
                disp(itr)
                break
            end
            
            means = new_means;
        end
        converge_str = sprintf('\t For K = %d:\n \t\t Iteration number for converge: %d \n', k, itr);
        display(converge_str);
        
        means = round(means);
        
        color_segmented_image = color_image;
        
        for ii = 1:r
            for jj = 1:c
                red = color_segmented_image(ii,jj,1);
                green = color_segmented_image(ii,jj,2);
                blue = color_segmented_image(ii,jj,3);
                
                diff = ones(k,1)*[red, green, blue] - means;
                distance = sum(diff.^2, 2);
                [val ind] = min(distance);
                color_segmented_image(ii,jj,:) = means(ind,:);
            end
        end
        imshow(uint8(round(color_segmented_image)));
        
        % Save image
        result_im_str = strcat(raw_image_names(nn).name, num2str(k));
        result_png_str = strcat(result_im_str, '.png');
        output_path =[result_path filesep result_png_str];
        imwrite(uint8(round(color_segmented_image)), output_path);
        
        mse = mean_square_error(color_image, color_segmented_image);
        mse_str = sprintf('\t\t Mean Square Error: %d\n ', mse);
        
        disp(mse_str);
        fileID = fopen(output_txt_str,'a');
        fprintf(fileID,'%s %s',converge_str,mse_str);
        fclose(fileID);
        mean_square_error_matrix(nn,k) = mse;
    end
    
    % Dash string for separating different images
    fileID = fopen(output_txt_str,'a');
    fprintf(fileID,'%s',dash_str);
    fclose(fileID);
    fprintf('For image: %s', raw_image_names(nn).name);
    toc;
end
mean_square_error_path = [result_path filesep mean_square_error_str];
save(mean_square_error_matrix, mean_square_error_path);

figure; hold on
for ii = 1:k
   col = (1/255).*means(ii,:);
   rectangle('Position', [ii, 0, 1, 1], 'FaceColor', col, 'EdgeColor', col);
end
axis off