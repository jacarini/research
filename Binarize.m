clc
clear
close all

% Convert microscope image to binary
% 1b

% d = uigetdir(pwd, 'Select a folder');
% Folder = dir(fullfile(d, '*.jpg'));

picture = imread('1.jpg');

rmat = picture(:,:,1);
gmat = picture(:,:,2);
bmat = picture(:,:,3);
picture = im2bw(picture);
picture = imfill(picture,'holes');

[~,threshold] = edge(picture,'sobel');
fudgeFactor = 1.0;
dilate1 = edge(picture,'sobel',threshold * fudgeFactor);
se90 = strel('line',10,90);
se0 = strel('line',10,0);
dilate1 = imdilate(dilate1,[se90 se0]);
dilate1 = imfill(dilate1,'holes');
dilate1 = bwareaopen(dilate1,500);
se0 = strel('line',20,0);
dilate1 = imdilate(dilate1,se0);
dilate1 = imfill(dilate1,'holes');
se1 = strel('diamond',3);
dilate1 = imerode(dilate1,se1);
dilate1 = imerode(dilate1,se1);


levelr = 0.39;
levelg = 0.42;
levelb = 0.41;
r1 = imbinarize(rmat,levelr);
g1 = imbinarize(gmat,levelg);
b1 = imbinarize(bmat,levelb);
sum_1 = (r1&g1&b1);
sum_1 = imfill(sum_1,'holes');

[~,threshold] = edge(sum_1,'sobel');
fudgeFactor = 0.5;
BW1 = edge(sum_1,'sobel',threshold * fudgeFactor);
se90 = strel('line',10,90);
se0 = strel('line',10,0);
BW1 = imdilate(BW1,[se90 se0]);
BW1 = imfill(BW1,'holes');
BW1 = bwareaopen(BW1,5000);
se0 = strel('line',10,0);
BW1 = imdilate(BW1,[se90 se0]);
BW1 = imfill(BW1,'holes');
se1 = strel('diamond',3);
BW1 = imerode(BW1,se1);
BW1 = imerode(BW1,se1);
BW1 = imfill(BW1,'holes');

 figure;
 subplot(2,2,1), imshow(picture);
 title('Original Binary');
 subplot(2,2,2), imshow(sum_1);
 title('RGB Layers Combined');
 subplot(2,2,3), imshow(dilate1);
 title('Dilated Original');
 subplot(2,2,4), imshow(BW1);
 title('Dilated RGB Combination');

CC = bwconncomp(BW1);
properties = regionprops(CC, 'orientation', 'MajorAxisLength', 'MinorAxisLength');
[~,index] = sortrows([properties.MajorAxisLength].'); properties = properties(index(end:-1:1)); clear index;
M = extractfield(properties,'MajorAxisLength');
theta = extractfield(properties,'Orientation'); theta = deg2rad(theta);

outliers = M<400; M_out = M(outliers); theta_out = theta(outliers); %scale bar(25um) = 433 pixels
M = setdiff(M,M_out); theta = setdiff(theta,theta_out); 

fibers = size(M,2);
x1 = zeros(1,fibers); y1 = zeros(1,fibers); x2 = cos(theta).*M; y2 = M.*sin(theta);
orientation = atan(y2./x2);
