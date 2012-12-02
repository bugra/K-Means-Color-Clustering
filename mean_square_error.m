function mse = mean_square_error(im1, im2)
% Takes im1 and im2 and computes the mean square error
diff = im1 - im2;
mse = 0;
for ii = 1:size(diff,1)
    for jj = 1:size(diff,2)
        mse = mse + diff(ii,jj)^2;
    end
end
