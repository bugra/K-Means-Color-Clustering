function [img] = read_color_raw(raw_image_name, raw_image_size)
fid=fopen(raw_image_name,'rb');
im=fread(fid,inf,'uchar');
fclose(fid);

r = raw_image_size(1); c = raw_image_size(2);

% Initialization of color images for Red, Green and Blue
Red = zeros(r,c);
Green = zeros(r,c);
Blue = zeros(r,c);

% Initialization of the RGB image, which will be returned by this
% function
img = zeros(r,c,3);

% RGB values are read in the same order they are provided 
for ii = 1:r
    for jj = 1:c
        Red(ii,jj)=im((ii-1)*(3*c)+(jj-1)*3+1); 
        Green(ii,jj)=im((ii-1)*(3*c)+(jj-1)*3+2);
        Blue(ii,jj)=im((ii-1)*(3*c)+(jj-1)*3+3);
    end
end
% Construction of RGB image, in 3-D, 3-Dimensional array,
% 3rd dimension is for R, G, B values respectively.
for ii = 1:r
    for jj = 1:c
        img(ii,jj,1)=Red(ii,jj);
        img(ii,jj,2)=Green(ii,jj);
        img(ii,jj,3)=Blue(ii,jj);
    end
end
imshow(uint8(img));
