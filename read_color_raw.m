function [img] = read_color_raw(raw_image_name, raw_image_size)
fid=fopen(raw_image_name,'rb');
im=fread(fid,inf,'uchar');
fclose(fid);

r = raw_image_size(1); c = raw_image_size(2);

% Initialization of color fields
R = zeros(r,c);
G = zeros(r,c);
B = zeros(r,c);

% Initialization of the RGB image
img = zeros(r,c,3);

% RGB values are read in the same order they are provided 
for ii = 1:r
    for jj = 1:c
        R(ii,jj)=im((ii-1)*(3*c)+(jj-1)*3+1); 
        G(ii,jj)=im((ii-1)*(3*c)+(jj-1)*3+2);
        B(ii,jj)=im((ii-1)*(3*c)+(jj-1)*3+3);
    end
end
% Construction of RGB image, in 3-D,
% 3rd dimension is for R, G, B values respectively.
for ii = 1:r
    for jj = 1:c
        img(ii,jj,1)=R(ii,jj);
        img(ii,jj,2)=G(ii,jj);
        img(ii,jj,3)=B(ii,jj);
    end
end
imshow(uint8(img));
