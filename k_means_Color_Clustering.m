% Exercise 9
% K-means

% Note: this script will probably take 5-10 min in Octave, with nothing
% printing to the screen and no figures appearing until the entire script 
% is done.

clear all; close all; clc;


% Load small image
A = double(imread('red_sunset_beach.jpg'));

dim = size(A,1); % number of pixels in picture's length/width
k = 16; % number of colors to represent

% Initialize means to randomly-selected colors in the original photo.
means = zeros(k, 3);
rand_x = ceil(dim*rand(k, 1));
rand_y = ceil(dim*rand(k, 1));
for i = 1:k
    means(i,:) = A(rand_x(i), rand_y(i), :);
end


% array that will store the nearest neighbor for every
% pixel in the image
nearest_mean = zeros(dim);

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
    for i = 1:dim
        for j = 1:dim
            % Calculate the nearest mean for the pixels in the image
            r = A(i,j,1); g = A(i,j,2); b = A(i,j,3);
            diff = ones(k,1)*[r, g, b] - means;
            distance = sum(diff.^2, 2);
            [val ind] = min(distance);
            nearest_mean(i,j) = ind;
            
            % Add this pixel to the rgb values of its nearest mean
            new_means(ind, 1) = new_means(ind, 1) + r;
            new_means(ind, 2) = new_means(ind, 2) + g;
            new_means(ind, 3) = new_means(ind, 3) + b;
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
    d = sum(sqrt(sum((new_means - means).^2, 2)))
    if d < 1e-5
        break
    end
    
    means = new_means;
end
disp(itr)

means = round(means);

% Recalculate the big image and display
large_image = double(imread('bird_large.tiff'));
large_dim = size(large_image, 1);

for i = 1:large_dim
    for j = 1:large_dim
        r = large_image(i,j,1); g = large_image(i,j,2); b = large_image(i,j,3);
        diff = ones(k,1)*[r, g, b] - means;
        distance = sum(diff.^2, 2);
        [val ind] = min(distance);
        large_image(i,j,:) = means(ind,:);
    end 
end
imshow(uint8(round(large_image))); hold off

% Save image
imwrite(uint8(round(large_image)), 'bird_kmeans.jpg');



% Uncomment to display the mean colors (Matlab Only)
% Unfortunately, the rectangle function does not work in Octave
% figure; hold on
% for i=1:k
%    col = (1/255).*means(i,:);
%    rectangle('Position', [i, 0, 1, 1], 'FaceColor', col, 'EdgeColor', col);
% end
% axis off