clear all; close all; clc;
% Raw Image Data Path
image_data_path = [pwd filesep 'data'];
addpath(image_data_path);
% Raw Image Names
raw_image_names = dir(fullfile(image_data_path, '/*.raw'));
% Iteration Number which K-means will be running to converge
max_iterations = 200;
% Output txt file to write the mean square error and iteration number
% for debugging purposes
output_txt_str = 'output.txt';
% Resulting images will be stored in this directory
result_path = [pwd filesep 'result'];
% Figures of the Mean Square Error versus the number of K will be stored
% in this directory
figs_path = [pwd filesep 'figs'];
dash_str = sprintf('-------------------------------------- \n');
% K values range, asked in the assignment
k_values = 2:10;
number_of_k_values = length(k_values);
% Mean Square Error Matrix for each raw image with respect to K values.
mean_square_error_matrix = zeros(size(raw_image_names,1), number_of_k_values);
mean_square_error_str = 'mse_matrix.mat';

for nn = 1:size(raw_image_names,1)
    % For timing
    tic;
    % Initialization of the raw image sizes as raw image does not provide
    % this information, we need to have the image size of the image in 
    % order to read the image into double 3-Dimensional array.
    % It only compares the names of the images, assuming all of the 
    % different images have different names
    if strcmpi(raw_image_names(nn).name, 'rock-stream.raw')
        raw_image_size = [333 250];
    elseif strcmpi(raw_image_names(nn).name, 'tiger1.raw')
        raw_image_size = [461 690];
    end
    
    raw_image_name = [image_data_path filesep raw_image_names(nn).name];
    r = raw_image_size(1); c = raw_image_size(2);
    % Turning the raw image into 3-Dimensional Array
    % More information can be found in the read_color_raw function
    color_image = read_color_raw(raw_image_name, raw_image_size);
    
    % Image Name is written on output.txt
    image_str = sprintf('For image %s:\n', raw_image_names(nn).name);
    fileID = fopen(output_txt_str,'a');
    fprintf(fileID,'%s %s',image_str);
    fclose(fileID);
    
    for k = k_values
        
        % Initialization suggested in the assignment
        means = zeros(k, 3);
        for jj = 1:k
            means(jj,:) = (256 / floor(k+1)) * jj;
        end
        
        % Nearest neighbor mean of each individual pixel
        nearest_mean = zeros(r,c);
        
        % For constant k value,
        % K-Means Clustering Algorithm
        for itr = 1:max_iterations
            
            % Stores the means to be calculated in this iteration
            new_means = zeros(size(means));
            
            % number of pixels clustered in the nth mean
            num_assigned = zeros(k, 1);
            
            % For every individual pixel in the image:
            % Compute the nearest mean and update the means.
            for i = 1:r
                for j = 1:c
                    % Compute the nearest mean
                    red = color_image(i,j,1);
                    green = color_image(i,j,2);
                    blue = color_image(i,j,3);
                    
                    diff = ones(k,1)*[red, green, blue] - means;
                    distance = sum(diff.^2, 2);
                    [val ind] = min(distance);
                    nearest_mean(i,j) = ind;
                    
                    % Add this pixel into the nearest mean value.
                    new_means(ind, 1) = new_means(ind, 1) + red;
                    new_means(ind, 2) = new_means(ind, 2) + green;
                    new_means(ind, 3) = new_means(ind, 3) + blue;
                    num_assigned(ind) = num_assigned(ind) + 1;
                end
            end
            
            % Update the means
            for i = 1:k
                % Update the means if there are pixel values in the 
                % neighborhood of that mean
                if (num_assigned(i) > 0)
                    new_means(i,:) = new_means(i,:) ./ num_assigned(i);
                end
            end
            
            % Check whether the new means are actually different than the
            % old means, if not, the algorithm converges.
            d = sum(sqrt(sum((new_means - means).^2, 2)));
            if d == 0
                disp(itr)
                break
            end
            % Update means with new_means
            means = new_means;
        end
        % Display the convergence number
        converge_str = sprintf('\t For K = %d:\n \t\t Iteration number for converge: %d \n', k, itr);
        display(converge_str);
        % As mean values cannot put as fractal numbers in the image we
        % need to turn into integer values
        means = round(means);
        
        % Initialize the color segmented image as in the original image
        color_segmented_image = color_image;
        
        % Replace the invidividual pixel values with the K-means 
        % clustering mean values in order to get color segmented image
        for ii = 1:r
            for jj = 1:c
                % Get the original values of Red, Green and Blue values
                % of the image
                red = color_segmented_image(ii,jj,1);
                green = color_segmented_image(ii,jj,2);
                blue = color_segmented_image(ii,jj,3);
                
                % Compute the nearest mean of the individual pixel and 
                % replace the individual pixel value with the mean of 
                % that cluster
                diff = ones(k,1)*[red, green, blue] - means;
                distance = sum(diff.^2, 2);
                [val ind] = min(distance);
                color_segmented_image(ii,jj,:) = means(ind,:);
            end
        end
        % Show the color segmented image
        imshow(uint8(round(color_segmented_image)));
        
        % Save the color segmented image image
        result_im_str = strcat(raw_image_names(nn).name, num2str(k));
        result_png_str = strcat(result_im_str, '.png');
        output_path =[result_path filesep result_png_str];
        imwrite(uint8(round(color_segmented_image)), output_path);
        
        % Compute the mean square error
        mse = mean_square_error(color_image, color_segmented_image);
        mse_str = sprintf('\t\t Mean Square Error: %d\n ', mse);
        % Show the mean square error
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
    % Timing Ends
    toc;
end
% Save the mean square error
mean_square_error_path = [result_path filesep mean_square_error_str];
save(mean_square_error_path, 'mean_square_error_matrix');
%%
%load([pwd filesep '/result/mse_matrix.mat']);
mse_values = zeros(1,number_of_k_values);
for pp = 1:size(raw_image_names,1)
    mse_values(:) = mean_square_error_matrix(pp,:)';
    plot(k_values, mse_values);
    title(sprintf('For image %s:', raw_image_names(pp).name));
    xlabel('k Values');
    ylabel('Mean Square Error');
    fig_path = [figs_path filesep raw_image_names(pp).name '.pdf'];
    saveas(gcf, fig_path, 'pdf') %Save figure
end
%%
figure; hold on
for ii = 1:k
   col = (1/255).*means(ii,:);
   rectangle('Position', [ii, 0, 1, 1], 'FaceColor', col, 'EdgeColor', col);
end
axis off