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
        % K-MEANS ALGORITHM
%         1) Set $i_c$(iteration count) to 1.
%         2) Choose a set of K means $m_1(1), m_2(1), \ldots m_K(1)$, 
%         3) For each vector $x_i$ compute $Dist(x_i, m_k(i_c))$ for each k=1, ..., K and assign $x_i$ to the cluster $C_j$ with the 
%            nearest mean.(Smallest Distance)
%         4) Increment $i_c$ by 1 and update the means to get a new set $m_1(i_c), m_2(i_c)$ $, \ldots, m_K(i_c)$
%         5) Repeat steps 3 and 4 until the clusters do not change; i.e., $C_k(i_c) = C_k(i_c + 1)$ for all k.

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
%% MEAN SQUARE MATRIX PLOTTING
%load([pwd filesep '/result/mse_matrix.mat']);
mse_values = zeros(1,number_of_k_values);
for pp = 1:size(raw_image_names,1)
    % Get the mean square error vector for one image, with different k
    % values
    mse_values(:) = mean_square_error_matrix(pp,:)';
    % Plot it for one image with different k values
    plot(k_values, mse_values);
    title(sprintf('For image %s:', raw_image_names(pp).name));
    xlabel('k Values');
    ylabel('Mean Square Error');
    % Format the output file name in order to save as a pdf file
    fig_path = [figs_path filesep raw_image_names(pp).name '.pdf'];
    % Save the figure as a pdf file
    saveas(gcf, fig_path, 'pdf') 
end
%% CODEBOOK PLOTTING
figure; hold on
% For different k's, I plotted the codebook of the colors which actually 
% corresponds the mean of the clusters, debugging purposes
for ii = 1:k
   col = (1/255).*means(ii,:);
   rectangle('Position', [ii, 0, 1, 1], 'FaceColor', col, 'EdgeColor', col);
end
axis off