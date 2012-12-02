function mse = mean_square_error(im1, im2)
% Takes im1 and im2 and computes the mean square error
diff = im1 - im2;
mse = sum(sum(diff.^2));
