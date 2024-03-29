clc
clear
close all

% Read all JPEG files from a folder
% Convert microscope image to binary
% Analyze regoinal properties for orientation


d = uigetdir(pwd, 'Select a folder');
addpath(d);
Folder = dir(fullfile(d, '*.jpg'));
prop_sum = [];

for i = 1:size(Folder,1)
    d = imread(Folder(i).name);
    rmat = d(:,:,1);
    gmat = d(:,:,2);
    bmat = d(:,:,3);

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
    BW = edge(sum_1,'sobel',threshold * fudgeFactor);
    se90 = strel('line',10,90);
    se0 = strel('line',10,0);
    BW = imdilate(BW,[se90 se0]);
    BW = imfill(BW,'holes');
    BW = bwareaopen(BW,5000);
    se0 = strel('line',10,0);
    BW = imdilate(BW,[se90 se0]);
    BW = imfill(BW,'holes');
    se1 = strel('diamond',3);
    BW = imerode(BW,se1);
    BW = imerode(BW,se1);
    BW = imfill(BW,'holes'); figure; imshow(BW);
    
    CC = bwconncomp(BW); 
    properties = regionprops(CC, 'orientation', 'MajorAxisLength', 'MinorAxisLength');
    prop_sum = [prop_sum;properties];
end

[~,index] = sortrows([prop_sum.MajorAxisLength].'); prop_sum = prop_sum(index(end:-1:1)); clear index;
M = extractfield(prop_sum,'MajorAxisLength');
theta = extractfield(prop_sum,'Orientation'); theta = deg2rad(theta);
    
outliers = M<400; M_out = M(outliers); theta_out = theta(outliers); %scale bar(25um) = 433 pixels
M = setdiff(M,M_out); theta = setdiff(theta,theta_out);
    
fibers = size(M,2);
x1 = zeros(1,fibers); y1 = zeros(1,fibers); x2 = cos(theta).*M; y2 = M.*sin(theta);
orientation = atan(y2./x2); orientation = rad2deg(orientation);
avg_orientation = mean(orientation,'all');
median_orientation = median(orientation,'all');

% Figure shows progression of image processing 
% figure;
% subplot (2,2,1), imshow(d);
% title ('Original Image');
% subplot(2,2,2), imshow(sum_1);
% title('RGB Layers Combined');
% subplot(2,2,4), imshow(BW1);
% title('Dilated RGB Combination');
