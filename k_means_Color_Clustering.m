clear all; close all; clc;
image_data_path = '/home/bugra/Dropbox/PolyClasses/Fall2012/CS6643-ComputerVision/Projects/Project_2/data';
addpath(image_data_path);
raw_image_names = dir(fullfile(image_data_path, '/*.raw'));



% for ii = 1:size(raw_image_names,1)
%     if strcmpi(raw_image_names(ii).name, 'rock-stream.raw')
%         raw_image_size = [333 250];
%     elseif stcmpi(raw_image_names(ii).name, 'tiger1.raw')
%         raw_image_size = [461 990];
%     end

raw_image_name = [image_data_path filesep raw_image_names(1).name];
raw_image_size = [333 250];
r = raw_image_size(1); c = raw_image_size(2);
A = read_color_raw(raw_image_name, raw_image_size);

 
k = 10; % number of colors to represent



% Initialization suggested in the assignment
means = zeros(k, 3);
for jj = 1:k
    means(jj,:) = (256 / floor(k+1)) * jj;
end

% array that will store the nearest neighbor for every
% pixel in the image
nearest_mean = zeros(r,c);

% Run k-means
max_iterations = 100;
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
            red = A(i,j,1); 
            green = A(i,j,2); 
            blue = A(i,j,3);
            
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
disp(sprintf('It takes %d iteration to converge when K is %d', itr, k));

means = round(means);

color_segmented_image = A;

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
imshow(uint8(round(color_segmented_image))); hold off

% Save image
imwrite(uint8(round(color_segmented_image)), 'rock_stream.jpg');

mse = mean_square_error(A, color_segmented_image);
str = sprintf('Mean square error is: %d when K is: .', mse, k);
disp(str);

figure; hold on
for ii = 1:k
   col = (1/255).*means(ii,:);
   rectangle('Position', [ii, 0, 1, 1], 'FaceColor', col, 'EdgeColor', col);
end
axis off